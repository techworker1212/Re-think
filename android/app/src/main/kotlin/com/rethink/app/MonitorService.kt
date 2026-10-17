package com.rethink.app

import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.provider.Settings

/**
 * Polls the foreground app once a second. When a ruled app has been used continuously
 * past its limit: show that rule's warning, wait five seconds, then block it and open
 * the pause screen. A blocked app gets the pause screen every time it comes forward
 * until the user unlocks it.
 */
class MonitorService : Service() {
    private val handler = Handler(Looper.getMainLooper())
    private lateinit var store: RuleStore
    private lateinit var usage: UsageStatsManager

    private var foregroundPackage: String? = null
    private var lastQueryEnd = 0L
    private val sessions = mutableMapOf<String, Session>()
    private var pending: PendingPause? = null
    private var lastPauseLaunch = 0L
    private var lastNotificationState: Pair<Int, Boolean>? = null

    private class Session(var startedAt: Long, var lastSeenAt: Long)

    private class PendingPause(val ruleId: String, val fireAt: Long)

    private val tick = object : Runnable {
        override fun run() {
            try {
                step(System.currentTimeMillis())
            } finally {
                if (running) handler.postDelayed(this, TICK_MS)
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        store = RuleStore(this)
        usage = getSystemService(UsageStatsManager::class.java)
        Notifications.ensureChannels(this)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP || !store.monitoring) {
            stopSelf()
            return START_NOT_STICKY
        }
        updateForegroundNotification(force = true)
        if (!running) {
            running = true
            lastQueryEnd = System.currentTimeMillis() - LOOKBACK_MS
            handler.post(tick)
        }
        return START_STICKY
    }

    override fun onDestroy() {
        running = false
        handler.removeCallbacks(tick)
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun step(now: Long) {
        if (!store.monitoring) {
            stopSelf()
            return
        }
        updateForegroundNotification(force = false)
        if (store.startNewDayIfNeeded()) {
            // Midnight: everyone starts the day with a clean slate.
            sessions.clear()
            pending = null
        }
        val current = readForegroundPackage(now)
        val rules = store.rules().filter { it.enabled }
        val rule = rules.firstOrNull { it.packageName == current }

        pending?.let { warning ->
            if (now >= warning.fireAt) {
                pending = null
                store.rule(warning.ruleId)?.let { block(it, inFront = it.packageName == current, now) }
            }
        }

        if (rule == null || current == null) return

        val session = sessions.getOrPut(rule.packageName) { Session(now, now) }
        if (now - session.lastSeenAt > SESSION_GAP_MS) session.startedAt = now
        session.lastSeenAt = now

        when {
            store.isBlocked(rule.id) -> showPause(rule, now)
            pending?.ruleId == rule.id -> Unit
            now < store.cooldownUntil(rule.id) -> Unit
            now - session.startedAt >= rule.limitMinutes * 60_000L -> {
                store.recordInterruption(rule.id)
                Notifications.showWarning(this, rule)
                pending = PendingPause(rule.id, now + Notifications.WARNING_SECONDS * 1000L)
            }
        }
    }

    private fun block(rule: StoredRule, inFront: Boolean, now: Long) {
        store.block(rule.id)
        if (inFront) showPause(rule, now)
    }

    private fun showPause(rule: StoredRule, now: Long) {
        if (now - lastPauseLaunch < RELAUNCH_THROTTLE_MS) return
        lastPauseLaunch = now
        if (Settings.canDrawOverlays(this)) {
            Notifications.clearWarning(this, rule.id)
            startActivity(PauseActivity.intent(this, rule.id))
        } else {
            Notifications.showPausedFallback(this, rule)
        }
    }

    /** Replays usage events since the last tick to learn which app is in front. */
    private fun readForegroundPackage(now: Long): String? {
        val events = usage.queryEvents(lastQueryEnd, now)
        lastQueryEnd = now
        val event = UsageEvents.Event()
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            when (event.eventType) {
                UsageEvents.Event.ACTIVITY_RESUMED -> foregroundPackage = event.packageName
                UsageEvents.Event.SCREEN_NON_INTERACTIVE,
                UsageEvents.Event.KEYGUARD_SHOWN -> foregroundPackage = null
            }
        }
        return foregroundPackage
    }

    private fun updateForegroundNotification(force: Boolean) {
        val state = store.rules().count { it.enabled } to Permissions.hasUsageAccess(this)
        if (!force && state == lastNotificationState) return
        lastNotificationState = state
        val notification = Notifications.monitoring(this, state.first, state.second)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                Notifications.MONITOR_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE,
            )
        } else {
            startForeground(Notifications.MONITOR_ID, notification)
        }
    }

    companion object {
        private const val ACTION_STOP = "com.rethink.app.STOP"
        private const val TICK_MS = 1_000L
        private const val LOOKBACK_MS = 10 * 60_000L

        /** Leaving an app for longer than this ends the continuous-use session. */
        private const val SESSION_GAP_MS = 30_000L
        private const val RELAUNCH_THROTTLE_MS = 1_500L

        @Volatile
        var running = false
            private set

        fun start(context: Context) {
            context.startForegroundService(Intent(context, MonitorService::class.java))
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, MonitorService::class.java))
        }
    }
}
