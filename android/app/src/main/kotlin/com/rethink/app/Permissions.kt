package com.rethink.app

import android.app.AppOpsManager
import android.app.NotificationManager
import android.content.Context
import android.os.PowerManager
import android.os.Process
import android.provider.Settings

object Permissions {
    fun hasUsageAccess(context: Context): Boolean {
        val appOps = context.getSystemService(AppOpsManager::class.java)
        val mode = appOps.unsafeCheckOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(),
            context.packageName,
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    fun snapshot(context: Context) = PermissionSnapshot(
        familyControls = false,
        notifications = context.getSystemService(NotificationManager::class.java)
            .areNotificationsEnabled(),
        usageAccess = hasUsageAccess(context),
        overlay = Settings.canDrawOverlays(context),
        batteryExemption = context.getSystemService(PowerManager::class.java)
            .isIgnoringBatteryOptimizations(context.packageName),
    )
}
