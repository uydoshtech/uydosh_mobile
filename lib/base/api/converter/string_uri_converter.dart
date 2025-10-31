/*
 * Copyright (C) 2024 Finharbor DOO. - All Rights Reserved
 *
 * Unauthorized copying or redistribution of this file in source and binary forms via any medium
 * is strictly prohibited.
 */

import "package:freezed_annotation/freezed_annotation.dart";

class StringUriConverter implements JsonConverter<Uri, String> {
  const StringUriConverter();

  @override
  Uri fromJson(dynamic json) {
    if (json is String) {
      return Uri.parse(json);
    } else if (json is Uri) {
      return json;
    }
    throw Exception("Invalid value, expected String or Uri");
  }

  @override
  String toJson(Uri object) => object.toString();
}
