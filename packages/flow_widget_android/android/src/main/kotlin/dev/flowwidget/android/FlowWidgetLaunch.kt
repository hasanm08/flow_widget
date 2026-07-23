package dev.flowwidget.android

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri

/**
 * Builds launch [Intent]s for Glance `actionStartActivity` without letting
 * AndroidX Glance inject its trampoline `/CALLBACK?...` [Uri] into
 * [Intent.data].
 *
 * Glance requires PendingIntents to be unique. When [Intent.data] is null it
 * calls `createUniqueUri` and `setData`s a path like
 * `/CALLBACK?appWidgetId=…&viewId=…`. Flutter deep linking then treats that
 * as a route and shows "Page not found".
 *
 * Always set a stable app URI (and optional extras) via [activityIntent]
 * before passing the Intent to Glance.
 */
object FlowWidgetLaunch {
    /** FlutterActivity initial route extra (e.g. `"/invoices/sales/new"`). */
    const val EXTRA_ROUTE = "route"

    /** Named click action for [FlowWidgetPlugin.emitClick] / Dart `onClicked`. */
    const val EXTRA_ACTION = "flow_widget_action"

    /** Widget family name for click events. */
    const val EXTRA_WIDGET_NAME = "flow_widget_name"

    /** Optional Android `appWidgetId` for click events. */
    const val EXTRA_WIDGET_ID = "flow_widget_id"

    /** Default URI scheme used when Glance would otherwise inject `/CALLBACK`. */
    const val DEFAULT_SCHEME = "flowwidget"

    /** Default URI host used with [DEFAULT_SCHEME]. */
    const val DEFAULT_HOST = "app"

    /**
     * Creates an [Intent] that opens [activityClass] with a unique [data] URI
     * so Glance does not overwrite [Intent.data] with `/CALLBACK`.
     *
     * @param route Flutter route path, with or without a leading `/`
     * @param action Optional named action emitted on [FlowWidget.onClicked]
     * @param widgetName Optional widget family name for click events
     * @param widgetId Optional per-instance Android app widget id
     * @param scheme URI scheme for [Intent.data] (must be unique per PendingIntent)
     * @param host URI authority for [Intent.data]
     */
    @JvmStatic
    @JvmOverloads
    fun activityIntent(
        context: Context,
        activityClass: Class<out Activity>,
        route: String,
        action: String? = null,
        widgetName: String? = null,
        widgetId: Int? = null,
        scheme: String = DEFAULT_SCHEME,
        host: String = DEFAULT_HOST,
    ): Intent {
        val normalizedRoute = if (route.startsWith("/")) route else "/$route"
        return Intent(context, activityClass).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_CLEAR_TOP or
                Intent.FLAG_ACTIVITY_SINGLE_TOP
            this.action = Intent.ACTION_VIEW
            putExtra(EXTRA_ROUTE, normalizedRoute)
            if (action != null) putExtra(EXTRA_ACTION, action)
            if (widgetName != null) putExtra(EXTRA_WIDGET_NAME, widgetName)
            if (widgetId != null) putExtra(EXTRA_WIDGET_ID, widgetId)
            // Prevent Glance from injecting /CALLBACK — data must be non-null
            // and unique enough for PendingIntent identity.
            data = Uri.Builder()
                .scheme(scheme)
                .authority(host)
                .path(normalizedRoute.trimStart('/'))
                .build()
        }
    }
}
