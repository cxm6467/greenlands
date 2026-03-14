import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:greenlands/core/services/health_check/google_chat_health_check_service.dart';
import 'package:greenlands/core/services/health_check/health_check_result.dart';

import '../../../mocks/mock_dio.mocks.dart';
import '../../../mocks/mock_logger.mocks.dart';

void main() {
  group('GoogleChatHealthCheckService', () {
    late GoogleChatHealthCheckService service;
    late MockDio mockDio;
    late MockLogger mockLogger;

    setUp(() {
      mockDio = MockDio();
      mockLogger = MockLogger();
      service = GoogleChatHealthCheckService(dio: mockDio, logger: mockLogger);
    });

    group('validateFormat', () {
      test('returns valid for correct webhook URL', () async {
        final result = await service.validateFormat(
          'https://chat.googleapis.com/v1/spaces/AAAA1234567/messages?key=test-key&token=test-token',
        );
        expect(result.status, HealthCheckStatus.valid);
        expect(result.message, contains('valid'));
      });

      test('returns invalid for empty webhook', () async {
        final result = await service.validateFormat('');
        expect(result.status, HealthCheckStatus.invalid);
        expect(result.message, contains('required'));
      });

      test('returns invalid for non-HTTPS URL', () async {
        final result = await service.validateFormat(
          'http://chat.googleapis.com/v1/spaces/AAAA1234567/messages',
        );
        expect(result.status, HealthCheckStatus.invalid);
        expect(result.message, contains('Invalid'));
      });

      test('returns invalid for wrong domain', () async {
        final result = await service.validateFormat(
          'https://example.com/webhook',
        );
        expect(result.status, HealthCheckStatus.invalid);
        expect(result.message, contains('Invalid'));
      });

      test('returns invalid for missing /v1/spaces/ path', () async {
        final result = await service.validateFormat(
          'https://chat.googleapis.com/webhook',
        );
        expect(result.status, HealthCheckStatus.invalid);
        expect(result.message, contains('Invalid'));
      });
    });

    group('testConnectivity', () {
      test('returns valid on successful webhook call', () async {
        when(
          mockDio.post(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: {
              'name': 'spaces/AAAA1234567/messages/abc123',
              'sender': {'name': 'users/12345'},
            },
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/v1/spaces/AAAA1234567/messages',
            ),
          ),
        );

        final result = await service.testConnectivity(
          'https://chat.googleapis.com/v1/spaces/AAAA1234567/messages?key=test-key&token=test-token',
        );
        expect(result.status, HealthCheckStatus.valid);
        expect(result.message, contains('successful'));
      });

      test('returns invalid on 404 not found', () async {
        when(
          mockDio.post(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenThrow(
          DioException(
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(
                path: '/v1/spaces/AAAA1234567/messages',
              ),
            ),
            requestOptions: RequestOptions(
              path: '/v1/spaces/AAAA1234567/messages',
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        final result = await service.testConnectivity(
          'https://chat.googleapis.com/v1/spaces/INVALID/messages?key=test-key&token=test-token',
        );
        expect(result.status, HealthCheckStatus.invalid);
        expect(result.message, contains('not found'));
      });

      test('returns invalid on 401 unauthorized', () async {
        when(
          mockDio.post(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenThrow(
          DioException(
            response: Response(
              statusCode: 401,
              requestOptions: RequestOptions(
                path: '/v1/spaces/AAAA1234567/messages',
              ),
            ),
            requestOptions: RequestOptions(
              path: '/v1/spaces/AAAA1234567/messages',
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        final result = await service.testConnectivity(
          'https://chat.googleapis.com/v1/spaces/AAAA1234567/messages?key=bad-key&token=bad-token',
        );
        expect(result.status, HealthCheckStatus.invalid);
        expect(
          result.message.toLowerCase(),
          anyOf(
            contains('invalid'),
            contains('connection'),
            contains('failed'),
          ),
        );
      });

      test('returns connectivity failed on timeout', () async {
        when(
          mockDio.post(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(
              path: '/v1/spaces/AAAA1234567/messages',
            ),
          ),
        );

        final result = await service.testConnectivity(
          'https://chat.googleapis.com/v1/spaces/AAAA1234567/messages?key=test-key&token=test-token',
        );
        expect(result.status, HealthCheckStatus.invalid);
        expect(result.message, contains('timeout'));
      });

      test('returns connectivity failed on connection error', () async {
        when(
          mockDio.post(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.connectionError,
            requestOptions: RequestOptions(
              path: '/v1/spaces/AAAA1234567/messages',
            ),
          ),
        );

        final result = await service.testConnectivity(
          'https://chat.googleapis.com/v1/spaces/AAAA1234567/messages?key=test-key&token=test-token',
        );
        expect(result.status, HealthCheckStatus.invalid);
        expect(result.message, contains('Connection error'));
      });
    });

    group('validatePermissions', () {
      test('returns valid as webhooks have implicit permissions', () async {
        when(
          mockDio.post(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: {'name': 'spaces/AAAA1234567/messages/abc123'},
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/v1/spaces/AAAA1234567/messages',
            ),
          ),
        );

        final result = await service.validatePermissions(
          'https://chat.googleapis.com/v1/spaces/AAAA1234567/messages?key=test-key&token=test-token',
        );
        expect(result.status, HealthCheckStatus.valid);
      });
    });

    group('serviceName', () {
      test('returns correct service name', () {
        expect(service.serviceName, 'Google Chat');
      });
    });
  });
}
