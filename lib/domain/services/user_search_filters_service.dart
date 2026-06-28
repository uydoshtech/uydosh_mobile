import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";

abstract class IUserSearchFiltersService {
  /// GET /users/me/search-filters → `{ "search_filters": Map? }`
  Future<Map<String, dynamic>> fetchMe();

  /// PATCH /users/me/search-filters with `{ "search_filters": ... }`
  Future<void> saveMe(Map<String, dynamic> searchFilters);

  /// PATCH /users/me/search-filters with `{ "search_filters": null }`
  Future<void> clearMe();
}

class UserSearchFiltersService implements IUserSearchFiltersService {
  UserSearchFiltersService(this._client);

  final IOAuthApiClient _client;

  @override
  Future<Map<String, dynamic>> fetchMe() {
    return _client.get<Map<String, dynamic>>(
      "/users/me/search-filters",
      (json) => Map<String, dynamic>.from(json as Map),
    );
  }

  @override
  Future<void> saveMe(Map<String, dynamic> searchFilters) async {
    await _client.patch<Map<String, dynamic>, _SearchFiltersPatchBody>(
      "/users/me/search-filters",
      (_) => <String, dynamic>{},
      data: _SearchFiltersPatchBody(searchFilters),
    );
  }

  @override
  Future<void> clearMe() async {
    await _client.patch<Map<String, dynamic>, _SearchFiltersClearBody>(
      "/users/me/search-filters",
      (_) => <String, dynamic>{},
      data: _SearchFiltersClearBody(),
    );
  }
}

class _SearchFiltersPatchBody implements IJsonEncodable {
  _SearchFiltersPatchBody(this.searchFilters);

  final Map<String, dynamic> searchFilters;

  @override
  Map<String, dynamic> toJson() => {"search_filters": searchFilters};
}

class _SearchFiltersClearBody implements IJsonEncodable {
  @override
  Map<String, dynamic> toJson() => {"search_filters": null};
}
