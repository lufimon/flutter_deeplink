package com.quantam.deeplink

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** DeeplinkPlugin */
class DeeplinkPlugin :
        FlutterPlugin,
        MethodCallHandler,
        EventChannel.StreamHandler,
        ActivityAware,
        PluginRegistry.NewIntentListener {

    private val MESSAGES_CHANNEL = "com.quantam.deeplink/messages";
    private val EVENTS_CHANNEL = "com.quantam.deeplink/events";

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null

    private var mainActivity: Activity? = null

    private var initialLink: String? = null
    private var latestLink: String? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, MESSAGES_CHANNEL)
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, EVENTS_CHANNEL)
        eventChannel.setStreamHandler(this);
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method.equals("getLatestAppLink")) {
            result.success(latestLink);
        } else if (call.method.equals("getInitialAppLink")) {
            result.success(initialLink);
        } else {
            result.notImplemented();
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)

        initialLink = null
        latestLink = null
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        this.eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        this.eventSink = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        binding.addOnNewIntentListener(this)
        this.mainActivity = binding.activity
        if(mainActivity?.intent == null) {
            return
        }
        val flag = Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY
        if (mainActivity!!.intent.flags and flag != flag) {
            onNewIntent(mainActivity!!.intent)
            mainActivity?.intent?.replaceExtras(Bundle())
            mainActivity?.intent?.action = ""
            mainActivity?.intent?.data = null
            mainActivity?.intent?.flags = 0
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        this.mainActivity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        binding.addOnNewIntentListener(this)
        this.mainActivity = binding.activity
    }

    override fun onDetachedFromActivity() {
        this.mainActivity = null
    }

    override fun onNewIntent(intent: Intent): Boolean {
        if(handleIntent(intent)) {
            mainActivity?.intent = intent
            return true
        }
        return false
    }

    private fun handleIntent(intent: Intent?): Boolean {
        if (intent == null) {
            return false
        }
        val dataString: String? = DeeplinkHelper.getDeepLinkFromIntent(intent)
        if (dataString != null) {
            if (initialLink == null) {
                initialLink = dataString
            }
            latestLink = dataString
            if (eventSink != null) eventSink!!.success(dataString)
            return true
        }
        return false
    }
}
