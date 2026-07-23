package dev.flowwidget.android

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

/**
 * [FlutterActivity] that strips Glance trampoline `/CALLBACK` URIs and prefers
 * [FlowWidgetLaunch.EXTRA_ROUTE] for the Flutter initial route.
 *
 * Extend this from your app `MainActivity` (or call [sanitizeGlanceCallback]
 * yourself) whenever Glance uses `actionStartActivity`.
 */
open class FlowWidgetFlutterActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        sanitizeGlanceCallback(intent)
        maybeEmitClick(intent)
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        sanitizeGlanceCallback(intent)
        setIntent(intent)
        maybeEmitClick(intent)
        super.onNewIntent(intent)
    }

    override fun getInitialRoute(): String? {
        return intent?.getStringExtra(FlowWidgetLaunch.EXTRA_ROUTE)
            ?: super.getInitialRoute()
    }

    companion object {
        /**
         * Rewrites Glance `/CALLBACK?...` [Intent.data] to a stable
         * `flowwidget://app…` URI so Flutter deep linking does not navigate to
         * a non-existent `/CALLBACK` route.
         */
        @JvmStatic
        fun sanitizeGlanceCallback(intent: Intent?) {
            intent ?: return
            val data = intent.data?.toString().orEmpty()
            if (!data.contains("CALLBACK", ignoreCase = true)) return
            val route = intent.getStringExtra(FlowWidgetLaunch.EXTRA_ROUTE) ?: "/"
            val normalized = if (route.startsWith("/")) route else "/$route"
            intent.data = Uri.parse(
                "${FlowWidgetLaunch.DEFAULT_SCHEME}://${FlowWidgetLaunch.DEFAULT_HOST}$normalized",
            )
            intent.putExtra(FlowWidgetLaunch.EXTRA_ROUTE, normalized)
        }

        /**
         * Emits a `click` event on the flow_widget EventChannel when the Intent
         * carries [FlowWidgetLaunch.EXTRA_ACTION].
         */
        @JvmStatic
        fun maybeEmitClick(intent: Intent?) {
            intent ?: return
            val action = intent.getStringExtra(FlowWidgetLaunch.EXTRA_ACTION) ?: return
            val name = intent.getStringExtra(FlowWidgetLaunch.EXTRA_WIDGET_NAME) ?: "unknown"
            val widgetId = if (intent.hasExtra(FlowWidgetLaunch.EXTRA_WIDGET_ID)) {
                intent.getIntExtra(FlowWidgetLaunch.EXTRA_WIDGET_ID, -1).takeIf { it >= 0 }
            } else {
                null
            }
            FlowWidgetPlugin.emitClick(
                widgetName = name,
                widgetId = widgetId,
                action = action,
                uri = intent.data?.toString(),
            )
        }
    }
}
