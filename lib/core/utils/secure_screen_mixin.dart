import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

mixin SecureScreenMixin<T extends StatefulWidget> on State<T>, WidgetsBindingObserver {
  static const _channel = MethodChannel('com.example.trust_flow/secure');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _enableSecureScreen();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disableSecureScreen();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _enableSecureScreen();
    } else if (state == AppLifecycleState.resumed) {
      _enableSecureScreen();
    }
  }

  Future<void> _enableSecureScreen() async {
    try {
      await _channel.invokeMethod('enableSecure');
    } catch (_) {}
  }

  Future<void> _disableSecureScreen() async {
    try {
      await _channel.invokeMethod('disableSecure');
    } catch (_) {}
  }
}