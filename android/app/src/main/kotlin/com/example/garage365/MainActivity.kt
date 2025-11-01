// android/app/src/main/kotlin/com/example/garage365/MainActivity.kt
package com.example.garage365

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // registramos el canal de audio
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "garage365/audio"
        ).setStreamHandler(AudioStreamHandler())

        // si tenés el del acelerómetro, lo registrás igual acá:
        // EventChannel(flutterEngine.dartExecutor.binaryMessenger, "garage365/accelerometer")
        //     .setStreamHandler(AccelStreamHandler())
    }
}
