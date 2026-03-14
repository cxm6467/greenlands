import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import 'health_check_result.dart';
import 'health_check_service.dart';

/// Health check service for Google Chat webhooks
class GoogleChatHealthCheckService extends HealthCheckService {
  final Dio _dio;
  final Logger _logger;

  GoogleChatHealthCheckService({required Dio dio, required Logger logger})
    : _dio = dio,
      _logger = logger;

  @override
  String get serviceName => 'Google Chat';

  @override
  Future<HealthCheckResult> validateFormat(String webhookUrl) async {
    try {
      if (webhookUrl.isEmpty) {
        return HealthCheckResult.invalidFormat(
          'Webhook URL is required',
          details: 'Please provide your Google Chat webhook URL',
        );
      }

      // Parse URL
      Uri? uri;
      try {
        uri = Uri.parse(webhookUrl);
      } catch (e) {
        return HealthCheckResult.invalidFormat(
          'Invalid URL format',
          details: 'Could not parse URL: $e',
        );
      }

      // Check protocol
      if (uri.scheme != 'https') {
        return HealthCheckResult.invalidFormat(
          'Invalid URL protocol',
          details: 'Google Chat webhooks must use HTTPS',
        );
      }

      // Check host
      if (uri.host != 'chat.googleapis.com') {
        return HealthCheckResult.invalidFormat(
          'Invalid webhook host',
          details:
              'Google Chat webhooks should use chat.googleapis.com. Got: ${uri.host}',
        );
      }

      // Check path structure
      if (!uri.path.startsWith('/v1/spaces/')) {
        return HealthCheckResult.invalidFormat(
          'Invalid webhook path',
          details:
              'Google Chat webhooks should have path starting with /v1/spaces/',
        );
      }

      _logger.d('Google Chat webhook URL format validation passed');
      return HealthCheckResult.valid(
        'Webhook URL format is valid',
        details: 'Ready to test connection',
      );
    } catch (e) {
      _logger.e('Error validating Google Chat webhook format: $e');
      return HealthCheckResult.invalidFormat(
        'Validation error',
        details: e.toString(),
      );
    }
  }

  @override
  Future<HealthCheckResult> testConnectivity(
    String webhookUrl, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      _logger.i('Testing Google Chat webhook connectivity...');

      // Send a test message to the webhook
      final response = await _dio
          .post(
            webhookUrl,
            options: Options(headers: {'Content-Type': 'application/json'}),
            data: {
              'text': '🏰 The Greenlands setup wizard - connection test ✓',
            },
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        _logger.i('Google Chat webhook connectivity test successful');
        return HealthCheckResult.valid(
          'Connection successful',
          details: 'Test message sent to chat space',
        );
      } else {
        _logger.w(
          'Google Chat API returned unexpected status: ${response.statusCode}',
        );
        return HealthCheckResult.warning(
          'Unexpected response',
          details: 'Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _logger.e('Google Chat webhook connectivity test failed: ${e.message}');

      if (e.response?.statusCode == 400) {
        return HealthCheckResult.connectivityFailed(
          'Invalid webhook',
          details:
              'The webhook URL was rejected. Please check your webhook configuration.',
        );
      }

      if (e.response?.statusCode == 404) {
        return HealthCheckResult.connectivityFailed(
          'Webhook not found',
          details:
              'The webhook URL does not exist. Please verify the URL in Google Chat settings.',
        );
      }

      if (e.response?.statusCode == 429) {
        return HealthCheckResult.warning(
          'Rate limit exceeded',
          details:
              'Too many requests. The webhook appears valid but is rate limited.',
        );
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return HealthCheckResult.connectivityFailed(
          'Connection timeout',
          details:
              'Could not reach chat.googleapis.com within ${timeout.inSeconds} seconds',
        );
      }

      if (e.type == DioExceptionType.connectionError) {
        return HealthCheckResult.connectivityFailed(
          'Connection error',
          details:
              'Could not connect to chat.googleapis.com. Check your internet connection.',
        );
      }

      return HealthCheckResult.connectivityFailed(
        'Connection failed',
        details: e.message ?? 'Unknown error',
      );
    } catch (e) {
      _logger.e('Unexpected error testing Google Chat webhook: $e');
      return HealthCheckResult.connectivityFailed(
        'Unexpected error',
        details: e.toString(),
      );
    }
  }

  @override
  Future<HealthCheckResult> validatePermissions(String webhookUrl) async {
    // Webhooks don't have permission scopes - if the webhook works, it has permissions
    _logger.d('Google Chat webhooks have implicit permissions');
    return HealthCheckResult.valid(
      'Permissions validated',
      details:
          'Google Chat incoming webhooks inherit space permissions; no additional permission scopes are required.',
    );
  }
}
