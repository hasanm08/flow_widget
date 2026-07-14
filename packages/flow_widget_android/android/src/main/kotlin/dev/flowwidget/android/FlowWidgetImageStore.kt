package dev.flowwidget.android

import android.content.Context
import java.io.File
import java.net.HttpURLConnection
import java.net.URL
import java.util.Locale

/**
 * Persists widget images under `filesDir/flow_widget_images/`.
 */
class FlowWidgetImageStore(
    private val context: Context,
    private val maxCacheBytes: Long,
) {
    companion object {
        private const val DIRECTORY_NAME = "flow_widget_images"
    }

    private val imageDirectory: File by lazy {
        File(context.filesDir, DIRECTORY_NAME).apply { mkdirs() }
    }

    fun saveImage(args: Map<*, *>): String {
        val key = args["key"] as? String
            ?: throw IllegalArgumentException("saveImage requires key")
        val mimeType = (args["mimeType"] as? String) ?: "image/png"
        val extension = extensionForMimeType(mimeType)
        val target = File(imageDirectory, sanitizeKey(key) + extension)

        val bytes = args["bytes"]
        if (bytes != null) {
            val payload = toByteArray(bytes)
            enforceCacheLimit(payload.size.toLong())
            target.writeBytes(payload)
            return target.absolutePath
        }

        val url = args["url"] as? String
            ?: throw IllegalArgumentException("saveImage requires bytes or url")
        val downloaded = download(url)
        enforceCacheLimit(downloaded.size.toLong())
        target.writeBytes(downloaded)
        return target.absolutePath
    }

    fun removeImage(key: String) {
        val prefix = sanitizeKey(key)
        imageDirectory.listFiles()?.forEach { file ->
            if (file.name.startsWith(prefix)) {
                file.delete()
            }
        }
    }

    fun clear() {
        imageDirectory.listFiles()?.forEach { it.delete() }
    }

    private fun enforceCacheLimit(incomingBytes: Long) {
        val files = imageDirectory.listFiles()?.toList().orEmpty()
        var total = files.sumOf { it.length() } + incomingBytes
        if (total <= maxCacheBytes) return

        val sorted = files.sortedBy { it.lastModified() }
        for (file in sorted) {
            if (total <= maxCacheBytes) break
            total -= file.length()
            file.delete()
        }
    }

    private fun download(urlString: String): ByteArray {
        val connection = (URL(urlString).openConnection() as HttpURLConnection).apply {
            connectTimeout = 15_000
            readTimeout = 15_000
            requestMethod = "GET"
        }
        return connection.inputStream.use { stream -> stream.readBytes() }
    }

    private fun toByteArray(value: Any): ByteArray {
        return when (value) {
            is ByteArray -> value
            is List<*> -> ByteArray(value.size) { index ->
                (value[index] as Number).toInt().toByte()
            }
            else -> throw IllegalArgumentException("Unsupported byte payload type")
        }
    }

    private fun sanitizeKey(key: String): String {
        return key.replace(Regex("[^a-zA-Z0-9._-]"), "_")
    }

    private fun extensionForMimeType(mimeType: String): String {
        return when (mimeType.lowercase(Locale.US)) {
            "image/jpeg", "image/jpg" -> ".jpg"
            "image/webp" -> ".webp"
            "image/gif" -> ".gif"
            else -> ".png"
        }
    }
}
