import 'package:freezed_annotation/freezed_annotation.dart';

part 'pageable_response.freezed.dart';

@freezed
class PageableResponse<T> with _$PageableResponse<T> {
  const factory PageableResponse({
    required List<T> data,
    required int total,
    required int page,
    required int limit,
    required int totalPages,
  }) = _PageableResponse<T>;

  const PageableResponse._();

  bool get hasMore => page < totalPages;
}
