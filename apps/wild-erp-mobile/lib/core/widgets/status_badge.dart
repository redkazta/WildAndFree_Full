import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum BadgeType { success, warning, error, info, neutral }

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;
  final bool small;

  const StatusBadge({
    super.key,
    required this.label,
    this.type = BadgeType.neutral,
    this.small = false,
  });

  factory StatusBadge.fromStatus(String status) {
    final normalized = status.toLowerCase().replaceAll('_', ' ');
    BadgeType type;

    if (['approved', 'paid', 'delivered', 'completed', 'active', 'verified', 'approved']
        .any((s) => normalized.contains(s))) {
      type = BadgeType.success;
    } else if (['pending', 'processing', 'in review', 'in_progress']
        .any((s) => normalized.contains(s))) {
      type = BadgeType.warning;
    } else if (['rejected', 'cancelled', 'refunded', 'error', 'suspended']
        .any((s) => normalized.contains(s))) {
      type = BadgeType.error;
    } else if (['shipped', 'in transit', 'reviewed'].any((s) => normalized.contains(s))) {
      type = BadgeType.info;
    } else {
      type = BadgeType.neutral;
    }

    return StatusBadge(label: status.toUpperCase(), type: type, small: true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 3 : 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.$1.withAlpha(25),
            colors.$1.withAlpha(10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.$1.withAlpha(60)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.$1,
          fontSize: small ? 10 : 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  (Color, Color) _getColors() {
    switch (type) {
      case BadgeType.success:
        return (AppTheme.accent, Colors.black);
      case BadgeType.warning:
        return (AppTheme.primary, Colors.white);
      case BadgeType.error:
        return (AppTheme.error, Colors.white);
      case BadgeType.info:
        return (Colors.blue, Colors.white);
      case BadgeType.neutral:
        return (AppTheme.textSecondary, Colors.white);
    }
  }
}
