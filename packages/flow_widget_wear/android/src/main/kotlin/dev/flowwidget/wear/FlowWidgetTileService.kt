package dev.flowwidget.wear

import androidx.wear.tiles.TileService
import androidx.wear.tiles.RequestBuilders
import androidx.wear.tiles.TileBuilders
import androidx.wear.tiles.TimelineBuilders
import com.google.common.util.concurrent.ListenableFuture
import java.time.Instant

/**
 * Base [TileService] that reads typed data from [FlowWidgetStorage].
 *
 * Host Wear modules extend this class and override [buildTileLayout] to render
 * protolayout content from stored `{t, v}` values.
 */
abstract class FlowWidgetTileService : TileService() {
    protected open val tileName: String
        get() = javaClass.simpleName

    protected val storage: FlowWidgetStorage by lazy {
        FlowWidgetStorage(applicationContext)
    }

    override fun onTileRequest(requestParams: RequestBuilders.TileRequest): ListenableFuture<TileBuilders.Tile> {
        val tile = TileBuilders.Tile.Builder()
            .setResourcesVersion(RESOURCES_VERSION)
            .setTileTimeline(
                TimelineBuilders.Timeline.Builder()
                    .addTimelineEntry(
                        TimelineBuilders.TimelineEntry.Builder()
                            .setLayout(buildTileLayout(requestParams))
                            .setValidity(
                                TimelineBuilders.TimeInterval.Builder()
                                    .setStartMillis(Instant.now().toEpochMilli())
                                    .build(),
                            )
                            .build(),
                    )
                    .build(),
            )
            .build()
        return com.google.common.util.concurrent.Futures.immediateFuture(tile)
    }

    override fun onTileResourcesRequest(
        requestParams: RequestBuilders.ResourcesRequest,
    ): ListenableFuture<TileBuilders.Resources> {
        val resources = TileBuilders.Resources.Builder()
            .setVersion(RESOURCES_VERSION)
            .build()
        return com.google.common.util.concurrent.Futures.immediateFuture(resources)
    }

    /** Subclasses render tile UI from [storage] data. */
    protected abstract fun buildTileLayout(
        requestParams: RequestBuilders.TileRequest,
    ): androidx.wear.protolayout.LayoutElementBuilders.LayoutElement

    companion object {
        private const val RESOURCES_VERSION = "1"
    }
}
