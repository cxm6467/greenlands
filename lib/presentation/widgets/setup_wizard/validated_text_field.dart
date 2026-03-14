import 'package:flutter/material.dart';

import '../../../core/config/theme_config.dart';
import '../../../core/services/health_check/health_check_result.dart';
import 'health_check_indicator.dart';

/// Text field with integrated health check functionality
class ValidatedTextField extends StatefulWidget {
  final String label;
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;
  final bool obscureText;
  final TextInputType keyboardType;
  final HealthCheckResult? healthCheckResult;
  final VoidCallback? onRunHealthCheck;
  final bool isCheckingHealth;
  final bool showHealthCheck;
  final int? maxLines;

  const ValidatedTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.healthCheckResult,
    this.onRunHealthCheck,
    required this.isCheckingHealth,
    this.showHealthCheck = false,
    this.maxLines = 1,
  });

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(ValidatedTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            border: const OutlineInputBorder(),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: GreenlandsTheme.borderColor),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: GreenlandsTheme.accentGold,
                width: 2,
              ),
            ),
          ),
          onChanged: widget.onChanged,
        ),
        if (widget.showHealthCheck && widget.value.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: widget.isCheckingHealth
                    ? null
                    : widget.onRunHealthCheck,
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label: const Text('Test Connection'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  side: const BorderSide(color: GreenlandsTheme.accentGold),
                  foregroundColor: GreenlandsTheme.accentGold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: HealthCheckIndicator(
                  result: widget.healthCheckResult,
                  isChecking: widget.isCheckingHealth,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
