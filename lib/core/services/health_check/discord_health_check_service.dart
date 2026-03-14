import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import 'health_check_result.dart';
import 'health_check_service.dart';

/// Health check service for Discord Bot tokens
class DiscordHealthCheckService extends HealthCheckService {
  final Dio _dio;
  final Logger _logger;

  DiscordHealthCheckService({required Dio dio, required Logger logger})
    : _dio = dio,
      _logger = logger;

  @override
  String get serviceName => 'Discord Bot';

  @override
  Future<HealthCheckResult> validateFormat(String token) async {
    try {
      if (token.isEmpty) {
        return HealthCheckResult.invalidFormat(
          'Bot token is required',
          details: 'Please provide your Discord bot token',
        );
      }

      // Discord bot tokens have a specific structure with dots separating parts
      // Example format: XXXXX.YYYYY.ZZZZZ (base64-encoded parts)
      final parts = token.split('.');
      if (parts.length != 3) {
        return HealthCheckResult.invalidFormat(
          'Invalid token format',
          details:
              'Discord bot tokens should have 3 parts separated by dots. Get your token at discord.com/developers',
        );
      }

      // Each part should be base64-like (alphanumeric with some special chars)
      final base64Pattern = RegExp(r'^[A-Za-z0-9_\-]+$');
      if (!base64Pattern.hasMatch(parts[0]) ||
          !base64Pattern.hasMatch(parts[1]) ||
          !base64Pattern.hasMatch(parts[2])) {
        return HealthCheckResult.invalidFormat(
          'Invalid token characters',
          details: 'Token contains invalid characters',
        );
      }

      _logger.d('Discord bot token format validation passed');
      return HealthCheckResult.valid(
        'Token format is valid',
        details: 'Ready to test connection',
      );
    } catch (e) {
      _logger.e('Error validating Discord token format: $e');
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
      _logger.i('Testing Discord bot connectivity...');

      // Make an API call to get the bot's user info
      final response = await _dio
          .get(
            'https://discord.com/api/v10/users/@me',
            options: Options(
              headers: {
                'Authorization': 'Bot $token',
                'Content-Type': 'application/json',
              },
            ),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final username = data['username'] as String?;
        _logger.i('Discord bot connectivity test successful: $username');
        return HealthCheckResult.valid(
          'Connection successful',
          details: username != null ? 'Bot: $username' : 'Bot token is valid',
        );
      } else {
        _logger.w(
          'Discord API returned unexpected status: ${response.statusCode}',
        );
        return HealthCheckResult.warning(
          'Unexpected response',
          details: 'Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _logger.e('Discord bot connectivity test failed: ${e.message}');

      if (e.response?.statusCode == 401) {
        return HealthCheckResult.connectivityFailed(
          'Invalid bot token',
          details:
              'The token was rejected. Please check your token at discord.com/developers',
        );
      }

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
              'Could not reach discord.com within ${timeout.inSeconds} seconds',
        );
      }

      if (e.type == DioExceptionType.connectionError) {
        return HealthCheckResult.connectivityFailed(
          'Connection error',
          details:
              'Could not connect to discord.com. Check your internet connection.',
        );
      }

      return HealthCheckResult.connectivityFailed(
        'Connection failed',
        details: e.message ?? 'Unknown error',
      );
    } catch (e) {
      _logger.e('Unexpected error testing Discord bot: $e');
      return HealthCheckResult.connectivityFailed(
        'Unexpected error',
        details: e.toString(),
      );
    }
  }

  @override
  Future<HealthCheckResult> validatePermissions(String token) async {
    try {
      _logger.i('Validating Discord bot permissions...');

      // Get bot info to check intents and permissions
      final response = await _dio.get(
        'https://discord.com/api/v10/users/@me',
        options: Options(headers: {'Authorization': 'Bot $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final bot = data['bot'] as bool? ?? false;

        if (!bot) {
          return HealthCheckResult.warning(
            'Not a bot token',
            details:
                'This appears to be a user token, not a bot token. Please use a bot token.',
          );
        }

        // Note: We can't check intents without joining a guild, so we assume they're configured
        _logger.i('Discord bot permissions appear valid');
        return HealthCheckResult.valid(
          'Bot token is valid',
          details:
              'Ensure the bot has proper intents configured in the Developer Portal',
        );
      } else {
        return HealthCheckResult.warning(
          'Could not verify permissions',
          details: 'Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _logger.e('Discord bot permission validation failed: ${e.message}');

      // If we can't check permissions, but connectivity worked, return a warning
      return HealthCheckResult.warning(
        'Could not verify permissions',
        details:
            'The token works but permissions could not be verified. Ensure the bot has MESSAGE_CONTENT intent.',
      );
    } catch (e) {
      _logger.e('Unexpected error validating Discord bot permissions: $e');
      return HealthCheckResult.warning(
        'Permission check failed',
        details: e.toString(),
      );
    }
  }
}
