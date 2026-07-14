package dev.flowwidget.android

import android.util.Base64
import org.json.JSONArray
import org.json.JSONObject

/**
 * Encodes and decodes [FlowWidgetValue] wire maps `{t, v}` for MethodChannel
 * transport and JSON persistence.
 */
object FlowWidgetValueCodec {
    private const val KEY_TYPE = "t"
    private const val KEY_VALUE = "v"

    fun encode(wire: Map<*, *>): Map<String, Any?> {
        val type = wire[KEY_TYPE] as? String
            ?: throw IllegalArgumentException("Missing wire type discriminator")
        val value = wire[KEY_VALUE]
        return mapOf(KEY_TYPE to type, KEY_VALUE to encodeValue(type, value))
    }

    fun decode(wire: Map<*, *>): Map<String, Any?> {
        val type = wire[KEY_TYPE] as? String
            ?: throw IllegalArgumentException("Missing wire type discriminator")
        val value = wire[KEY_VALUE]
        return mapOf(KEY_TYPE to type, KEY_VALUE to decodeValue(type, value))
    }

    fun encodeToJson(wire: Map<*, *>): String {
        return JSONObject(encode(wire)).toString()
    }

    fun decodeFromJson(json: String): Map<String, Any?> {
        val objectJson = JSONObject(json)
        val wire = mapOf(
            KEY_TYPE to objectJson.getString(KEY_TYPE),
            KEY_VALUE to objectJson.opt(KEY_VALUE),
        )
        return decode(wire)
    }

    fun encodeDataMap(data: Map<*, *>?): Map<String, Map<String, Any?>> {
        if (data == null) return emptyMap()
        return buildMap {
            for ((key, value) in data) {
                val stringKey = key as? String ?: continue
                val wire = value as? Map<*, *> ?: continue
                put(stringKey, encode(wire))
            }
        }
    }

    fun decodeDataMap(data: Map<*, *>?): Map<String, Map<String, Any?>> {
        if (data == null) return emptyMap()
        return buildMap {
            for ((key, value) in data) {
                val stringKey = key as? String ?: continue
                val wire = value as? Map<*, *> ?: continue
                put(stringKey, decode(wire))
            }
        }
    }

    private fun encodeValue(type: String, value: Any?): Any? {
        return when (type) {
            "m" -> encodeMap(value)
            "l" -> encodeList(value)
            "bin" -> encodeBytes(value)
            else -> value
        }
    }

    private fun decodeValue(type: String, value: Any?): Any? {
        return when (type) {
            "m" -> decodeMap(value)
            "l" -> decodeList(value)
            "bin" -> decodeBytes(value)
            else -> value
        }
    }

    private fun encodeMap(value: Any?): JSONObject {
        val map = value as? Map<*, *> ?: emptyMap<Any?, Any?>()
        val json = JSONObject()
        for ((key, entryValue) in map) {
            val stringKey = key as? String ?: continue
            val wire = entryValue as? Map<*, *> ?: continue
            json.put(stringKey, JSONObject(encode(wire)))
        }
        return json
    }

    private fun decodeMap(value: Any?): Map<String, Any?> {
        val json = value as? JSONObject ?: return emptyMap()
        return buildMap {
            val keys = json.keys()
            while (keys.hasNext()) {
                val key = keys.next()
                val nested = json.getJSONObject(key)
                put(key, decodeValue(nested.getString(KEY_TYPE), nested.opt(KEY_VALUE)))
            }
        }
    }

    private fun encodeList(value: Any?): JSONArray {
        val list = value as? List<*> ?: emptyList<Any?>()
        val json = JSONArray()
        for (item in list) {
            val wire = item as? Map<*, *> ?: continue
            json.put(JSONObject(encode(wire)))
        }
        return json
    }

    private fun decodeList(value: Any?): List<Any?> {
        val json = value as? JSONArray ?: return emptyList()
        return buildList {
            for (index in 0 until json.length()) {
                val nested = json.getJSONObject(index)
                add(decodeValue(nested.getString(KEY_TYPE), nested.opt(KEY_VALUE)))
            }
        }
    }

    private fun encodeBytes(value: Any?): String {
        return when (value) {
            is ByteArray -> Base64.encodeToString(value, Base64.NO_WRAP)
            is List<*> -> {
                val bytes = ByteArray(value.size) { index ->
                    (value[index] as Number).toInt().toByte()
                }
                Base64.encodeToString(bytes, Base64.NO_WRAP)
            }
            is String -> value
            else -> ""
        }
    }

    private fun decodeBytes(value: Any?): ByteArray {
        val encoded = value as? String ?: return ByteArray(0)
        return Base64.decode(encoded, Base64.NO_WRAP)
    }
}
