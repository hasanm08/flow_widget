package dev.flowwidget.android

import android.os.Build

/**
 * Reports Android-specific capability flags for the flow_widget Dart API.
 */
object FlowWidgetCapabilitiesProvider {
    fun getCapabilities(): Map<String, Boolean> {
        val supportsPin = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
        val supportsInteractive = Build.VERSION.SDK_INT >= Build.VERSION_CODES.S

        return mapOf(
            "homeWidgets" to true,
            "lockScreenWidgets" to (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU),
            "interactiveWidgets" to supportsInteractive,
            "configurableWidgets" to true,
            "timelineProviders" to true,
            "liveActivities" to false,
            "dynamicIsland" to false,
            "pinWidget" to supportsPin,
            "backgroundUpdates" to true,
            "scheduledUpdates" to true,
            "pushUpdates" to false,
            "remoteImageCaching" to true,
            "appGroups" to true,
            "wearTiles" to false,
            "complications" to false,
            "multipleInstances" to true,
            "resizing" to (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S),
            "themeSynchronization" to (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S),
            "appIntents" to false,
        )
    }
}
