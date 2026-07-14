package dev.flowwidget.wear

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

/** Wear OS Tiles bridge for the flow_widget Method/Event channels. */
class FlowWidgetWearPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var context: Context? = null
    private var storage: FlowWidgetStorage? = null
    private var tileUpdater: FlowWidgetTileUpdater? = null
    private var eventSink: EventChannel.EventSink? = null
    private var prefsName: String = "flutter_flow_widget_wear"

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
        context = null
        storage = null
        tileUpdater = null
        eventSink = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> handleInitialize(call, result)
            "dispose" -> {
                storage = null
                tileUpdater = null
                result.success(null)
            }
            "getCapabilities" -> result.success(FlowWidgetCapabilitiesProvider.capabilities())
            "getPlatformType" -> result.success("wearOs")
            "getInstalledWidgets", "getActiveLiveActivities" -> result.success(emptyList<Any>())
            "saveData" -> handleSaveData(call, result)
            "saveBatch" -> handleSaveBatch(call, result)
            "getData" -> handleGetData(call, result)
            "getAllData" -> handleGetAllData(call, result)
            "removeData" -> handleRemoveData(call, result)
            "clearData" -> {
                requireStorage(result) { it.clear(); result.success(null) }
            }
            "saveImage" -> handleSaveImage(call, result)
            "removeImage" -> handleRemoveImage(call, result)
            "update" -> handleUpdate(call, result)
            "updateMany" -> handleUpdateMany(call, result)
            "updateAll" -> handleUpdateAll(result)
            "setTimeline" -> {
                storage?.setLastUpdate(System.currentTimeMillis())
                result.success(null)
            }
            "registerConfig" -> handleRegisterConfig(call, result)
            "requestPinWidget" -> result.success(false)
            "startLiveActivity", "updateLiveActivity", "endLiveActivity" ->
                result.error("unsupported", "Live Activities are not available on Wear OS.", null)
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private fun handleInitialize(call: MethodCall, result: MethodChannel.Result) {
        val ctx = context ?: run {
            result.error("no_context", "Application context unavailable.", null)
            return
        }
        prefsName = call.argument<String>("androidPrefs") ?: "flutter_flow_widget_wear"
        storage = FlowWidgetStorage(ctx, prefsName)
        tileUpdater = FlowWidgetTileUpdater(ctx)
        result.success(null)
    }

    private inline fun requireStorage(
        result: MethodChannel.Result,
        block: (FlowWidgetStorage) -> Unit,
    ) {
        val current = storage
        if (current == null) {
            result.error("not_initialized", "Call initialize() first.", null)
        } else {
            block(current)
        }
    }

    private fun handleSaveData(call: MethodCall, result: MethodChannel.Result) {
        val key = call.argument<String>("key")
        @Suppress("UNCHECKED_CAST")
        val wire = call.argument<Map<String, Any?>>("value")
        if (key == null || wire == null) {
            result.error("bad_args", "saveData requires key and value.", null)
            return
        }
        requireStorage(result) {
            it.save(key, wire)
            result.success(null)
        }
    }

    private fun handleSaveBatch(call: MethodCall, result: MethodChannel.Result) {
        @Suppress("UNCHECKED_CAST")
        val entries = call.argument<List<Map<String, Any?>>>("entries")
        if (entries == null) {
            result.error("bad_args", "saveBatch requires entries.", null)
            return
        }
        requireStorage(result) {
            it.saveBatch(entries)
            result.success(null)
        }
    }

    private fun handleGetData(call: MethodCall, result: MethodChannel.Result) {
        val key = call.argument<String>("key")
        if (key == null) {
            result.error("bad_args", "getData requires key.", null)
            return
        }
        requireStorage(result) {
            result.success(it.get(key))
        }
    }

    private fun handleGetAllData(call: MethodCall, result: MethodChannel.Result) {
        val prefix = call.argument<String>("prefix")
        requireStorage(result) {
            result.success(it.getAll(prefix))
        }
    }

    private fun handleRemoveData(call: MethodCall, result: MethodChannel.Result) {
        val key = call.argument<String>("key")
        if (key == null) {
            result.error("bad_args", "removeData requires key.", null)
            return
        }
        requireStorage(result) {
            it.remove(key)
            result.success(null)
        }
    }

    private fun handleSaveImage(call: MethodCall, result: MethodChannel.Result) {
        val ctx = context ?: run {
            result.error("no_context", "Application context unavailable.", null)
            return
        }
        val key = call.argument<String>("key")
        val bytes = call.argument<ByteArray>("bytes")
        if (key == null || bytes == null) {
            result.error("bad_args", "saveImage requires key and bytes.", null)
            return
        }
        val mimeType = call.argument<String>("mimeType") ?: "image/png"
        val ext = if (mimeType.contains("jpeg", ignoreCase = true)) "jpg" else "png"
        val dir = File(ctx.filesDir, "flow_widget_images").apply { mkdirs() }
        val file = File(dir, "$key.$ext")
        file.writeBytes(bytes)
        result.success(file.absolutePath)
    }

    private fun handleRemoveImage(call: MethodCall, result: MethodChannel.Result) {
        val ctx = context ?: run {
            result.error("no_context", "Application context unavailable.", null)
            return
        }
        val key = call.argument<String>("key")
        if (key == null) {
            result.error("bad_args", "removeImage requires key.", null)
            return
        }
        val dir = File(ctx.filesDir, "flow_widget_images")
        dir.listFiles()?.filter { it.nameWithoutExtension == key }?.forEach { it.delete() }
        result.success(null)
    }

    private fun handleUpdate(call: MethodCall, result: MethodChannel.Result) {
        val name = call.argument<String>("name")
        if (name == null) {
            result.error("bad_args", "update requires name.", null)
            return
        }
        requireStorage(result) { currentStorage ->
            @Suppress("UNCHECKED_CAST")
            val data = call.argument<Map<String, Any?>>("data")
            data?.forEach { (key, wire) ->
                @Suppress("UNCHECKED_CAST")
                currentStorage.save(key, wire as Map<String, Any?>)
            }
            currentStorage.setLastUpdate(System.currentTimeMillis())
            tileUpdater?.requestUpdateByName(name, currentStorage)
            result.success(null)
        }
    }

    private fun handleUpdateMany(call: MethodCall, result: MethodChannel.Result) {
        @Suppress("UNCHECKED_CAST")
        val requests = call.argument<List<Map<String, Any?>>>("requests")
        if (requests == null) {
            result.error("bad_args", "updateMany requires requests.", null)
            return
        }
        requireStorage(result) { currentStorage ->
            for (request in requests) {
                val name = request["name"] as? String ?: continue
                @Suppress("UNCHECKED_CAST")
                val data = request["data"] as? Map<String, Any?>
                data?.forEach { (key, wire) ->
                    @Suppress("UNCHECKED_CAST")
                    currentStorage.save(key, wire as Map<String, Any?>)
                }
                tileUpdater?.requestUpdateByName(name, currentStorage)
            }
            currentStorage.setLastUpdate(System.currentTimeMillis())
            result.success(null)
        }
    }

    private fun handleUpdateAll(result: MethodChannel.Result) {
        requireStorage(result) { currentStorage ->
            currentStorage.setLastUpdate(System.currentTimeMillis())
            tileUpdater?.requestUpdateAll(currentStorage)
            result.success(null)
        }
    }

    private fun handleRegisterConfig(call: MethodCall, result: MethodChannel.Result) {
        @Suppress("UNCHECKED_CAST")
        val config = call.arguments as? Map<String, Any?>
        if (config == null) {
            result.error("bad_args", "registerConfig requires config.", null)
            return
        }
        requireStorage(result) {
            it.registerConfig(config)
            result.success(null)
        }
    }

    companion object {
        private const val METHOD_CHANNEL = "dev.flow_widget/methods"
        private const val EVENT_CHANNEL = "dev.flow_widget/events"
    }
}
