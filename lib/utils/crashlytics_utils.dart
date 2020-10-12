import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

var notWebVersion = !kIsWeb;

Future<void> initializeCrashlytics() async {

  //Crashlytics for Flutter is not working on the web for now
  if (notWebVersion) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    // Pass all uncaught errors to Crashlytics.
    Function originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails errorDetails) async {
      await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      // Forward to original handler.
      originalOnError(errorDetails);
    };
  }

}

logException(Exception e) {
  if (notWebVersion) {
    FirebaseCrashlytics.instance.log(e.toString());
  }

}

logMessage(String msg) {
  FirebaseCrashlytics.instance.log(msg);
}