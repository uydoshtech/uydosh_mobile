/*
 * Copyright (C) 2024 Finharbor DOO. - All Rights Reserved
 *
 * Unauthorized copying or redistribution of this file in source and binary forms via any medium
 * is strictly prohibited.
 */

import "dart:typed_data";

import "package:dio/dio.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/base/util/iterable_extension.dart";

abstract class IApiClient {
  IApiClient(this.dio);

  final Dio dio;

  // [basePath] used to default to `EnvironmentUtil.basePath` directly, which
  // required that field to be `const`. Now that the base URL is resolved at
  // runtime from Remote Config, default parameter values can no longer be
  // `const` — so callers either pass a custom [basePath] explicitly, or we
  // resolve the runtime value via `EnvironmentUtil.basePath` inside the
  // method body when [basePath] is null.

  Future<ResponseType> get<ResponseType>(
    String path,
    ResponseType Function(dynamic) fromJson, {
    String? basePath,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final base = basePath ?? EnvironmentUtil.basePath;
    final response = await dio.get(
      "$base$path",
      queryParameters: queryParameters,
      options: options ?? Options(headers: headers),
      cancelToken: cancelToken,
    );
    return fromJson(response.data);
  }

  /// Binary GET (e.g. admin export downloads). [path] is relative to [basePath].
  Future<Uint8List> getBytes(
    String path, {
    String? basePath,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final base = basePath ?? EnvironmentUtil.basePath;
    final response = await dio.get<dynamic>(
      "$base$path",
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      options:
          (options ?? Options()).copyWith(responseType: ResponseType.bytes),
    );
    final data = response.data;
    if (data is Uint8List) {
      return data;
    }
    if (data is List<int>) {
      return Uint8List.fromList(data);
    }
    throw StateError("Expected byte response from $path");
  }

  Future<List<ResponseType>> getList<ResponseType>(
    String path,
    ResponseType Function(dynamic) fromJson, {
    String? basePath,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return get(
      path,
      (json) => (json as List).mapToList((e) => fromJson(e)),
      basePath: basePath,
      queryParameters: queryParameters,
      headers: headers,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<ResponseType> post<ResponseType, RequestType extends IJsonEncodable>(
    String path,
    ResponseType Function(dynamic) fromJson, {
    String? basePath,
    RequestType? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final base = basePath ?? EnvironmentUtil.basePath;
    final response = await dio.post(
      "$base$path",
      data: data?.toJson(),
      queryParameters: queryParameters,
      options: options ?? Options(headers: headers),
      cancelToken: cancelToken,
    );
    return fromJson(response.data);
  }

  Future<ResponseType> put<ResponseType, RequestType extends IJsonEncodable>(
    String path,
    ResponseType Function(dynamic) fromJson, {
    String? basePath,
    RequestType? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final base = basePath ?? EnvironmentUtil.basePath;
    final response = await dio.put(
      "$base$path",
      data: data?.toJson(),
      queryParameters: queryParameters,
      options: options ?? Options(headers: headers),
      cancelToken: cancelToken,
    );
    return fromJson(response.data);
  }

  Future<ResponseType> patch<ResponseType, RequestType extends IJsonEncodable>(
    String path,
    ResponseType Function(dynamic) fromJson, {
    String? basePath,
    RequestType? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final base = basePath ?? EnvironmentUtil.basePath;
    final response = await dio.patch(
      "$base$path",
      data: data?.toJson(),
      queryParameters: queryParameters,
      options: options ?? Options(headers: headers),
      cancelToken: cancelToken,
    );
    return fromJson(response.data);
  }

  Future<ResponseType> delete<ResponseType, RequestType extends IJsonEncodable>(
    String path,
    ResponseType Function(dynamic) fromJson, {
    String? basePath,
    RequestType? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final base = basePath ?? EnvironmentUtil.basePath;
    final response = await dio.delete(
      "$base$path",
      data: data?.toJson(),
      queryParameters: queryParameters,
      options: options ?? Options(headers: headers),
      cancelToken: cancelToken,
    );
    return fromJson(response.data);
  }
}
