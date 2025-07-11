// lib/presentation/widgets/targeted_debug_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class TargetedVpnDebugWidget extends StatefulWidget {
  const TargetedVpnDebugWidget({super.key});

  @override
  State<TargetedVpnDebugWidget> createState() => _TargetedVpnDebugWidgetState();
}

class _TargetedVpnDebugWidgetState extends State<TargetedVpnDebugWidget> {
  static const MethodChannel _channel = MethodChannel('aivpn');
  String _debugLog = '';
  bool _isDebugging = false;

  void _addLog(String message) {
    setState(() {
      _debugLog += '${DateTime.now().toString().substring(11, 19)}: $message\n';
    });
    print(message);
  }

  void _clearLog() {
    setState(() {
      _debugLog = '';
    });
  }

  Future<void> _testStep1_BasicConnection() async {
    _addLog('=== STEP 1: Testing Basic Platform Connection ===');

    try {
      final version = await _channel.invokeMethod('getPlatformVersion');
      _addLog('✅ Platform connection OK: $version');
    } catch (e) {
      _addLog('❌ Platform connection failed: $e');
    }
  }

  Future<void> _testStep2_InitializationOnly() async {
    _addLog('=== STEP 2: Testing VPN Manager Initialization Only ===');

    try {
      _addLog('🔄 Calling initializeVPNManager...');
      await _channel.invokeMethod('initializeVPNManager');
      _addLog('✅ initializeVPNManager completed without exception');

      // Check status after initialization
      await Future.delayed(const Duration(seconds: 1));
      final status = await _channel.invokeMethod('activeState');
      _addLog('📊 Status after initialization: $status');
    } catch (e) {
      _addLog('❌ Initialization failed: $e');
    }
  }

  Future<void> _testStep3_StatusMonitoring() async {
    _addLog('=== STEP 3: Testing Status Monitoring ===');

    // Set up listener for status changes
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'stateDidChangeNotification') {
        final arguments = call.arguments as Map<dynamic, dynamic>;
        final state = arguments['state'] as int;
        _addLog('📱 Status notification received: $state');
      }
    });

    _addLog('✅ Status listener set up');

    // Check current status multiple times
    for (int i = 0; i < 3; i++) {
      try {
        await Future.delayed(const Duration(seconds: 1));
        final status = await _channel.invokeMethod('activeState');
        _addLog('📊 Status check $i: $status');
      } catch (e) {
        _addLog('❌ Status check $i failed: $e');
      }
    }
  }

  Future<void> _testStep4_VpnPermissionCheck() async {
    _addLog('=== STEP 4: Testing VPN Permission (if available) ===');

    try {
      // Try to call a method that might reveal permission status
      // This might not exist in your BGVPNManager, but let's try
      final result = await _channel.invokeMethod('checkVPNPermission');
      _addLog('📊 VPN Permission check result: $result');
    } catch (e) {
      _addLog('⚠️ VPN Permission check not available: $e');
    }
  }

  Future<void> _testStep5_SimpleConfigTest() async {
    _addLog('=== STEP 5: Testing Config Parsing ===');

    const testVmess =
        'vmess://eyJhZGQiOiAiNS4xNjEuMTEwLjI0NyIsICJhaWQiOiAiMCIsICJob3N0IjogInFxLmNvbSIsICJpZCI6ICI0YWVhNjA2MS0wOWE0LTRmMjEtODgyNi03MGUyODJiNTI3OTEiLCAibmV0IjogInRjcCIsICJwYXRoIjogIi8iLCAicG9ydCI6IDgwODEsICJwcyI6ICJVU0EgMSIsICJzY3kiOiAiYXV0byIsICJ0bHMiOiAibm9uZSIsICJ0eXBlIjogImh0dHAiLCAidiI6ICIyIn0=';

    try {
      _addLog('🔄 Testing config parsing...');
      final result = await _channel.invokeMethod('parseURI', {
        'uri': testVmess,
      });
      _addLog('✅ Config parsing result: ${result?.length ?? 0} configurations');

      if (result != null && result.isNotEmpty) {
        final config = result[0] as Map;
        _addLog('📋 Config keys: ${config.keys.toList()}');
      }
    } catch (e) {
      _addLog('❌ Config parsing failed: $e');
    }
  }

  Future<void> _testStep6_MinimalConnect() async {
    _addLog(
      '=== STEP 6: Testing Minimal Connect (Watch for Permission Dialog) ===',
    );
    _addLog('⚠️ WATCH YOUR DEVICE - Permission dialog should appear now!');

    const testVmess =
        'vmess://eyJhZGQiOiAiNS4xNjEuMTEwLjI0NyIsICJhaWQiOiAiMCIsICJob3N0IjogInFxLmNvbSIsICJpZCI6ICI0YWVhNjA2MS0wOWE0LTRmMjEtODgyNi03MGUyODJiNTI3OTEiLCAibmV0IjogInRjcCIsICJwYXRoIjogIi8iLCAicG9ydCI6IDgwODEsICJwcyI6ICJVU0EgMSIsICJzY3kiOiAiYXV0byIsICJ0bHMiOiAibm9uZSIsICJ0eXBlIjogImh0dHAiLCAidiI6ICIyIn0=';

    try {
      // First ensure initialization
      _addLog('🔄 Ensuring VPN is initialized...');
      await _channel.invokeMethod('initializeVPNManager');
      await Future.delayed(const Duration(seconds: 1));

      final statusBefore = await _channel.invokeMethod('activeState');
      _addLog('📊 Status before connect: $statusBefore');

      _addLog('🔄 Calling connect method...');
      _addLog('👀 WATCH YOUR DEVICE FOR VPN PERMISSION DIALOG!');

      await _channel.invokeMethod('connect', {'uri': testVmess});
      _addLog('✅ Connect method call completed');

      // Monitor status changes for 10 seconds
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(seconds: 1));
        try {
          final status = await _channel.invokeMethod('activeState');
          _addLog('📊 Status $i seconds after connect: $status');

          if (status == 4 || status == -1) {
            _addLog('❌ Error status detected - connection failed');
            break;
          } else if (status == 2) {
            _addLog('✅ Connected successfully!');
            break;
          }
        } catch (e) {
          _addLog('❌ Error checking status: $e');
        }
      }
    } catch (e) {
      _addLog('❌ Connect test failed: $e');
    }
  }

  Future<void> _runFullDiagnostic() async {
    setState(() {
      _isDebugging = true;
      _debugLog = '';
    });

    try {
      await _testStep1_BasicConnection();
      await Future.delayed(const Duration(seconds: 1));

      await _testStep2_InitializationOnly();
      await Future.delayed(const Duration(seconds: 1));

      await _testStep3_StatusMonitoring();
      await Future.delayed(const Duration(seconds: 1));

      await _testStep4_VpnPermissionCheck();
      await Future.delayed(const Duration(seconds: 1));

      await _testStep5_SimpleConfigTest();
      await Future.delayed(const Duration(seconds: 1));

      _addLog('=== DIAGNOSTIC COMPLETE ===');
      _addLog('📋 Summary:');
      _addLog('- Check if any permission dialogs appeared');
      _addLog('- Check iOS device settings → VPN');
      _addLog('- Check Xcode console for additional logs');
    } finally {
      setState(() {
        _isDebugging = false;
      });
    }
  }

  Future<void> _testPermissionConnect() async {
    setState(() {
      _isDebugging = true;
    });

    try {
      await _testStep6_MinimalConnect();
    } finally {
      setState(() {
        _isDebugging = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[900]?.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.bug_report, color: Colors.red),
              const SizedBox(width: 8),
              const Text(
                'VPN Permission Debug',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _clearLog,
                icon: const Icon(Icons.clear, color: Colors.white70),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Important notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.5)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚠️ IMPORTANT INSTRUCTIONS:',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '1. Test on REAL iOS device (not simulator)\n'
                  '2. Watch for VPN permission dialog\n'
                  '3. Check iOS Settings → VPN after tests\n'
                  '4. Check Xcode console for detailed logs',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Test buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: _isDebugging ? null : _runFullDiagnostic,
                icon: const Icon(Icons.medical_services),
                label: const Text('Run Full Diagnostic'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isDebugging ? null : _testPermissionConnect,
                icon: const Icon(Icons.security),
                label: const Text('Test Permission Connect'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Debug log
          const Text(
            'Debug Log:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 300,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: SingleChildScrollView(
              child: Text(
                _debugLog.isEmpty ? 'No debug messages yet...' : _debugLog,
                style: const TextStyle(
                  color: Colors.green,
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
              ),
            ),
          ),

          // Loading indicator
          if (_isDebugging)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupertinoActivityIndicator(color: Colors.red),
                    SizedBox(width: 12),
                    Text(
                      'Running diagnostic tests...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
