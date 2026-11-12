import 'package:flutter/material.dart';

import '../services/api_sync.dart';

class ConnectionErrorScreen extends StatefulWidget {
  const ConnectionErrorScreen({super.key});

  @override
  State<ConnectionErrorScreen> createState() => _ConnectionErrorScreenState();
}

class _ConnectionErrorScreenState extends State<ConnectionErrorScreen> {
  bool _retrying = false;

  Future<void> _retry() async {
    setState(() => _retrying = true);
    await ApiSync().refresh();
    if (mounted) setState(() => _retrying = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F4),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(color: Color(0xFFFDEBEE), shape: BoxShape.circle),
                    child: const Icon(Icons.wifi_off_rounded, size: 44, color: Color(0xFFC4202F)),
                  ),
                  const SizedBox(height: 22),
                  const Text('No internet connection', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF241D1A))),
                  const SizedBox(height: 8),
                  Text(
                    'Foodie cannot reach the kitchen right now. Check your connection or make sure the API server is running, then try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, height: 1.5, color: Colors.brown.shade400),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _retrying ? null : _retry,
                      icon: _retrying ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.refresh_rounded),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(_retrying ? 'Connecting...' : 'Try again'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => ApiSync.connection.value = ApiConnection.online,
                    child: const Text('Continue with saved menu'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}