import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:greenfield/core/services/health_check/slack_health_check_service.dart';
import 'package:greenfield/core/services/health_check/health_check_result.dart';

import '../../../mocks/mock_dio.mocks.dart';
import '../../../mocks/mock_logger.mocks.dart';

void main() {
  group('SlackHealthCheckService', () {
    late SlackHealthCheckService service;
    late MockDio mockDio;
    late MockLogger mockLogger;

    setUp(() {
      mockDio = MockDio();
      mockLogger = MockLogger();
      service = SlackHealthCheckService(dio: mockDio, logger: mockLogger);
    });

    group('validateFormat', () {
      test('returns valid for correct token format', () async {
        final result = await service.validateFormat(
          'xoxb-fake-test-token-not-real-for-testing-purposes-only',
        );
        expect(result.status, HealthCheckStatus.valid);
        expect(result.message, contains('valid'));
      });

      test('returns invalid for empty token', () async {
        final result = await service.validateFormat('');
        expect(result.status, HealthCheckStatus.invalid);
        expect(result.message, contains('required'));
      });

      test('returns invalid for wrong prefix', () async {
        final result = await service.validateFormat('wrong-prefix-token');
        expect(result.status, HealthCheckStatus.invalid);
        expect(result.message, contains('Invalid'));
      });

      test('returns invalid for too short token', () async {
        final result = await service.validateFormat('xoxb-short');
        expect(result.status, HealthCheckStatus.invalid);
        expect(result.message, contains('too short'));
      });
    });

    group('testConnectivity', () {
      test('returns valid on successful auth.test call', () async {
        when(mockDio.post(any, options: anyNamed('options'))).thenAnswer(
          (_) async => Response(
            data: {'ok': true, 'team': 'Test Workspace', 'user': 'test_user'},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/auth.test'),
          ),
        );

        final result = await service.testConnectivity(
          'xoxb-fake-test-token-not-real-for-testing-purposes-only',
        );
        expect(result.status, HealthCheckStatus.valid);
        expect(result.message, contains('successful'));
        expect(result.details, contains('Test Workspace'));
      });

      test('returns invalid on invalid_auth error', () async {
        when(mockDio.post(any, options: anyNamed('options'))).thenAnswer(
          (_) async => Response(
            data: {'ok': false, 'error': 'invalid_auth'},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/auth.test'),
          ),
        );

        final result = await service.testConnectivity('xoxb-invalid-token');
        expect(result.status, HealthCheckStatus.invalid);
        expect(result.message, contains('Invalid token'));
      });

      test('returns warning on 429 rate limit', () async {
        when(mockDio.post(any, options: anyNamed('options'))).thenThrow(
          DioException(
            response: Response(
              statusCode: 429,
              requestOptions: RequestOptions(path: '/api/auth.test'),
            ),
            requestOptions: RequestOptions(path: '/api/auth.test'),
            type: DioExceptionType.badResponse,
          ),
        );

        final result = await service.testConnectivity(
          'xoxb-fake-test-token-not-real-for-testing-purposes-only',
        );
        expect(result.status, HealthCheckStatus.warning);
        expect(result.message, contains('Rate limit'));
      });

      test('returns connectivity failed on timeout', () async {
        when(mockDio.post(any, options: anyNamed('options'))).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: '/api/auth.test'),
          ),
        );

        final result = await service.testConnectivity(
          'xoxb-fake-test-token-not-real-for-testing-purposes-only',
        );
        expect(result.status, HealthCheckStatus.invalid);
        expect(result.message, contains('timeout'));
      });
    });

    group('validatePermissions', () {
      test('returns valid with note about scopes', () async {
        when(mockDio.post(any, options: anyNamed('options'))).thenAnswer(
          (_) async => Response(
            data: {'ok': true, 'team': 'Test Workspace'},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/auth.test'),
          ),
        );

        final result = await service.validatePermissions(
          'xoxb-fake-test-token-not-real-for-testing-purposes-only',
        );
        expect(result.status, HealthCheckStatus.valid);
        expect(result.details, contains('chat:write'));
      });

      test('returns warning when permissions cannot be verified', () async {
        when(mockDio.post(any, options: anyNamed('options'))).thenThrow(
          DioException(
            type: DioExceptionType.connectionError,
            requestOptions: RequestOptions(path: '/api/auth.test'),
          ),
        );

        final result = await service.validatePermissions(
          'xoxb-fake-test-token-not-real-for-testing-purposes-only',
        );
        expect(result.status, HealthCheckStatus.warning);
        expect(result.message, contains('Could not verify'));
      });
    });

    group('serviceName', () {
      test('returns correct service name', () {
        expect(service.serviceName, 'Slack Bot');
      });
    });
  });
}
