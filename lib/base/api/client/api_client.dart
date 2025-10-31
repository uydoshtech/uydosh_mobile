/*
 * Copyright (C) 2024 Finharbor DOO. - All Rights Reserved
 *
 * Unauthorized copying or redistribution of this file in source and binary forms via any medium
 * is strictly prohibited.
 */

import "package:dio/dio.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/base/util/iterable_extension.dart";

abstract class IApiClient {
  IApiClient(this.dio);

  final Dio dio;

  Future<ResponseType> get<ResponseType>(
    String path,
    ResponseType Function(dynamic) fromJson, {
    String basePath = EnvironmentUtil.basePath,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.get(
      "$basePath$path",
      queryParameters: queryParameters,
      options: options ?? Options(headers: headers),
      cancelToken: cancelToken,
    );
    return fromJson(response.data);
  }

  Future<List<ResponseType>> getList<ResponseType>(
    String path,
    ResponseType Function(dynamic) fromJson, {
    String basePath = EnvironmentUtil.basePath,
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
    String basePath = EnvironmentUtil.basePath,
    RequestType? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.post(
      "$basePath$path",
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
    String basePath = EnvironmentUtil.basePath,
    RequestType? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.put(
      "$basePath$path",
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
    String basePath = EnvironmentUtil.basePath,
    RequestType? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.patch(
      "$basePath$path",
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
    String basePath = EnvironmentUtil.basePath,
    RequestType? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.delete(
      "$basePath$path",
      data: data?.toJson(),
      queryParameters: queryParameters,
      options: options ?? Options(headers: headers),
      cancelToken: cancelToken,
    );
    return fromJson(response.data);
  }
}
