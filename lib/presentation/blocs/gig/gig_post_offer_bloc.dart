import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/cache/gig_category_cache.dart";
import "package:uy_dosh/domain/models/gig/gig_category.dart";
import "package:uy_dosh/domain/models/gig/gig_offer.dart";
import "package:uy_dosh/domain/services/gig_service.dart";

abstract class GigPostOfferEvent {
  const GigPostOfferEvent();
}

class SubmitGigOffer extends GigPostOfferEvent {
  const SubmitGigOffer({
    required this.categoryId,
    required this.title,
    required this.pricingType,
    required this.price,
    this.currencyCode = "UZS",
    this.descriptionRu,
    this.minDurationMinutes,
    this.isRemote = false,
    this.photoPaths = const <String>[],
    this.primaryPhotoIndex,
  });
  final int categoryId;
  final String title;
  final GigPricingType pricingType;
  final int price;
  final String currencyCode;
  final String? descriptionRu;
  final int? minDurationMinutes;
  final bool isRemote;

  /// Local file paths for photos the user picked while filling out the form.
  /// Uploaded sequentially after the offer is created (the photos route is
  /// keyed by offer id, so creation has to happen first). Empty list means
  /// "submit without photos".
  final List<String> photoPaths;

  /// Index into [photoPaths] for the photo the user marked as primary. The
  /// publish UI defaults to slot 0; this lets a user promote any picked
  /// photo to the cover image. `null` is treated as "no explicit choice"
  /// and the server falls back to "first photo wins".
  final int? primaryPhotoIndex;
}

/// Owner-only edit of an existing offer. Goes through `PATCH /gigs/offers/:id`
/// with whichever subset of fields the screen wants to overwrite. The
/// publish flow (`SubmitGigOffer`) still owns photo upload — for v1 the edit
/// screen only modifies text/numeric/category fields.
class SubmitGigOfferEdit extends GigPostOfferEvent {
  const SubmitGigOfferEdit({
    required this.offerId,
    required this.categoryId,
    required this.title,
    required this.pricingType,
    required this.price,
    this.currencyCode = "UZS",
    this.descriptionRu,
    this.minDurationMinutes,
    this.isRemote = false,
  });
  final int offerId;
  final int categoryId;
  final String title;
  final GigPricingType pricingType;
  final int price;
  final String currencyCode;
  final String? descriptionRu;
  final int? minDurationMinutes;
  final bool isRemote;
}

abstract class GigPostOfferState {
  const GigPostOfferState();
}

class GigPostOfferIdle extends GigPostOfferState {
  const GigPostOfferIdle({required this.categories});

  final List<GigCategory> categories;
}

class GigPostOfferSubmitting extends GigPostOfferState {
  const GigPostOfferSubmitting();
}

class GigPostOfferSuccess extends GigPostOfferState {
  const GigPostOfferSuccess(this.created);
  final GigOffer created;
}

class GigOfferEditSuccess extends GigPostOfferState {
  const GigOfferEditSuccess(this.updated);
  final GigOffer updated;
}

class GigPostOfferError extends GigPostOfferState {
  const GigPostOfferError(this.message);
  final String message;
}

class GigPostOfferBloc extends Bloc<GigPostOfferEvent, GigPostOfferState> {
  GigPostOfferBloc(this._service)
      : super(GigPostOfferIdle(categories: GigCategoryCache.getOrdered())) {
    on<SubmitGigOffer>((e, emit) async {
      emit(const GigPostOfferSubmitting());
      try {
        final offer = await _service.createOffer(
          categoryId: e.categoryId,
          title: e.title,
          pricingType: e.pricingType,
          price: e.price,
          currencyCode: e.currencyCode,
          descriptionRu: e.descriptionRu,
          minDurationMinutes: e.minDurationMinutes,
          isRemote: e.isRemote,
        );

        // Photos are a second hop: the server route is keyed by offer id,
        // so we can only upload after `createOffer` succeeds. Upload
        // sequentially (the listing flow does the same — keeps memory and
        // network pressure predictable on flaky connections) and tag the
        // primary photo on its own request so the server's "first photo
        // wins" fallback doesn't fight an explicit user choice.
        //
        // Per-photo failures are intentionally swallowed: the offer is
        // already live, and forcing the user back to the publish screen
        // would lose all their other input. They can retry uploads from
        // the (forthcoming) edit-offer screen.
        if (e.photoPaths.isNotEmpty) {
          for (var i = 0; i < e.photoPaths.length; i++) {
            final isPrimary = e.primaryPhotoIndex == null
                ? i == 0
                : i == e.primaryPhotoIndex;
            try {
              await _service.uploadOfferPhoto(
                offerId: offer.id,
                photoPath: e.photoPaths[i],
                isPrimary: isPrimary,
              );
            } catch (_) {
              // Best-effort upload — log + continue (see comment above).
            }
          }
        }

        emit(GigPostOfferSuccess(offer));
      } catch (err) {
        emit(GigPostOfferError(err.toString()));
      }
    });

    on<SubmitGigOfferEdit>((e, emit) async {
      emit(const GigPostOfferSubmitting());
      try {
        // Build a sparse patch — sending the full set of fields is harmless
        // (the backend `updateOffer` accepts a `Partial<…>`) but keeping
        // only the user-editable subset documents which fields this screen
        // actually owns. Photo edits are a separate, future workflow.
        final patch = <String, dynamic>{
          "category_id": e.categoryId,
          "title": e.title,
          "pricing_type": gigPricingTypeToString(e.pricingType),
          "price": e.price,
          "currency_code": e.currencyCode,
          // Send `null` (not "") when description was cleared so the server
          // can wipe the column rather than store an empty string.
          "description_ru": e.descriptionRu,
          "min_duration_minutes":
              e.pricingType == GigPricingType.hourly ? e.minDurationMinutes : null,
          "is_remote": e.isRemote,
        };
        final updated = await _service.updateOffer(id: e.offerId, patch: patch);
        emit(GigOfferEditSuccess(updated));
      } catch (err) {
        emit(GigPostOfferError(err.toString()));
      }
    });
  }

  final IGigService _service;
}
