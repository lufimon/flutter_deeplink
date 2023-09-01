package com.quantam.deeplink

import android.content.Intent
import android.content.Intent.ACTION_SEND
import android.net.Uri
import android.os.Parcel
import android.os.Parcelable
import android.util.Log

import org.microg.safeparcel.SafeParcelReader;


object DeeplinkHelper {
    private val FIREBASE_DYNAMIC_LINKS_DATA = "com.google.firebase.dynamiclinks.DYNAMIC_LINK_DATA"

    private val TAG = "com.quantam.deeplink"

    fun getDeepLinkFromIntent(intent: Intent): String? {
        val shortLink = getShortDeepLink(intent)
        if (shortLink != null) {
            Log.d(TAG, "handleIntent: (Data) (short deep link)$shortLink")
            return shortLink
        }
        return getUrl(intent)
    }

    private fun getShortDeepLink(intent: Intent): String? {
        val bytes = intent.getByteArrayExtra(FIREBASE_DYNAMIC_LINKS_DATA)
        if (bytes == null || bytes.isEmpty()) {
            return null
        }
        val parcel = Parcel.obtain()
        parcel.unmarshall(bytes, 0, bytes.size)
        parcel.setDataPosition(0)
        val header = parcel.readInt()
        return SafeParcelReader.readString(parcel, header)
    }

    private fun getUrl(intent: Intent): String? {
        val action = intent.action
        var dataString = intent.dataString
        if (ACTION_SEND == action) {
            val extras = intent.extras
            if (extras != null) {
                if (extras.containsKey(Intent.EXTRA_TEXT)) {
                    val charSeq = extras.getCharSequence(Intent.EXTRA_TEXT)
                    if (charSeq != null) {
                        dataString = charSeq.toString()
                    }
                } else if (extras.containsKey(Intent.EXTRA_STREAM)) {
                    val uri = extras.getParcelable<Parcelable>(Intent.EXTRA_STREAM) as Uri?
                    if (uri != null) {
                        dataString = uri.toString()
                    }
                }
            }
        }
        Log.d(TAG, "handleIntent: (Action) $action")
        Log.d(TAG, "handleIntent: (Data) $dataString")
        return dataString
    }
}