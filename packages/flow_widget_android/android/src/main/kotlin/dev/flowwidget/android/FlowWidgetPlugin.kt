package dev.flowwidget.android

import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** Android implementation of the flow_widget federated plugin. */
class FlowWidgetPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    companion object {
        private const val METHOD_CHANNEL = "dev.flow_widget/methods"
        private const val EVENT_CHANNEL = "dev.flow_widget/events"
        private const val UNSUPPORTED = "unsupported"
    }

    private lateinit var context: Context
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel

    private var storage: FlowWidgetStorage? = null
    private var imageStore: FlowWidgetImageStore? = null
    private var updater: FlowWidgetUpdater? = null
    private var eventSink: EventChannel.EventSink? = null
    private var initialized = false
    private var debugLogging = false

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        methodChannel = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL)
        eventChannel = EventChannel(binding.binaryMessenger, EVENT_CHANNEL)
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        eventSink = null
        disposeNative()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "initialize" -> handleInitialize(call, result)
                "dispose" -> handleDispose(result)
                "getCapabilities" -> result.success(FlowWidgetCapabilitiesProvider.getCapabilities())
                "getPlatformType" -> result.success("android")
                "getInstalledWidgets" -> ensureInitialized(result) {
                    result.success(requireUpdater().getInstalledWidgets())
                }
                "saveData" -> ensureInitialized(result) {
                    val key = call.argument<String>("key")
                        ?: return@ensureInitialized badArgs(result, "saveData requires key")
                    val value = call.argument<Map<String, Any?>>("value")
                        ?: return@ensureInitialized badArgs(result, "saveData requires value")
                    requireStorage().saveData(key, value, call.argument("groupId"))
                    result.success(null)
                }
                "saveBatch" -> ensureInitialized(result) {
                    val entries = call.argument<List<Map<String, Any?>>>("entries")
                        ?: return@ensureInitialized badArgs(result, "saveBatch requires entries")
                    requireStorage().saveBatch(entries, call.argument("groupId"))
                    result.success(null)
                }
                "getData" -> ensureInitialized(result) {
                    val key = call.argument<String>("key")
                        ?: return@ensureInitialized badArgs(result, "getData requires key")
                    result.success(requireStorage().getData(key, call.argument("groupId")))
                }
                "getAllData" -> ensureInitialized(result) {
                    val allData = requireStorage().getAllData(
                        prefix = call.argument("prefix"),
                        groupId = call.argument("groupId"),
                    )
                    result.success(allData)
                }
                "removeData" -> ensureInitialized(result) {
                    val key = call.argument<String>("key")
                        ?: return@ensureInitialized badArgs(result, "removeData requires key")
                    requireStorage().removeData(key, call.argument("groupId"))
                    result.success(null)
                }
                "clearData" -> ensureInitialized(result) {
                    requireStorage().clearData(call.argument("groupId"))
                    result.success(null)
                }
                "saveImage" -> ensureInitialized(result) {
                    val args = call.arguments as? Map<*, *>
                        ?: return@ensureInitialized badArgs(result, "saveImage requires arguments")
                    result.success(requireImageStore().saveImage(args))
                }
                "removeImage" -> ensureInitialized(result) {
                    val key = call.argument<String>("key")
                        ?: return@ensureInitialized badArgs(result, "removeImage requires key")
                    requireImageStore().removeImage(key)
                    result.success(null)
                }
                "update" -> ensureInitialized(result) {
                    val request = call.arguments as? Map<*, *>
                        ?: return@ensureInitialized badArgs(result, "update requires request")
                    requireUpdater().update(request)
                    result.success(null)
                }
                "updateMany" -> ensureInitialized(result) {
                    val requests = call.argument<List<Map<String, Any?>>>("requests")
                        ?: return@ensureInitialized badArgs(result, "updateMany requires requests")
                    requireUpdater().updateMany(requests)
                    result.success(null)
                }
                "updateAll" -> ensureInitialized(result) {
                    requireUpdater().updateAll()
                    result.success(null)
                }
                "setTimeline" -> ensureInitialized(result) {
                    val widgetId = call.argument<Map<String, Any?>>("widgetId")
                        ?: return@ensureInitialized badArgs(result, "setTimeline requires widgetId")
                    val entries = call.argument<List<Map<String, Any?>>>("entries")
                        ?: return@ensureInitialized badArgs(result, "setTimeline requires entries")
                    requireUpdater().setTimeline(widgetId, entries)
                    result.success(null)
                }
                "registerConfig" -> ensureInitialized(result) {
                    val config = call.arguments as? Map<*, *>
                        ?: return@ensureInitialized badArgs(result, "registerConfig requires config")
                    requireStorage().registerConfig(config)
                    result.success(null)
                }
                "requestPinWidget" -> ensureInitialized(result) {
                    val name = call.argument<String>("name")
                        ?: return@ensureInitialized badArgs(result, "requestPinWidget requires name")
                    val initialData = call.argument<Map<String, Any?>>("initialData")
                    val pinned = requireUpdater().requestPinWidget(name, initialData)
                    result.success(pinned)
                }
                "startLiveActivity",
                "updateLiveActivity",
                "endLiveActivity",
                "getActiveLiveActivities" -> unsupportedLiveActivity(result)
                else -> result.notImplemented()
            }
        } catch (error: IllegalArgumentException) {
            badArgs(result, error.message ?: "Invalid arguments")
        } catch (error: IllegalStateException) {
            result.error("error", error.message, null)
        } catch (error: Exception) {
            log("Method ${call.method} failed: ${error.message}")
            result.error("error", error.message, null)
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun emitEvent(event: Map<String, Any?>) {
        val sink = eventSink ?: return
        Handler(Looper.getMainLooper()).post { sink.success(event) }
    }

    private fun handleInitialize(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments as? Map<*, *> ?: emptyMap<Any?, Any?>()
        val androidPrefs = args["androidPrefs"] as? String
        val appGroupId = args["appGroupId"] as? String
        // Android prefs are independent of iOS/macOS appGroupId. Never fall back
        // to appGroupId — that silently mismatches native FlowWidgetStorage.create.
        val prefsName = androidPrefs ?: FlowWidgetStorage.DEFAULT_PREFS_NAME
        val useGlance = args["useGlance"] as? Boolean ?: true
        val maxCache = (args["imageCacheMaxBytes"] as? Number)?.toLong() ?: 20L * 1024L * 1024L
        debugLogging = args["enableDebugLogging"] == true

        if (androidPrefs.isNullOrEmpty() && !appGroupId.isNullOrEmpty()) {
            android.util.Log.w(
                "FlowWidgetPlugin",
                "androidNamedSharedPreferences was null; using " +
                    "\"${FlowWidgetStorage.DEFAULT_PREFS_NAME}\". appGroupId " +
                    "(\"$appGroupId\") is iOS/macOS-only and is not used as the " +
                    "Android SharedPreferences name. Pass the same name to " +
                    "FlowWidgetStorage.create in your Glance/RemoteViews code.",
            )
        }

        storage = FlowWidgetStorage.create(context, prefsName)
        imageStore = FlowWidgetImageStore(context, maxCache)
        updater = FlowWidgetUpdater(context, requireStorage(), useGlance = useGlance)
        initialized = true
        log("Initialized with prefs=$prefsName useGlance=$useGlance")
        result.success(null)
    }

    private fun handleDispose(result: MethodChannel.Result) {
        disposeNative()
        result.success(null)
    }

    private fun disposeNative() {
        imageStore?.clear()
        storage = null
        imageStore = null
        updater = null
        initialized = false
    }

    private fun ensureInitialized(result: MethodChannel.Result, block: () -> Unit) {
        if (!initialized) {
            result.error("not_initialized", "Call initialize() before other methods", null)
            return
        }
        block()
    }

    private fun unsupportedLiveActivity(result: MethodChannel.Result) {
        result.error(
            UNSUPPORTED,
            "Live Activities are not supported on Android",
            null,
        )
    }

    private fun badArgs(result: MethodChannel.Result, message: String) {
        result.error("bad_args", message, null)
    }

    private fun requireStorage(): FlowWidgetStorage {
        return storage ?: throw IllegalStateException("Storage not initialized")
    }

    private fun requireImageStore(): FlowWidgetImageStore {
        return imageStore ?: throw IllegalStateException("Image store not initialized")
    }

    private fun requireUpdater(): FlowWidgetUpdater {
        return updater ?: throw IllegalStateException("Updater not initialized")
    }

    private fun log(message: String) {
        if (debugLogging) {
            android.util.Log.d("FlowWidgetPlugin", message)
        }
    }
}
