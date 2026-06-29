import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkIndicator extends StatefulWidget {
  const NetworkIndicator({super.key});

  @override
  State<NetworkIndicator> createState() => _NetworkIndicatorState();
}

class _NetworkIndicatorState extends State<NetworkIndicator> {
  bool _isOffline = false;
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final isOffline = results.isEmpty || results.contains(ConnectivityResult.none);
      if (mounted) {
        setState(() {
          _isOffline = isOffline;
        });
      }
    });
    
    // Initial check
    _checkInitialStatus();
  }
  
  Future<void> _checkInitialStatus() async {
    final results = await Connectivity().checkConnectivity();
    final isOffline = results.isEmpty || results.contains(ConnectivityResult.none);
    if (mounted) {
      setState(() {
        _isOffline = isOffline;
      });
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOffline) return const SizedBox.shrink();

    return Container(
      color: Colors.red.shade600,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text(
            'Offline Mode - Changes will sync when connected',
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
