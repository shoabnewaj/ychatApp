package com.ychat.app;

import android.content.Context;
import android.media.AudioManager;
import android.os.Build;
import android.os.Bundle;
import android.view.WindowManager;
import android.webkit.JavascriptInterface;
import android.webkit.PermissionRequest;
import android.webkit.WebChromeClient;
import com.getcapacitor.BridgeActivity;

public class MainActivity extends BridgeActivity {
    private AudioManager audioManager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);

        // Allow waking up screen over lockscreen for incoming calls
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true);
            setTurnScreenOn(true);
        } else {
            getWindow().addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED |
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON |
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD |
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            );
        }

        // Auto grant camera & microphone permissions to WebRTC in WebView
        if (this.bridge != null && this.bridge.getWebView() != null) {
            this.bridge.getWebView().setWebChromeClient(new WebChromeClient() {
                @Override
                public void onPermissionRequest(final PermissionRequest request) {
                    request.grant(request.getResources());
                }
            });

            // Native hardware audio bridge for earpiece vs loudspeaker call switching
            this.bridge.getWebView().addJavascriptInterface(new Object() {
                @JavascriptInterface
                public void setCallMode(boolean inCall) {
                    runOnUiThread(() -> {
                        if (audioManager != null) {
                            if (inCall) {
                                audioManager.setMode(AudioManager.MODE_IN_COMMUNICATION);
                            } else {
                                audioManager.setMode(AudioManager.MODE_NORMAL);
                                audioManager.setSpeakerphoneOn(false);
                            }
                        }
                    });
                }

                @JavascriptInterface
                public void setSpeakerphoneOn(boolean on) {
                    runOnUiThread(() -> {
                        if (audioManager != null) {
                            audioManager.setMode(AudioManager.MODE_IN_COMMUNICATION);
                            audioManager.setSpeakerphoneOn(on);
                        }
                    });
                }

                @JavascriptInterface
                public boolean isSpeakerphoneOn() {
                    return audioManager != null && audioManager.isSpeakerphoneOn();
                }
            }, "AndroidApp");
        }
    }
}
