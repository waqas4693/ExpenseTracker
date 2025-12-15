import 'package:flutter/material.dart';

class NumericKeypad extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback? onBackspace;
  final VoidCallback? onDone;

  const NumericKeypad({
    super.key,
    required this.onKeyPressed,
    this.onBackspace,
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top numeric row (1, 2, 3)
          Row(
            children: [
              _buildKey('1', onKeyPressed),
              _buildKey('2', onKeyPressed),
              _buildKey('3', onKeyPressed),
            ],
          ),
          // Full QWERTY keyboard would go here
          // For now, we'll show a simplified numeric keypad
          Row(
            children: [
              _buildKey('4', onKeyPressed),
              _buildKey('5', onKeyPressed),
              _buildKey('6', onKeyPressed),
            ],
          ),
          Row(
            children: [
              _buildKey('7', onKeyPressed),
              _buildKey('8', onKeyPressed),
              _buildKey('9', onKeyPressed),
            ],
          ),
          Row(
            children: [
              _buildKey('.', onKeyPressed),
              _buildKey('0', onKeyPressed),
              _buildActionKey(icon: Icons.backspace, onTap: onBackspace),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String value, Function(String) onPressed) {
    return Expanded(
      child: InkWell(
        onTap: () => onPressed(value),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey({required IconData icon, VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Center(child: Icon(icon, color: const Color(0xFF1A1A1A))),
        ),
      ),
    );
  }
}
