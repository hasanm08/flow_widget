package dev.flowwidget.android

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.os.Build
import android.os.Bundle

/**
 * Refreshes installed App Widgets using provider class names registered via
 * [FlowWidgetStorage.registerConfig].
 */
class FlowWidgetUpdater(
    private val context: Context,
    private val storage: FlowWidgetStorage,
) {
    fun update(request: Map<*, *>) {
        applyRequestData(request)
        refresh(
            name = request["name"] as? String,
            id = request["id"] as? Int,
            reloadTimeline = request["reloadTimeline"] as? Boolean ?: true,
        )
    }

    fun updateMany(requests: List<Map<*, *>>) {
        for (request in requests) {
            applyRequestData(request)
            refresh(
                name = request["name"] as? String,
                id = request["id"] as? Int,
                reloadTimeline = request["reloadTimeline"] as? Boolean ?: true,
            )
        }
    }

    fun updateAll() {
        val configs = storage.getAllRegisteredConfigs()
        for (name in configs.keys) {
            refresh(name = name, id = null, reloadTimeline = true)
        }
    }

    fun setTimeline(widgetId: Map<*, *>, entries: List<Map<*, *>>) {
        storage.setTimeline(widgetId, entries)
        refresh(
            name = widgetId["name"] as? String,
            id = widgetId["id"] as? Int,
            reloadTimeline = true,
        )
    }

    fun getInstalledWidgets(): List<Map<String, Any?>> {
        val manager = AppWidgetManager.getInstance(context)
        val configs = storage.getAllRegisteredConfigs()
        val providerToName = buildMap {
            for ((name, config) in configs) {
                val provider = config["androidProvider"] as? String ?: continue
                put(provider, name)
            }
        }

        val results = mutableListOf<Map<String, Any?>>()
        for ((providerClass, name) in providerToName) {
            val component = resolveComponent(providerClass) ?: continue
            val ids = manager.getAppWidgetIds(component)
            for (widgetId in ids) {
                val options = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                    manager.getAppWidgetOptions(widgetId)
                } else {
                    Bundle()
                }
                results.add(
                    mapOf(
                        "widgetId" to mapOf(
                            "name" to name,
                            "id" to widgetId,
                        ),
                        "size" to sizeFromOptions(options),
                        "family" to "home",
                        "lastUpdated" to System.currentTimeMillis(),
                    ),
                )
            }
        }
        return results
    }

    fun requestPinWidget(name: String, initialData: Map<*, *>?): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return false
        }

        val config = storage.getRegisteredConfig(name)
            ?: throw IllegalArgumentException("No config registered for widget '$name'")
        val providerClass = config["androidProvider"] as? String
            ?: throw IllegalArgumentException("Widget '$name' has no androidProvider")

        if (initialData != null) {
            for ((key, value) in initialData) {
                val stringKey = key as? String ?: continue
                val wire = value as? Map<*, *> ?: continue
                storage.saveData(stringKey, wire)
            }
        }

        val manager = AppWidgetManager.getInstance(context)
        if (!manager.isRequestPinAppWidgetSupported) {
            return false
        }

        val component = resolveComponent(providerClass)
            ?: throw IllegalStateException("Unable to resolve provider $providerClass")
        return manager.requestPinAppWidget(component, null, null)
    }

    private fun applyRequestData(request: Map<*, *>) {
        val data = request["data"] as? Map<*, *> ?: return
        for ((key, value) in data) {
            val stringKey = key as? String ?: continue
            val wire = value as? Map<*, *> ?: continue
            storage.saveData(stringKey, wire)
        }
    }

    private fun refresh(name: String?, id: Int?, reloadTimeline: Boolean) {
        if (name.isNullOrEmpty()) return
        val config = storage.getRegisteredConfig(name) ?: return
        val providerClass = config["androidProvider"] as? String ?: return
        val component = resolveComponent(providerClass) ?: return

        val manager = AppWidgetManager.getInstance(context)
        val widgetIds = if (id != null) {
            intArrayOf(id)
        } else {
            manager.getAppWidgetIds(component)
        }

        if (widgetIds.isEmpty()) return

        if (reloadTimeline) {
            manager.notifyAppWidgetViewDataChanged(widgetIds, android.R.id.list)
        }
        manager.notifyAppWidgetViewDataChanged(widgetIds, 0)
    }

    private fun resolveComponent(providerClass: String): ComponentName? {
        return try {
            Class.forName(providerClass)
            ComponentName(context.packageName, providerClass)
        } catch (_: ClassNotFoundException) {
            null
        }
    }

    private fun sizeFromOptions(options: Bundle): String {
        val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 0)
        val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0)
        val area = minWidth * minHeight
        return when {
            area <= 0 -> "medium"
            area < 180 * 110 -> "small"
            area < 280 * 180 -> "medium"
            else -> "large"
        }
    }
}
