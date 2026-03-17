import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;
import '../services/api_service.dart';
import '../widgets/status_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;
  html.VideoElement? _videoElement;
  html.CanvasElement? _canvasElement;
  bool _isInitialized = false;
  bool serverConnected = false;
  final String _viewId = 'webcam-view';

  double ear = 0.0;
  double mar = 0.0;
  int drowsyScore = 0;
  int frameCounter = 0;
  String status = 'INITIALIZING';

  @override
  void initState() {
    super.initState();
    _initWebCamera();
    _checkServer();
  }

  Future<void> _checkServer() async {
    bool connected = await ApiService.checkHealth();
    setState(() {
      serverConnected = connected;
    });
  }

  Future<void> _initWebCamera() async {
    _canvasElement = html.CanvasElement(
      width: 640,
      height: 480,
    );

    _videoElement = html.VideoElement()
      ..autoplay = true
      ..muted = true
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover';

    final mediaStream = await html.window.navigator
        .mediaDevices!
        .getUserMedia({'video': true, 'audio': false});

    _videoElement!.srcObject = mediaStream;
    await _videoElement!.play();

    // Register video element for HtmlElementView on web.
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) => _videoElement!,
    );

    setState(() {
      _isInitialized = true;
    });

    _startDetection();
  }

  void _startDetection() {
    _timer = Timer.periodic(
      const Duration(milliseconds: 500),
      (timer) async {
        await _captureAndDetect();
      },
    );
  }

  Future<void> _captureAndDetect() async {
    if (_videoElement == null || _canvasElement == null) return;

    try {
      final ctx = _canvasElement!.context2D;
      ctx.drawImageScaled(_videoElement!, 0, 0, 640, 480);

      final blob = await _canvasElement!.toBlob('image/jpeg', 0.8);
      final reader = html.FileReader();
      reader.readAsArrayBuffer(blob);

      await reader.onLoad.first;
      final bytes = reader.result as List<int>;

      final result = await ApiService.detectDrowsiness(
          Uint8List.fromList(bytes));

      setState(() {
        ear = (result['ear'] ?? 0.0).toDouble();
        mar = (result['mar'] ?? 0.0).toDouble();
        drowsyScore = result['drowsy_score'] ?? 0;
        frameCounter = result['frame_counter'] ?? 0;
        status = result['status'] ?? 'ERROR';
      });

      if (status == 'DROWSY') {
        await _audioPlayer.play(AssetSource('alarm.wav'));
      } else {
        await _audioPlayer.stop();
      }
    } catch (e) {
      setState(() {
        status = 'ERROR';
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          '🚗 Driver Drowsiness Detection',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              serverConnected ? Icons.wifi : Icons.wifi_off,
              color: serverConnected ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Live Camera Preview
          Expanded(
            flex: 3,
            child: _isInitialized
                ? Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getBorderColor(),
                        width: 3,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: HtmlElementView(
                        viewType: _viewId,
                      ),
                    ),
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.white,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Starting Camera...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
          ),

          // Stats Row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatBox('EAR', ear.toStringAsFixed(2)),
                _buildStatBox('MAR', mar.toStringAsFixed(2)),
                _buildStatBox('SCORE', drowsyScore.toString()),
                _buildStatBox('FRAMES', frameCounter.toString()),
              ],
            ),
          ),

          // Status Card
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 8.0),
            child: StatusCard(status: status),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Color _getBorderColor() {
    switch (status) {
      case 'SAFE':
        return Colors.green;
      case 'WARNING':
        return Colors.orange;
      case 'DROWSY':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}