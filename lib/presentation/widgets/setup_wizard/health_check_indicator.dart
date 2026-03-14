import 'package:flutter/material.dart';

import '../../../core/config/theme_config.dart';
import '../../../core/services/health_check/health_check_result.dart';

/// Widget that displays the status of a health check with appropriate icon and colors
class HealthCheckIndicator extends StatelessWidget {
  final HealthCheckResult? result;
  final bool isChecking;

  const HealthCheckIndicator({
    super.key,
    this.result,
    required this.isChecking,
  });

  @override
  Widget build(BuildContext context) {
    if (isChecking) {
      return Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                GreenlandsTheme.accentGold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Checking...',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: GreenlandsTheme.accentGold),
          ),
        ],
      );
    }

    if (result == null) {
      return const SizedBox.shrink();
    }

    // At this point, result is guaranteed to be non-null
    final healthResult = result!;

    IconData icon;
    Color color;
    switch (healthResult.status) {
      case HealthCheckStatus.valid:
        icon = Icons.check_circle;
        color = GreenlandsTheme.successGreen;
        break;
      case HealthCheckStatus.warning:
        icon = Icons.warning;
        color = GreenlandsTheme.accentGold;
        break;
      case HealthCheckStatus.invalid:
        icon = Icons.error;
        color = GreenlandsTheme.errorRed;
        break;
      case HealthCheckStatus.pending:
        icon = Icons.pending;
        color = GreenlandsTheme.textSecondary;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                healthResult.message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        if (healthResult.details != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              healthResult.details!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: GreenlandsTheme.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
