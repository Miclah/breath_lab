package com.example.breath_lab

import android.app.PictureInPictureParams
import android.content.res.Configuration
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Picture-in-picture during an active hold (PRD §A3). Flutter tells us via
 * [pipChannelName] whether entering PiP is currently allowed (hold active +
 * ambient PiP setting on); we enter it when the user leaves the app, and
 * report PiP mode changes back so Flutter can swap to the PiP-friendly
 * layout.
 */
class MainActivity : FlutterActivity() {
    private val pipChannelName = "com.example.breath_lab/pip"
    private var pipChannel: MethodChannel? = null
    private var pipEnabled = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        pipChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, pipChannelName)
        pipChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "setEnabled" -> {
                    pipEnabled = call.arguments as? Boolean ?: false
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        if (pipEnabled && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            enterPictureInPictureMode(PictureInPictureParams.Builder().build())
        }
    }

    override fun onPictureInPictureModeChanged(
        isInPictureInPictureMode: Boolean,
        newConfig: Configuration
    ) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        pipChannel?.invokeMethod("modeChanged", isInPictureInPictureMode)
    }
}
