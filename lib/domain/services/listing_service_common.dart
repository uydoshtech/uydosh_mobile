import "package:uy_dosh/base/api/client/json_encodable.dart";

/// Empty request for endpoints that don't require a request body.
class EmptyListingRequest implements IJsonEncodable {
  @override
  Map<String, dynamic> toJson() => {};
}

class DescriptionTranslationRequest implements IJsonEncodable {
  DescriptionTranslationRequest({
    required this.targetLanguageCode,
    required this.translatedText,
  });

  final String targetLanguageCode;
  final String translatedText;

  @override
  Map<String, dynamic> toJson() => {
        "targetLanguageCode": targetLanguageCode,
        "translatedText": translatedText,
      };
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

/// RoomPlan USDZ upload (stored server-side; URL saved as listing.point_cloud_url).
class RoomScanUploadRequest implements IJsonEncodable {
  RoomScanUploadRequest({required this.usdzData});

  final String usdzData;

  @override
  Map<String, dynamic> toJson() => {"usdzData": usdzData};
}

/// Reorder existing listing photos. `photoIds` are in the desired display
/// order (index 0 = new primary, index 0-based = new photo_order - 1).
class PhotoReorderRequest implements IJsonEncodable {
  PhotoReorderRequest({required this.photoIds});

  final List<int> photoIds;

  @override
  Map<String, dynamic> toJson() => {"photoIds": photoIds};
}
