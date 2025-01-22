import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';

import 'package:qrcode_scanner/src/services.dart';

class HttpApiService {
  HttpApiService(this.http, this.log) {
    _initializeDio();
  }

  final Dio http;
  final LoggerService log;

  void _initializeDio() {
    http.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: <String, dynamic>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    http.interceptors.add(
      InterceptorsWrapper(
        onRequest:
            (RequestOptions options, RequestInterceptorHandler handler) async {
          log.info(
            'REQUEST[${options.method}] => PATH: ${options.path}',
            <String, dynamic>{'data': options.data, 'headers': options.headers},
          );
          return handler.next(options);
        },
        onResponse:
            (Response<dynamic> response, ResponseInterceptorHandler handler) {
          log.info(
            'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
            <String, dynamic>{'data': response.data},
          );
          return handler.next(response);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          log.error(
            'ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}',
            error,
            error.stackTrace,
          );
          return handler.next(error);
        },
      ),
    );
  }

  TaskEither<Exception, T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) {
    return TaskEither<Exception, T>.tryCatch(
      () async {
        final Response<dynamic> response = await http.get(
          path,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
        );
        return _handleResponse<T>(response).match(
          (Exception error) => throw error,
          (T success) => success,
        );
      },
      (Object error, _) => _handleError(error),
    );
  }

  TaskEither<Exception, T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) {
    return TaskEither<Exception, T>.tryCatch(
      () async {
        final Response<dynamic> response = await http.post(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        );
        return _handleResponse<T>(response).match(
          (Exception error) => throw error,
          (T success) => success,
        );
      },
      (Object error, _) => _handleError(error),
    );
  }

  TaskEither<Exception, T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) {
    return TaskEither<Exception, T>.tryCatch(
      () async {
        final Response<dynamic> response = await http.put(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        );
        return _handleResponse<T>(response).match(
          (Exception error) => throw error,
          (T success) => success,
        );
      },
      (Object error, _) => _handleError(error),
    );
  }

  TaskEither<Exception, T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) {
    return TaskEither<Exception, T>.tryCatch(
      () async {
        final Response<dynamic> response = await http.patch(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        );
        return _handleResponse<T>(response).match(
          (Exception error) => throw error,
          (T success) => success,
        );
      },
      (Object error, _) => _handleError(error),
    );
  }

  TaskEither<Exception, T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return TaskEither<Exception, T>.tryCatch(
      () async {
        final Response<dynamic> response = await http.delete(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        );
        return _handleResponse<T>(response).match(
          (Exception error) => throw error,
          (T success) => success,
        );
      },
      (Object error, _) => _handleError(error),
    );
  }

  Either<Exception, T> _handleResponse<T>(Response<dynamic> response) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      return Either<Exception, T>.right(response.data as T);
    } else {
      return Either<Exception, T>.left(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Request failed with status code ${response.statusCode}',
        ),
      );
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return Exception('Connection timeout');
        case DioExceptionType.sendTimeout:
          return Exception('Send timeout');
        case DioExceptionType.receiveTimeout:
          return Exception('Receive timeout');
        case DioExceptionType.badResponse:
          return Exception('Bad response: ${error.response?.statusCode}');
        case DioExceptionType.cancel:
          return Exception('Request cancelled');
        default:
          return Exception(error.message);
      }
    }
    return Exception('Unknown error occurred');
  }
}
