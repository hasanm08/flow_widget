package dev.flowwidget.wear

import android.content.Context
import android.content.SharedPreferences
import org.json.JSONArray
import org.json.JSONObject

/** Encodes and decodes flow_widget wire values `{t, v}`. */
object FlowWidgetValueCodec {
    fun encode(value: Any?): Map<String, Any?> {
        return when (value) {
            is Map<*, *> -> {
                if (value.containsKey("t") && value.containsKey("v")) {
                    @Suppress("UNCHECKED_CAST")
                    value as Map<String, Any?>
                } else {
                    mapOf(
                        "t" to "m",
                        "v" to value.entries.associate { (k, v) ->
                            k.toString() to encode(v)
                        },
                    )
                }
            }
            is String -> mapOf("t" to "s", "v" to value)
            is Int -> mapOf("t" to "i", "v" to value)
            is Long -> mapOf("t" to "i", "v" to value)
            is Double -> mapOf("t" to "d", "v" to value)
            is Float -> mapOf("t" to "d", "v" to value.toDouble())
            is Boolean -> mapOf("t" to "b", "v" to value)
            is ByteArray -> mapOf("t" to "bin", "v" to value)
            is List<*> -> mapOf("t" to "l", "v" to value.map { encode(it) })
            else -> mapOf("t" to "s", "v" to value?.toString().orEmpty())
        }
    }

    fun decode(wire: Map<String, Any?>): Any? {
        val type = wire["t"] as? String ?: return null
        val value = wire["v"]
        return when (type) {
            "s", "j" -> value as? String
            "i" -> when (value) {
                is Int -> value
                is Long -> value
                is Number -> value.toLong()
                else -> null
            }
            "d" -> when (value) {
                is Double -> value
                is Float -> value.toDouble()
                is Number -> value.toDouble()
                else -> null
            }
            "b" -> value as? Boolean
            "dt" -> when (value) {
                is Int -> value.toLong()
                is Long -> value
                is Number -> value.toLong()
                else -> null
            }
            "bin" -> when (value) {
                is ByteArray -> value
                is List<*> -> value.mapNotNull { (it as? Number)?.toInt()?.toByte() }.toByteArray()
                else -> null
            }
            "m" -> {
                val raw = value as? Map<*, *> ?: return null
                raw.entries.associate { (k, v) ->
                    k.toString() to decode(v as Map<String, Any?>)
                }
            }
            "l" -> {
                val raw = value as? List<*> ?: return null
                raw.mapNotNull { item ->
                    @Suppress("UNCHECKED_CAST")
                    decode(item as Map<String, Any?>)
                }
            }
            else -> null
        }
    }

    fun wireToJson(wire: Map<String, Any?>): String = JSONObject(wire).toString()

    fun wireFromJson(json: String): Map<String, Any?> {
        val objectJson = JSONObject(json)
        return jsonObjectToMap(objectJson)
    }

    private fun jsonObjectToMap(json: JSONObject): Map<String, Any?> {
        val result = linkedMapOf<String, Any?>()
        val keys = json.keys()
        while (keys.hasNext()) {
            val key = keys.next()
            result[key] = jsonValue(json.get(key))
        }
        return result
    }

    private fun jsonValue(value: Any?): Any? = when (value) {
        JSONObject.NULL -> null
        is JSONObject -> jsonObjectToMap(value)
        is JSONArray -> (0 until value.length()).map { index ->
            jsonValue(value.get(index))
        }
        else -> value
    }
}

/** SharedPreferences backed typed storage for Wear tiles. */
class FlowWidgetStorage(context: Context, prefsName: String = "flutter_flow_widget_wear") {
    private val prefs: SharedPreferences =
        context.getSharedPreferences(prefsName, Context.MODE_PRIVATE)

    fun save(key: String, wire: Map<String, Any?>) {
        prefs.edit().putString(dataKey(key), FlowWidgetValueCodec.wireToJson(wire)).apply()
    }

    fun saveBatch(entries: List<Map<String, Any?>>) {
        val editor = prefs.edit()
        for (entry in entries) {
            val key = entry["key"] as? String ?: continue
            @Suppress("UNCHECKED_CAST")
            val wire = entry["value"] as? Map<String, Any?> ?: continue
            editor.putString(dataKey(key), FlowWidgetValueCodec.wireToJson(wire))
        }
        editor.apply()
    }

    fun get(key: String): Map<String, Any?>? {
        val json = prefs.getString(dataKey(key), null) ?: return null
        return FlowWidgetValueCodec.wireFromJson(json)
    }

    fun getAll(prefix: String?): Map<String, Map<String, Any?>> {
        val result = linkedMapOf<String, Map<String, Any?>>()
        for ((fullKey, json) in prefs.all) {
            if (!fullKey.startsWith(DATA_PREFIX)) continue
            val shortKey = fullKey.removePrefix(DATA_PREFIX)
            if (prefix != null && !shortKey.startsWith(prefix)) continue
            val wire = json as? String ?: continue
            result[shortKey] = FlowWidgetValueCodec.wireFromJson(wire)
        }
        return result
    }

    fun remove(key: String) {
        prefs.edit().remove(dataKey(key)).apply()
    }

    fun clear() {
        val editor = prefs.edit()
        for (key in prefs.all.keys) {
            if (key.startsWith(DATA_PREFIX)) {
                editor.remove(key)
            }
        }
        editor.apply()
    }

    fun registerConfig(config: Map<String, Any?>) {
        val name = config["name"] as? String ?: return
        val configs = getConfigMap().toMutableMap()
        configs[name] = config
        prefs.edit().putString(CONFIGS_KEY, JSONObject(configs as Map<*, *>).toString()).apply()
    }

    fun allConfigs(): Map<String, Map<String, Any?>> {
        val raw = getConfigMap()
        val result = linkedMapOf<String, Map<String, Any?>>()
        for ((name, value) in raw) {
            @Suppress("UNCHECKED_CAST")
            val config = value as? Map<String, Any?> ?: continue
            result[name] = config
        }
        return result
    }

    fun tileServiceClass(name: String): String? {
        return allConfigs()[name]?.get("androidProvider") as? String
    }

    fun setLastUpdate(millis: Long) {
        prefs.edit().putLong(LAST_UPDATE_KEY, millis).apply()
    }

    private fun getConfigMap(): Map<String, Any?> {
        val json = prefs.getString(CONFIGS_KEY, null) ?: return emptyMap()
        return FlowWidgetValueCodec.wireFromJson(json)
    }

    private fun dataKey(key: String): String = DATA_PREFIX + key

    companion object {
        private const val DATA_PREFIX = "flow_widget.data."
        private const val CONFIGS_KEY = "flow_widget.configs"
        private const val LAST_UPDATE_KEY = "flow_widget.last_update"
    }
}
