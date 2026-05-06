import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/domain/models/gig/gig_category.dart";
import "package:uy_dosh/domain/models/gig/gig_request.dart";
import "package:uy_dosh/domain/services/gig_service.dart";

abstract class GigPostRequestEvent {
  const GigPostRequestEvent();
}

class LoadCategoriesForRequest extends GigPostRequestEvent {
  const LoadCategoriesForRequest();
}

class SubmitGigRequest extends GigPostRequestEvent {
  const SubmitGigRequest({
    required this.categoryId,
    required this.title,
    required this.budgetType,
    this.budgetAmount,
    this.currencyCode = "UZS",
    this.descriptionRu,
    this.scheduledAt,
    this.addressText,
    this.isRemote = false,
  });
  final int categoryId;
  final String title;
  final GigRequestBudgetType budgetType;
  final int? budgetAmount;
  final String currencyCode;
  final String? descriptionRu;
  final DateTime? scheduledAt;
  final String? addressText;
  final bool isRemote;
}

abstract class GigPostRequestState {
  const GigPostRequestState();
}

class GigPostRequestIdle extends GigPostRequestState {
  const GigPostRequestIdle({
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

class GigPostRequestSubmitting extends GigPostRequestState {
  const GigPostRequestSubmitting();
}

class GigPostRequestSuccess extends GigPostRequestState {
  const GigPostRequestSuccess(this.created);
  final GigRequest created;
}

class GigPostRequestError extends GigPostRequestState {
  const GigPostRequestError(this.message);
  final String message;
}

class GigPostRequestBloc extends Bloc<GigPostRequestEvent, GigPostRequestState> {
  GigPostRequestBloc(this._service) : super(const GigPostRequestIdle()) {
    on<LoadCategoriesForRequest>((_, emit) async {
      emit(const GigPostRequestIdle(loadingCategories: true));
      try {
        final cats = await _service.listCategories();
        emit(GigPostRequestIdle(categories: cats));
      } catch (err) {
        // Stay in Idle (so the form is still usable) but surface the error
        // through the dropdown plate. Going to GigPostRequestError would
        // dump the user out of the screen via the SnackBar listener.
        emit(GigPostRequestIdle(categoriesError: err.toString()));
      }
    });
    on<SubmitGigRequest>((e, emit) async {
      emit(const GigPostRequestSubmitting());
      try {
        final req = await _service.createRequest(
          categoryId: e.categoryId,
          title: e.title,
          budgetType: e.budgetType,
          budgetAmount: e.budgetAmount,
          currencyCode: e.currencyCode,
          descriptionRu: e.descriptionRu,
          scheduledAt: e.scheduledAt,
          addressText: e.addressText,
          isRemote: e.isRemote,
        );
        emit(GigPostRequestSuccess(req));
      } catch (err) {
        emit(GigPostRequestError(err.toString()));
      }
    });
  }

  final IGigService _service;
}
