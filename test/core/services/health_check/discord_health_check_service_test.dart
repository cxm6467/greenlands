import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:greenfield/core/services/health_check/discord_health_check_service.dart';
import 'package:greenfield/core/services/health_check/health_check_result.dart';

import '../../../mocks/mock_dio.mocks.dart';
import '../../../mocks/mock_logger.mocks.dart';

void main() {
  group('DiscordHealthCheckService', () {
    late DiscordHealthCheckService service;
    late MockDio mockDio;
    late MockLogger mockLogger;

    setUp(() {
      mockDio = MockDio();
      mockLogger = MockLogger();
      service = DiscordHealthCheckService(dio: mockDio, logger: mockLogger);
    });

    group('validateFormat', () {
      test('returns valid for correct token format with dots', () async {
        final result = await service.validateFormat(
          'FAKE_DISCORD_TOKEN.test.not-a-real-token-for-testing-only',
        );
        expect(result.status, HealthCheckStatus.valid);
        expect(result.message, contains('valid'));
      });

      test('returns invalid for empty token', () async {
        final result = await service.validateFormat('');
        expect(result.status, HealthCheckStatus.invalid);
        expect(result.message, contains('required'));
      });

      test('returns invalid for token without dots', () async {
        final result = await service.validateFormat('invalidtoken');
        expect(result.status, HealthCheckStatus.invalid);
        expect(result.message, contains('Invalid'));
      });

      test('returns invalid for too short token', () async {
        final result = await service.validateFormat('abc..ghi');
        expect(result.status, HealthCheckStatus.invalid);
        expect(result.message, contains('Invalid'));
      });
    });

    group('testConnectivity', () {
      test('returns valid on successful API call', () async {
        when(mockDio.get(any, options: anyNamed('options'))).thenAnswer(
          (_) async => Response(
            data: {
              'id': '123456789',
              'username': 'TestBot',
              'discriminator': '0001',
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/users/@me'),
          ),
        );

        final result = await service.testConnectivity(
          'FAKE_DISCORD_TOKEN.test.not-a-real-token-for-testing-only',
        );
        expect(result.status, HealthCheckStatus.valid);
        expect(result.message, contains('successful'));
      });

      test('returns invalid on 401 unauthorized', () async {
        when(mockDio.get(any, options: anyNamed('options'))).thenThrow(
          DioException(
            response: Response(
              statusCode: 401,
              requestOptions: RequestOptions(path: '/users/@me'),
            ),
            requestOptions: RequestOptions(path: '/users/@me'),
            type: DioExceptionType.badResponse,
          ),
        );

        final result = await service.testConnectivity(
          'FAKE_DISCORD_TOKEN.test.invalid-token-for-testing',
        );
        expect(result.status, HealthCheckStatus.invalid);
        expect(result.message, contains('Invalid'));
      });

      test('returns warning on 429 rate limit', () async {
        when(mockDio.get(any, options: anyNamed('options'))).thenThrow(
          DioException(
            response: Response(
              statusCode: 429,
              requestOptions: RequestOptions(path: '/users/@me'),
            ),
            requestOptions: RequestOptions(path: '/users/@me'),
            type: DioExceptionType.badResponse,
          ),
        );

        final result = await service.testConnectivity(
          'FAKE_DISCORD_TOKEN.test.not-a-real-token-for-testing-only',
        );
        expect(result.status, HealthCheckStatus.warning);
        expect(result.message, contains('Rate limit'));
      });

      test('returns connectivity failed on timeout', () async {
        when(mockDio.get(any, options: anyNamed('options'))).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: '/users/@me'),
          ),
        );

        final result = await service.testConnectivity(
          'FAKE_DISCORD_TOKEN.test.not-a-real-token-for-testing-only',
        );
        expect(result.status, HealthCheckStatus.invalid);
        expect(result.message, contains('timeout'));
      });
    });

    group('validatePermissions', () {
      test('returns valid when bot has required intents', () async {
        when(mockDio.get(any, options: anyNamed('options'))).thenAnswer(
          (_) async => Response(
            data: {'id': '123456789', 'username': 'TestBot', 'bot': true},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/users/@me'),
          ),
        );

        final result = await service.validatePermissions(
          'FAKE_DISCORD_TOKEN.test.not-a-real-token-for-testing-only',
        );
        expect(result.status, HealthCheckStatus.valid);
      });
    });

    group('serviceName', () {
      test('returns correct service name', () {
        expect(service.serviceName, 'Discord Bot');
      });
    });
  });
}
