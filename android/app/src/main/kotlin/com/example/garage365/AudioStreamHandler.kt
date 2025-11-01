// android/app/src/main/kotlin/com/example/garage365/AudioStreamHandler.kt
package com.example.garage365

import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import io.flutter.plugin.common.EventChannel

class AudioStreamHandler : EventChannel.StreamHandler {

    private var recorder: AudioRecord? = null
    private var handlerThread: HandlerThread? = null
    private var bgHandler: Handler? = null
    private val uiHandler = Handler(Looper.getMainLooper())
    private var isRecording = false

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        if (isRecording) return

        val sampleRate = 16000
        val channelConfig = AudioFormat.CHANNEL_IN_MONO
        val audioFormat = AudioFormat.ENCODING_PCM_16BIT

        val minBuf = AudioRecord.getMinBufferSize(sampleRate, channelConfig, audioFormat)
        val bufferSize = minBuf * 2

        recorder = AudioRecord(
            MediaRecorder.AudioSource.MIC,
            sampleRate,
            channelConfig,
            audioFormat,
            bufferSize
        )

        handlerThread = HandlerThread("garage365-audio").also { thread ->
            thread.start()
            bgHandler = Handler(thread.looper)
        }

        isRecording = true
        recorder?.startRecording()

        // loop de lectura
        bgHandler?.post(object : Runnable {
            override fun run() {
                val rec = recorder ?: return
                if (!isRecording) return

                val buf = ByteArray(bufferSize)
                val read = rec.read(buf, 0, buf.size)

                if (read > 0) {
                    // PCM_16BIT = 2 bytes por muestra → nos aseguramos que sea par
                    val even = if (read % 2 == 0) read else read - 1
                    if (even > 0) {
                        val out = buf.copyOf(even)
                        // MUY IMPORTANTE: mandar al main thread,
                        // si no → @UiThread must be executed on the main thread
                        uiHandler.post {
                            try {
                                events.success(out)
                            } catch (e: Exception) {
                                e.printStackTrace()
                            }
                        }
                    }
                }

                // volvemos a leer
                bgHandler?.post(this)
            }
        })
    }

    override fun onCancel(arguments: Any?) {
        isRecording = false
        recorder?.stop()
        recorder?.release()
        recorder = null

        handlerThread?.quitSafely()
        handlerThread = null
        bgHandler = null
    }
}
