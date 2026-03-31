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
