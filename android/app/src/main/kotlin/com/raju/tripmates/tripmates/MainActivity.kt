package com.raju.tripmates.tripmates

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.raju.tripmates/deeplink"
    private var deepLinkUri: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialLink" -> {
                    val link = getInitialDeepLink()
                    result.success(link)
                }
                else -> result.notImplemented()
            }
        }

        // Handle initial intent if it contains a deep link
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent) {
        val action = intent.action
        val data = intent.data

        if (action == Intent.ACTION_VIEW && data != null) {
            deepLinkUri = data.toString()

            // Send the deep link to Flutter
            flutterEngine?.let { engine ->
                val channel = MethodChannel(
                    engine.dartExecutor.binaryMessenger,
                    CHANNEL
                )
                channel.invokeMethod("onDeepLink", deepLinkUri)
            }
        }
    }

    private fun getInitialDeepLink(): String? {
        val intent = intent
        val action = intent?.action
        val data = intent?.data

        if (action == Intent.ACTION_VIEW && data != null) {
            deepLinkUri = data.toString()
            return deepLinkUri
        }

        return null
    }
}

