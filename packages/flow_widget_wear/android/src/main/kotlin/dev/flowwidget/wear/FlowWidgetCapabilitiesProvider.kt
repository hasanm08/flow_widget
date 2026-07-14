package dev.flowwidget.wear

object FlowWidgetCapabilitiesProvider {
    fun capabilities(): Map<String, Boolean> = mapOf(
        "homeWidgets" to false,
        "wearTiles" to true,
        "scheduledUpdates" to true,
        "backgroundUpdates" to true,
        "liveActivities" to false,
        "complications" to false,
        "appGroups" to false,
        "multipleInstances" to false,
    )
}
