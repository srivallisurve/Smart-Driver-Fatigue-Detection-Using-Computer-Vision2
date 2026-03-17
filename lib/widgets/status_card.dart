import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final String status;

  const StatusCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getBackgroundColor().withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _getEmoji(),
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 12),
          Text(
            status,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case 'SAFE':
        return Colors.green[700]!;
      case 'WARNING':
        return Colors.orange[700]!;
      case 'DROWSY':
        return Colors.red[700]!;
      case 'NO FACE':
        return Colors.grey[700]!;
      case 'ERROR':
        return Colors.purple[700]!;
      default:
        return Colors.grey[800]!;
    }
  }

  String _getEmoji() {
    switch (status) {
      case 'SAFE':
        return '🟢';
      case 'WARNING':
        return '🟡';
      case 'DROWSY':
        return '🔴';
      case 'NO FACE':
        return '👤';
      case 'ERROR':
        return '⚠️';
      default:
        return '⏳';
    }
  }
}
