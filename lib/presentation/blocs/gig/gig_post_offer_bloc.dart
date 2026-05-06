import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/domain/models/gig/gig_category.dart";
import "package:uy_dosh/domain/models/gig/gig_offer.dart";
import "package:uy_dosh/domain/services/gig_service.dart";

abstract class GigPostOfferEvent {
  const GigPostOfferEvent();
}

class LoadCategoriesForOffer extends GigPostOfferEvent {
  const LoadCategoriesForOffer();
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
  });
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
  const GigPostOfferIdle({
    this.categories = const <GigCategory>[],
    this.loadingCategories = false,
    this.categoriesError,
  });

  final List<GigCategory> categories;

  /// True while the initial categories request is in-flight. Distinguishes
  /// "still loading" from "loaded and the response was empty / failed".
  final bool loadingCategories;

  /// Last error encountered while loading categories, if any. Cleared on the
  /// next successful load.
  final String? categoriesError;
}

class GigPostOfferSubmitting extends GigPostOfferState {
  const GigPostOfferSubmitting();
}

class GigPostOfferSuccess extends GigPostOfferState {
  const GigPostOfferSuccess(this.created);
  final GigOffer created;
}

class GigPostOfferError extends GigPostOfferState {
  const GigPostOfferError(this.message);
  final String message;
}

class GigPostOfferBloc extends Bloc<GigPostOfferEvent, GigPostOfferState> {
  GigPostOfferBloc(this._service) : super(const GigPostOfferIdle()) {
    on<LoadCategoriesForOffer>((_, emit) async {
      emit(const GigPostOfferIdle(loadingCategories: true));
      try {
        final cats = await _service.listCategories();
        emit(GigPostOfferIdle(categories: cats));
      } catch (err) {
        // Stay in Idle (so the form is still usable) but surface the error
        // through the dropdown plate. Going to GigPostOfferError would dump
        // the user out of the screen via the SnackBar listener.
        emit(GigPostOfferIdle(categoriesError: err.toString()));
      }
    });
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
        emit(GigPostOfferSuccess(offer));
      } catch (err) {
        emit(GigPostOfferError(err.toString()));
      }
    });
  }

  final IGigService _service;
}
