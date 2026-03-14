/// Health check status indicating the result of validation/connectivity tests
enum HealthCheckStatus {
  /// All checks passed successfully
  valid,

  /// Checks passed with warnings (works but has issues)
  warning,

  /// Checks failed (invalid configuration)
  invalid,

  /// Check is pending or in progress
  pending,
}

/// Result of a health check operation containing status and diagnostic information
class HealthCheckResult {
  final HealthCheckStatus status;
  final String message;
  final String? details;
  final DateTime timestamp;

  /// Format validation result (fast, no network)
  final bool formatValid;

  /// Connectivity result (actual API call)
  final bool? connectivityValid;

  /// Permission result (token scopes check)
  final bool? permissionsValid;

  const HealthCheckResult({
    required this.status,
    required this.message,
    this.details,
    required this.timestamp,
    required this.formatValid,
    this.connectivityValid,
    this.permissionsValid,
  });

  /// Create a valid result
  factory HealthCheckResult.valid(String message, {String? details}) {
    return HealthCheckResult(
      status: HealthCheckStatus.valid,
      message: message,
      details: details,
      timestamp: DateTime.now(),
      formatValid: true,
      connectivityValid: true,
      permissionsValid: true,
    );
  }

  /// Create a warning result
  factory HealthCheckResult.warning(String message, {String? details}) {
    return HealthCheckResult(
      status: HealthCheckStatus.warning,
      message: message,
      details: details,
      timestamp: DateTime.now(),
      formatValid: true,
      connectivityValid: true,
      permissionsValid: false,
    );
  }

  /// Create an invalid result
  factory HealthCheckResult.invalid(String message, {String? details}) {
    return HealthCheckResult(
      status: HealthCheckStatus.invalid,
      message: message,
      details: details,
      timestamp: DateTime.now(),
      formatValid: false,
      connectivityValid: false,
      permissionsValid: false,
    );
  }

  /// Create a pending result
  factory HealthCheckResult.pending(String message) {
    return HealthCheckResult(
      status: HealthCheckStatus.pending,
      message: message,
      timestamp: DateTime.now(),
      formatValid: false,
      connectivityValid: null,
      permissionsValid: null,
    );
  }

  /// Create a format-only invalid result
  factory HealthCheckResult.invalidFormat(String message, {String? details}) {
    return HealthCheckResult(
      status: HealthCheckStatus.invalid,
      message: message,
      details: details,
      timestamp: DateTime.now(),
      formatValid: false,
      connectivityValid: null,
      permissionsValid: null,
    );
  }

  /// Create a connectivity-failed result (format was valid)
  factory HealthCheckResult.connectivityFailed(
    String message, {
    String? details,
  }) {
    return HealthCheckResult(
      status: HealthCheckStatus.invalid,
      message: message,
      details: details,
      timestamp: DateTime.now(),
      formatValid: true,
      connectivityValid: false,
      permissionsValid: null,
    );
  }

  @override
  String toString() {
    return 'HealthCheckResult(status: $status, message: $message, formatValid: $formatValid, connectivityValid: $connectivityValid, permissionsValid: $permissionsValid)';
  }
}
