import "package:uy_dosh/base/api/client/json_encodable.dart";

/// Empty request for endpoints that don't require a request body.
class EmptyListingRequest implements IJsonEncodable {
  @override
  Map<String, dynamic> toJson() => {};
}

/// Request for photo upload endpoints.
class PhotoUploadRequest implements IJsonEncodable {
  PhotoUploadRequest({required this.imageData, required this.isPrimary});

  final String imageData;
  final bool isPrimary;

  @override
  Map<String, dynamic> toJson() => {
        "imageData": imageData,
        "isPrimary": isPrimary,
      };
}
