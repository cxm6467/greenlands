import 'health_check_result.dart';

/// Abstract interface for health check services that validate API credentials
/// and test connectivity to external services
abstract class HealthCheckService {
  /// Fast format validation (e.g., API key format, URL structure)
  ///
  /// This should be a quick, synchronous check that doesn't require network calls.
  /// Examples:
  /// - Check if API key starts with expected prefix
  /// - Validate URL format and structure
  /// - Check length requirements
  Future<HealthCheckResult> validateFormat(String value);

  /// Network connectivity test (actual API call)
  ///
  /// Makes a real API call to verify the credentials work. Should use minimal
  /// resources (small request) and respect the timeout.
  ///
  /// [value] - The credential or URL to test
  /// [timeout] - Maximum time to wait for response (default: 10 seconds)
  Future<HealthCheckResult> testConnectivity(
    String value, {
    Duration timeout = const Duration(seconds: 10),
  });

  /// Permission/scope validation (token capabilities)
  ///
  /// Checks if the provided token has the necessary permissions or scopes
  /// required for the features we need.
  ///
  /// For some services (like Claude), permissions are implicit and this
  /// will return the same result as testConnectivity.
  Future<HealthCheckResult> validatePermissions(String value);

  /// Run all checks sequentially (format → connectivity → permissions)
  ///
  /// This is a convenience method that runs all checks in order, stopping
  /// at the first failure. Use this for comprehensive validation.
  Future<HealthCheckResult> runAllChecks(String value) async {
    // Step 1: Format validation
    final formatResult = await validateFormat(value);
    if (formatResult.status == HealthCheckStatus.invalid) {
      return formatResult;
    }

    // Step 2: Connectivity test
    try {
      final connectivityResult = await testConnectivity(value);
      if (connectivityResult.status == HealthCheckStatus.invalid) {
        return connectivityResult;
      }

      // Step 3: Permission validation
      final permissionsResult = await validatePermissions(value);
      return permissionsResult;
    } catch (e) {
      return HealthCheckResult.connectivityFailed(
        'Connection failed',
        details: e.toString(),
      );
    }
  }

  /// Get the service name for display purposes
  String get serviceName;
}
