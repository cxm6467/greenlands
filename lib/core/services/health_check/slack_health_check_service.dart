import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import 'health_check_result.dart';
import 'health_check_service.dart';

/// Health check service for Slack bot tokens
class SlackHealthCheckService extends HealthCheckService {
  final Dio _dio;
  final Logger _logger;

  SlackHealthCheckService({required Dio dio, required Logger logger})
    : _dio = dio,
      _logger = logger;

  @override
  String get serviceName => 'Slack Bot';

  @override
  Future<HealthCheckResult> validateFormat(String token) async {
    try {
      if (token.isEmpty) {
        return HealthCheckResult.invalidFormat(
          'Bot token is required',
          details: 'Please provide your Slack bot token',
        );
      }

      // Slack bot tokens start with xoxb-
      if (!token.startsWith('xoxb-')) {
        return HealthCheckResult.invalidFormat(
          'Invalid token format',
          details:
              'Slack bot tokens should start with xoxb-. Get your token at api.slack.com',
        );
      }

      // Check length (Slack tokens are typically quite long)
      if (token.length < 50) {
        return HealthCheckResult.invalidFormat(
          'Token appears too short',
          details: 'Slack bot tokens are typically longer than 50 characters',
        );
      }

      _logger.d('Slack bot token format validation passed');
      return HealthCheckResult.valid(
        'Token format is valid',
        details: 'Ready to test connection',
      );
    } catch (e) {
      _logger.e('Error validating Slack token format: $e');
      return HealthCheckResult.invalidFormat(
        'Validation error',
        details: e.toString(),
      );
    }
  }

  @override
  Future<HealthCheckResult> testConnectivity(
    String token, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      _logger.i('Testing Slack app connectivity...');

      // Use auth.test to verify the token
      final response = await _dio
          .post(
            'https://slack.com/api/auth.test',
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/x-www-form-urlencoded',
              },
            ),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final ok = data['ok'] as bool? ?? false;

        if (ok) {
          final teamName = data['team'] as String?;
          _logger.i('Slack app connectivity test successful: $teamName');
          return HealthCheckResult.valid(
            'Connection successful',
            details: teamName != null
                ? 'Connected to: $teamName'
                : 'App token is valid',
          );
        } else {
          final error = data['error'] as String? ?? 'Unknown error';
          _logger.w('Slack API returned error: $error');

          if (error == 'invalid_auth' || error == 'token_revoked') {
            return HealthCheckResult.connectivityFailed(
              'Invalid token',
              details: 'The token was rejected: $error',
            );
          }

          return HealthCheckResult.connectivityFailed(
            'Authentication failed',
            details: error,
          );
        }
      } else {
        _logger.w(
          'Slack API returned unexpected status: ${response.statusCode}',
        );
        return HealthCheckResult.warning(
          'Unexpected response',
          details: 'Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _logger.e('Slack app connectivity test failed: ${e.message}');

      if (e.response?.statusCode == 429) {
        return HealthCheckResult.warning(
          'Rate limit exceeded',
          details:
              'Too many requests. The token appears valid but is rate limited.',
        );
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return HealthCheckResult.connectivityFailed(
          'Connection timeout',
          details:
              'Could not reach slack.com within ${timeout.inSeconds} seconds',
        );
      }

      if (e.type == DioExceptionType.connectionError) {
        return HealthCheckResult.connectivityFailed(
          'Connection error',
          details:
              'Could not connect to slack.com. Check your internet connection.',
        );
      }

      return HealthCheckResult.connectivityFailed(
        'Connection failed',
        details: e.message ?? 'Unknown error',
      );
    } catch (e) {
      _logger.e('Unexpected error testing Slack app: $e');
      return HealthCheckResult.connectivityFailed(
        'Unexpected error',
        details: e.toString(),
      );
    }
  }

  @override
  Future<HealthCheckResult> validatePermissions(String token) async {
    try {
      _logger.i('Validating Slack app permissions...');

      // Use auth.test to get token info including scopes
      final response = await _dio.post(
        'https://slack.com/api/auth.test',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final ok = data['ok'] as bool? ?? false;

        if (ok) {
          // Note: auth.test doesn't return scopes directly
          // We'd need to call auth.scopes or users.info for full scope checking
          // For now, we'll assume if auth.test works, basic permissions are OK
          _logger.i('Slack app permissions appear valid');
          return HealthCheckResult.valid(
            'Token is valid',
            details:
                'Ensure the app has chat:write and other required scopes in your Slack app settings',
          );
        } else {
          final error = data['error'] as String? ?? 'Unknown error';
          return HealthCheckResult.invalid(
            'Permission check failed',
            details: error,
          );
        }
      } else {
        return HealthCheckResult.warning(
          'Could not verify permissions',
          details: 'Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _logger.e('Slack app permission validation failed: ${e.message}');

      // If we can't check permissions, but connectivity worked, return a warning
      return HealthCheckResult.warning(
        'Could not verify permissions',
        details:
            'The token works but permissions could not be verified. Ensure the app has chat:write scope.',
      );
    } catch (e) {
      _logger.e('Unexpected error validating Slack app permissions: $e');
      return HealthCheckResult.warning(
        'Permission check failed',
        details: e.toString(),
      );
    }
  }
}
