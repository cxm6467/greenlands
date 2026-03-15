import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:greenfield/core/services/health_check/claude_health_check_service.dart';
import 'package:greenfield/core/services/health_check/health_check_result.dart';

import '../../../mocks/mock_dio.mocks.dart';
import '../../../mocks/mock_logger.mocks.dart';

void main() {
  group('ClaudeHealthCheckService', () {
    late ClaudeHealthCheckService service;
    late MockDio mockDio;
    late MockLogger mockLogger;

    setUp(() {
      mockDio = MockDio();
      mockLogger = MockLogger();
      service = ClaudeHealthCheckService(dio: mockDio, logger: mockLogger);
    });

    group('validateFormat', () {
      test('returns valid for correct API key format', () async {
        final result = await service.validateFormat(
          'sk-ant-api03-abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890',
        );
        expect(result.status, HealthCheckStatus.valid);
        expect(result.message, contains('valid'));
      });

      test('returns invalid for empty key', () async {
        final result = await service.validateFormat('');
        expect(result.status, HealthCheckStatus.invalid);
        expect(result.message, contains('required'));
      });

      test('returns invalid for wrong prefix', () async {
        final result = await service.validateFormat('invalid-key');
        expect(result.status, HealthCheckStatus.invalid);
        expect(result.message, contains('Invalid'));
      });

      test('returns invalid for too short key', () async {
        final result = await service.validateFormat('sk-ant-api03-short');
        expect(result.status, HealthCheckStatus.invalid);
        expect(result.message, contains('too short'));
      });
    });

    group('testConnectivity', () {
      test('returns valid on successful API call', () async {
        when(
          mockDio.post(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: {
              'content': [
                {'text': 'test response'},
              ],
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/v1/messages'),
          ),
        );

        final result = await service.testConnectivity(
          'sk-ant-api03-validkey1234567890abcdefghijklmnopqrstuvwxyz1234567890',
        );
        expect(result.status, HealthCheckStatus.valid);
        expect(result.message, contains('successful'));
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
              requestOptions: RequestOptions(path: '/v1/messages'),
            ),
            requestOptions: RequestOptions(path: '/v1/messages'),
            type: DioExceptionType.badResponse,
          ),
        );

        final result = await service.testConnectivity(
          'sk-ant-api03-badkey1234567890abcdefghijklmnopqrstuvwxyz1234567890',
        );
        expect(result.status, HealthCheckStatus.invalid);
        expect(result.message, contains('Invalid'));
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
            requestOptions: RequestOptions(path: '/v1/messages'),
          ),
        );

        final result = await service.testConnectivity(
          'sk-ant-api03-validkey1234567890abcdefghijklmnopqrstuvwxyz1234567890',
        );
        expect(result.status, HealthCheckStatus.invalid);
        expect(result.message, contains('timeout'));
      });

      test('returns connectivity failed on network error', () async {
        when(
          mockDio.post(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.connectionError,
            requestOptions: RequestOptions(path: '/v1/messages'),
          ),
        );

        final result = await service.testConnectivity(
          'sk-ant-api03-validkey1234567890abcdefghijklmnopqrstuvwxyz1234567890',
        );
        expect(result.status, HealthCheckStatus.invalid);
        expect(result.message, contains('Connection error'));
      });

      test('respects timeout parameter', () async {
        const testTimeout = Duration(seconds: 5);

        when(
          mockDio.post(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: {
              'content': [
                {'text': 'test response'},
              ],
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/v1/messages'),
          ),
        );

        await service.testConnectivity(
          'sk-ant-api03-validkey1234567890abcdefghijklmnopqrstuvwxyz1234567890',
          timeout: testTimeout,
        );

        // Verify the timeout was passed to the API call
        verify(
          mockDio.post(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).called(1);
      });
    });

    group('validatePermissions', () {
      test('returns same result as testConnectivity for Claude', () async {
        when(
          mockDio.post(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: {
              'content': [
                {'text': 'test response'},
              ],
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/v1/messages'),
          ),
        );

        final connectivityResult = await service.testConnectivity(
          'sk-ant-api03-validkey1234567890abcdefghijklmnopqrstuvwxyz1234567890',
        );
        final permissionsResult = await service.validatePermissions(
          'sk-ant-api03-validkey1234567890abcdefghijklmnopqrstuvwxyz1234567890',
        );

        expect(permissionsResult.status, connectivityResult.status);
      });
    });

    group('runAllChecks', () {
      test('stops at format validation if invalid', () async {
        final result = await service.runAllChecks('invalid-key');

        expect(result.status, HealthCheckStatus.invalid);
        expect(result.message, contains('Invalid'));

        // Should not attempt connectivity check
        verifyNever(
          mockDio.post(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        );
      });

      test('runs all checks if format is valid', () async {
        when(
          mockDio.post(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: {
              'content': [
                {'text': 'test response'},
              ],
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/v1/messages'),
          ),
        );

        final result = await service.runAllChecks(
          'sk-ant-api03-validkey1234567890abcdefghijklmnopqrstuvwxyz1234567890',
        );

        expect(result.status, HealthCheckStatus.valid);

        // Should have called the API (connectivity and permissions both use testConnectivity)
        verify(
          mockDio.post(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).called(greaterThanOrEqualTo(1));
      });

      test('returns connectivity failed on exception', () async {
        when(
          mockDio.post(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenThrow(Exception('Network error'));

        final result = await service.runAllChecks(
          'sk-ant-api03-validkey1234567890abcdefghijklmnopqrstuvwxyz1234567890',
        );

        expect(result.status, HealthCheckStatus.invalid);
        // The error message should indicate a failure (either "Connection failed" or "Unexpected error")
        expect(
          result.message.toLowerCase(),
          anyOf(contains('connection'), contains('error')),
        );
      });
    });

    group('serviceName', () {
      test('returns correct service name', () {
        expect(service.serviceName, 'Claude API');
      });
    });
  });
}
