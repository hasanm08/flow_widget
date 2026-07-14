package dev.flowwidget.android

import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Test

class FlowWidgetValueCodecTest {
    @Test
    fun roundTripsStringValue() {
        val wire = mapOf("t" to "s", "v" to "hello")
        val json = FlowWidgetValueCodec.encodeToJson(wire)
        val decoded = FlowWidgetValueCodec.decodeFromJson(json)
        assertEquals("s", decoded["t"])
        assertEquals("hello", decoded["v"])
    }

    @Test
    fun roundTripsDateTimeValue() {
        val wire = mapOf("t" to "dt", "v" to 1_700_000_000_000L)
        val decoded = FlowWidgetValueCodec.decodeFromJson(FlowWidgetValueCodec.encodeToJson(wire))
        assertEquals(1_700_000_000_000L, decoded["v"])
    }

    @Test
    fun roundTripsNestedMap() {
        val wire = mapOf(
            "t" to "m",
            "v" to mapOf(
                "title" to mapOf("t" to "s", "v" to "News"),
                "count" to mapOf("t" to "i", "v" to 3),
            ),
        )
        val decoded = FlowWidgetValueCodec.decodeFromJson(FlowWidgetValueCodec.encodeToJson(wire))
        val map = decoded["v"] as Map<*, *>
        val title = map["title"] as Map<*, *>
        assertEquals("News", title["v"])
    }

    @Test
    fun encodeToJsonProducesValidJson() {
        val wire = mapOf("t" to "j", "v" to """{"ok":true}""")
        val json = FlowWidgetValueCodec.encodeToJson(wire)
        val objectJson = JSONObject(json)
        assertEquals("j", objectJson.getString("t"))
    }
}
