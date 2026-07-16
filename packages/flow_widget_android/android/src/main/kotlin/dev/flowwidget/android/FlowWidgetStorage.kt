package dev.flowwidget.android

import android.content.Context
import android.content.SharedPreferences
import org.json.JSONArray
import org.json.JSONObject

/**
 * Typed key/value storage backed by [SharedPreferences].
 *
 * Values are persisted as JSON-encoded wire maps so complex types round-trip
 * without loss.
 */
class FlowWidgetStorage(
    private val preferences: SharedPreferences,
) {
    companion object {
        /**
         * Default SharedPreferences file name. Must match
         * [FlowWidgetOptions.androidNamedSharedPreferences] when that option is
         * null, and the name passed to [create] from Glance / RemoteViews code.
         */
        const val DEFAULT_PREFS_NAME = "flutter_flow_widget"

        private const val DATA_PREFIX = "flow_widget.data."
        private const val CONFIG_PREFIX = "flow_widget.config."
        private const val TIMELINE_PREFIX = "flow_widget.timeline."
        private const val METADATA_PREFIX = "flow_widget.meta."

        fun create(context: Context, prefsName: String = DEFAULT_PREFS_NAME): FlowWidgetStorage {
            val preferences = context.getSharedPreferences(prefsName, Context.MODE_PRIVATE)
            return FlowWidgetStorage(preferences)
        }

        fun scopedKey(groupId: String?, key: String): String {
            return if (groupId.isNullOrEmpty()) key else "$groupId::$key"
        }
    }

    fun saveData(key: String, wire: Map<*, *>, groupId: String? = null) {
        val storageKey = DATA_PREFIX + scopedKey(groupId, key)
        val encoded = FlowWidgetValueCodec.encodeToJson(wire)
        preferences.edit().putString(storageKey, encoded).apply()
    }

    fun saveBatch(entries: List<Map<*, *>>, groupId: String? = null) {
        val editor = preferences.edit()
        for (entry in entries) {
            val key = entry["key"] as? String ?: continue
            val wire = entry["value"] as? Map<*, *> ?: continue
            val storageKey = DATA_PREFIX + scopedKey(groupId, key)
            editor.putString(storageKey, FlowWidgetValueCodec.encodeToJson(wire))
        }
        editor.apply()
    }

    fun getData(key: String, groupId: String? = null): Map<String, Any?>? {
        val storageKey = DATA_PREFIX + scopedKey(groupId, key)
        val json = preferences.getString(storageKey, null) ?: return null
        return FlowWidgetValueCodec.decodeFromJson(json)
    }

    fun getAllData(prefix: String? = null, groupId: String? = null): Map<String, Map<String, Any?>> {
        val groupPrefix = if (groupId.isNullOrEmpty()) {
            DATA_PREFIX
        } else {
            DATA_PREFIX + "$groupId::"
        }
        val keyPrefix = if (prefix.isNullOrEmpty()) {
            groupPrefix
        } else {
            groupPrefix + prefix
        }

        return buildMap {
            for ((storageKey, json) in preferences.all) {
                if (storageKey !is String || json !is String) continue
                if (!storageKey.startsWith(keyPrefix)) continue
                val logicalKey = storageKey.removePrefix(groupPrefix)
                put(logicalKey, FlowWidgetValueCodec.decodeFromJson(json))
            }
        }
    }

    fun removeData(key: String, groupId: String? = null) {
        val storageKey = DATA_PREFIX + scopedKey(groupId, key)
        preferences.edit().remove(storageKey).apply()
    }

    fun clearData(groupId: String? = null) {
        val editor = preferences.edit()
        val prefix = if (groupId.isNullOrEmpty()) {
            DATA_PREFIX
        } else {
            DATA_PREFIX + "$groupId::"
        }
        for (key in preferences.all.keys) {
            if (key is String && key.startsWith(prefix)) {
                editor.remove(key)
            }
        }
        editor.apply()
    }

    fun registerConfig(config: Map<*, *>) {
        val name = config["name"] as? String ?: return
        val json = JSONObject()
        for ((key, value) in config) {
            if (key is String && value != null) {
                when (value) {
                    is List<*> -> json.put(key, JSONArray(value))
                    else -> json.put(key, value)
                }
            }
        }
        preferences.edit()
            .putString(CONFIG_PREFIX + name, json.toString())
            .apply()
    }

    fun getRegisteredConfig(name: String): Map<String, Any?>? {
        val json = preferences.getString(CONFIG_PREFIX + name, null) ?: return null
        return jsonObjectToMap(JSONObject(json))
    }

    fun getAllRegisteredConfigs(): Map<String, Map<String, Any?>> {
        return buildMap {
            for ((key, value) in preferences.all) {
                if (key !is String || value !is String) continue
                if (!key.startsWith(CONFIG_PREFIX)) continue
                val name = key.removePrefix(CONFIG_PREFIX)
                put(name, jsonObjectToMap(JSONObject(value)))
            }
        }
    }

    fun setTimeline(widgetId: Map<*, *>, entries: List<Map<*, *>>) {
        val name = widgetId["name"] as? String ?: return
        val id = widgetId["id"] as? Int
        val key = timelineKey(name, id)
        val array = JSONArray()
        for (entry in entries) {
            val objectJson = JSONObject()
            for ((entryKey, entryValue) in entry) {
                if (entryKey is String && entryValue != null) {
                    when (entryValue) {
                        is Map<*, *> -> objectJson.put(entryKey, mapToJsonObject(entryValue))
                        is List<*> -> objectJson.put(entryKey, JSONArray(entryValue))
                        else -> objectJson.put(entryKey, entryValue)
                    }
                }
            }
            array.put(objectJson)
        }
        preferences.edit().putString(TIMELINE_PREFIX + key, array.toString()).apply()
    }

    fun getTimeline(name: String, id: Int?): List<Map<String, Any?>> {
        val json = preferences.getString(TIMELINE_PREFIX + timelineKey(name, id), null)
            ?: return emptyList()
        val array = JSONArray(json)
        return buildList {
            for (index in 0 until array.length()) {
                add(jsonObjectToMap(array.getJSONObject(index)))
            }
        }
    }

    fun setMetadata(key: String, value: String) {
        preferences.edit().putString(METADATA_PREFIX + key, value).apply()
    }

    fun getMetadata(key: String): String? {
        return preferences.getString(METADATA_PREFIX + key, null)
    }

    private fun timelineKey(name: String, id: Int?): String {
        return if (id == null) name else "$name#$id"
    }

    private fun jsonObjectToMap(json: JSONObject): Map<String, Any?> {
        return buildMap {
            val keys = json.keys()
            while (keys.hasNext()) {
                val key = keys.next()
                put(key, json.opt(key))
            }
        }
    }

    private fun mapToJsonObject(map: Map<*, *>): JSONObject {
        val json = JSONObject()
        for ((key, value) in map) {
            if (key is String && value != null) {
                json.put(key, value)
            }
        }
        return json
    }
}
