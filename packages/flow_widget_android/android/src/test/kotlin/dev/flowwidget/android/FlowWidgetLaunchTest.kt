package dev.flowwidget.android

import android.content.Intent
import android.net.Uri
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class FlowWidgetLaunchTest {
    @Test
    fun activityIntentSetsUniqueDataUriAndExtras() {
        val context = RuntimeEnvironment.getApplication()
        val intent = FlowWidgetLaunch.activityIntent(
            context = context,
            activityClass = android.app.Activity::class.java,
            route = "dashboard",
            action = "open",
            widgetName = "DemoWidget",
            widgetId = 7,
        )

        assertEquals(Intent.ACTION_VIEW, intent.action)
        assertEquals("/dashboard", intent.getStringExtra(FlowWidgetLaunch.EXTRA_ROUTE))
        assertEquals("open", intent.getStringExtra(FlowWidgetLaunch.EXTRA_ACTION))
        assertEquals("DemoWidget", intent.getStringExtra(FlowWidgetLaunch.EXTRA_WIDGET_NAME))
        assertEquals(7, intent.getIntExtra(FlowWidgetLaunch.EXTRA_WIDGET_ID, -1))
        assertNotNull(intent.data)
        assertEquals("flowwidget", intent.data!!.scheme)
        assertEquals("app", intent.data!!.host)
        assertEquals("/dashboard", intent.data!!.path)
        assertFalse(intent.data.toString().contains("CALLBACK", ignoreCase = true))
    }

    @Test
    fun sanitizeRewritesGlanceCallbackUri() {
        val intent = Intent().apply {
            data = Uri.parse("/CALLBACK?appWidgetId=5&viewId=12&viewSize=1x1&extraData=")
            putExtra(FlowWidgetLaunch.EXTRA_ROUTE, "/invoices/new")
        }

        FlowWidgetFlutterActivity.sanitizeGlanceCallback(intent)

        assertEquals("flowwidget://app/invoices/new", intent.data.toString())
        assertEquals("/invoices/new", intent.getStringExtra(FlowWidgetLaunch.EXTRA_ROUTE))
    }

    @Test
    fun sanitizeLeavesNonCallbackUriAlone() {
        val original = Uri.parse("flowwidget://app/home")
        val intent = Intent().apply {
            data = original
            putExtra(FlowWidgetLaunch.EXTRA_ROUTE, "/home")
        }

        FlowWidgetFlutterActivity.sanitizeGlanceCallback(intent)

        assertEquals(original, intent.data)
    }

    @Test
    fun sanitizeDefaultsRouteWhenExtraMissing() {
        val intent = Intent().apply {
            data = Uri.parse("/CALLBACK?appWidgetId=1")
        }

        FlowWidgetFlutterActivity.sanitizeGlanceCallback(intent)

        assertEquals("flowwidget://app/", intent.data.toString())
        assertEquals("/", intent.getStringExtra(FlowWidgetLaunch.EXTRA_ROUTE))
    }

    @Test
    fun maybeEmitClickNoopsWithoutActionExtra() {
        // Should not throw when plugin instance is null and action is absent.
        FlowWidgetFlutterActivity.maybeEmitClick(Intent())
    }
}
