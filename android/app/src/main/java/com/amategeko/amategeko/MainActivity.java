package com.amategeko.amategeko;

import android.content.Intent;
import android.os.Bundle;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(new FlutterEngine(this));

        // Handle the deep link when the app is launched from a link
        handleDeepLink(getIntent());
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        // Handle the deep link when the app is already running and a new link is clicked
        handleDeepLink(intent);
    }

    private void handleDeepLink(Intent intent) {
        if (Intent.ACTION_VIEW.equals(intent.getAction())) {
            // Get the deep link URL
            String dataString = intent.getDataString();
            if (dataString != null) {
                // Send the deep link URL to Flutter
                getFlutterEngine().getNavigationChannel().pushRoute(dataString);
            }
        }
    }
}
