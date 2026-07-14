package dev.flowwidget.wear

import android.content.Context
import androidx.wear.tiles.TileService
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

/** Requests Wear OS tile refreshes via [TileService.getUpdater]. */
class FlowWidgetTileUpdater(private val context: Context) {
    fun requestUpdate(tileServiceClass: Class<out FlowWidgetTileService>) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                TileService.getUpdater(context).requestUpdate(tileServiceClass)
            } catch (_: Exception) {
                // TileService may not be declared in the host Wear module yet.
            }
        }
    }

    fun requestUpdateByName(name: String, storage: FlowWidgetStorage) {
        val className = storage.tileServiceClass(name) ?: return
        try {
            @Suppress("UNCHECKED_CAST")
            val clazz = Class.forName(className) as Class<out FlowWidgetTileService>
            requestUpdate(clazz)
        } catch (_: ClassNotFoundException) {
        }
    }

    fun requestUpdateAll(storage: FlowWidgetStorage) {
        for ((_, config) in storage.allConfigs()) {
            val provider = config["androidProvider"] as? String ?: continue
            try {
                @Suppress("UNCHECKED_CAST")
                val clazz = Class.forName(provider) as Class<out FlowWidgetTileService>
                requestUpdate(clazz)
            } catch (_: ClassNotFoundException) {
            }
        }
    }
}
