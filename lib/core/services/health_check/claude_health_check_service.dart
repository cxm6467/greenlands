import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import 'health_check_result.dart';
import 'health_check_service.dart';

/// Health check service for Claude API (Anthropic)
class ClaudeHealthCheckService extends HealthCheckService {
  final Dio _dio;
  final Logger _logger;

  ClaudeHealthCheckService({required Dio dio, required Logger logger})
    : _dio = dio,
      _logger = logger;

  @override
  String get serviceName => 'Claude API';

  @override
  Future<HealthCheckResult> validateFormat(String apiKey) async {
    try {
      // Claude API keys should start with sk-ant-api03-
      if (apiKey.isEmpty) {
        return HealthCheckResult.invalidFormat(
          'API key is required',
          details: 'Please provide your Claude API key',
        );
      }

      if (!apiKey.startsWith('sk-ant-')) {
        return HealthCheckResult.invalidFormat(
          'Invalid API key format',
          details:
              'Claude API keys should start with sk-ant-. Get your key at console.anthropic.com',
        );
      }

      // Basic length check (Claude keys are typically quite long)
      if (apiKey.length < 50) {
        return HealthCheckResult.invalidFormat(
          'API key appears too short',
          details: 'Claude API keys are typically longer than 50 characters',
        );
      }

      _logger.d('Claude API key format validation passed');
      return HealthCheckResult.valid(
        'API key format is valid',
        details: 'Ready to test connection',
      );
    } catch (e) {
      _logger.e('Error validating Claude API key format: $e');
      return HealthCheckResult.invalidFormat(
        'Validation error',
        details: e.toString(),
      );
    }
  }

  @override
  Future<HealthCheckResult> testConnectivity(
    String apiKey, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      _logger.i('Testing Claude API connectivity...');

      // Make a minimal API call to verify the key works
      final response = await _dio.post(
        'https://api.anthropic.com/v1/messages',
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json',
          },
          sendTimeout: timeout,
          receiveTimeout: timeout,
        ),
        data: {
          'model': 'claude-3-5-sonnet-20241022',
          'max_tokens': 10,
          'messages': [
            {'role': 'user', 'content': 'Hi'},
          ],
        },
      );

      if (response.statusCode == 200) {
        _logger.i('Claude API connectivity test successful');
        return HealthCheckResult.valid(
          'Connection successful',
          details: 'API key is valid and working',
        );
      } else {
        _logger.w(
          'Claude API returned unexpected status: ${response.statusCode}',
        );
        return HealthCheckResult.warning(
          'Unexpected response',
          details: 'Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _logger.e('Claude API connectivity test failed: ${e.message}');

      if (e.response?.statusCode == 401) {
        return HealthCheckResult.connectivityFailed(
          'Invalid API key',
          details:
              'The API key was rejected. Please check your key at console.anthropic.com',
        );
      }

      if (e.response?.statusCode == 429) {
        return HealthCheckResult.warning(
          'Rate limit exceeded',
          details:
              'Too many requests. The API key appears valid but is rate limited.',
        );
      }

      if (e.response?.statusCode == 400) {
        return HealthCheckResult.warning(
          'Bad request',
          details:
              'The API key appears valid but the request format may have changed',
        );
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return HealthCheckResult.connectivityFailed(
          'Connection timeout',
          details:
              'Could not reach api.anthropic.com within ${timeout.inSeconds} seconds',
        );
      }

      if (e.type == DioExceptionType.connectionError) {
        return HealthCheckResult.connectivityFailed(
          'Connection error',
          details:
              'Could not connect to api.anthropic.com. Check your internet connection.',
        );
      }

      return HealthCheckResult.connectivityFailed(
        'Connection failed',
        details: e.message ?? 'Unknown error',
      );
    } catch (e) {
      _logger.e('Unexpected error testing Claude API: $e');
      return HealthCheckResult.connectivityFailed(
        'Unexpected error',
        details: e.toString(),
      );
    }
  }

  @override
  Future<HealthCheckResult> validatePermissions(String apiKey) async {
    // For Claude API, if connectivity works, permissions are implicit.
    // The API doesn't have separate permission scopes that we need to check,
    // so we avoid making an additional paid network call here.
    _logger.d('Claude API permissions are implicit with connectivity');
    return HealthCheckResult.valid(
      'Permissions valid',
      details: 'Claude API permissions are implicit with a valid API key.',
    );
  }
}
