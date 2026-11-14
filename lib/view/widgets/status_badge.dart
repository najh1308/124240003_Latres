import 'package:flutter/material.dart';

Color statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'alive':
      return Colors.green;
    case 'dead':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

/// Titik berwarna + teks status (Alive / Dead / unknown)
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, this.filled = false});

  final String status;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    final dot = Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
    final text = Text(
      status,
      style: TextStyle(
        color: filled ? color : Colors.black87,
        fontWeight: filled ? FontWeight.bold : FontWeight.normal,
      ),
    );

    final row = Row(mainAxisSize: MainAxisSize.min, children: [
      dot,
      const SizedBox(width: 6),
      text,
    ]);

    if (!filled) return row;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: row,
    );
  }
}
