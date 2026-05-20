import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/cache/gig_category_cache.dart";
import "package:uy_dosh/domain/models/gig/gig_category.dart";
import "package:uy_dosh/domain/models/gig/gig_request.dart";
import "package:uy_dosh/domain/services/gig_service.dart";

abstract class GigPostRequestEvent {
  const GigPostRequestEvent();
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
    this.locationId,
    this.subwayStationId,
    this.subwayLineId,
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
  final int? locationId;
  final int? subwayStationId;
  final int? subwayLineId;
  final String? addressText;
  final bool isRemote;
}

class SubmitGigRequestEdit extends GigPostRequestEvent {
  const SubmitGigRequestEdit({
    required this.requestId,
    required this.categoryId,
    required this.title,
    required this.budgetType,
    this.budgetAmount,
    this.currencyCode = "UZS",
    this.descriptionRu,
    this.locationId,
    this.subwayStationId,
    this.subwayLineId,
    this.addressText,
    this.isRemote = false,
  });
  final int requestId;
  final int categoryId;
  final String title;
  final GigRequestBudgetType budgetType;
  final int? budgetAmount;
  final String currencyCode;
  final String? descriptionRu;
  final int? locationId;
  final int? subwayStationId;
  final int? subwayLineId;
  final String? addressText;
  final bool isRemote;
}

abstract class GigPostRequestState {
  const GigPostRequestState();
}

class GigPostRequestIdle extends GigPostRequestState {
  const GigPostRequestIdle({required this.categories});

  final List<GigCategory> categories;
}

class GigPostRequestSubmitting extends GigPostRequestState {
  const GigPostRequestSubmitting();
}

class GigPostRequestSuccess extends GigPostRequestState {
  const GigPostRequestSuccess(this.created);
  final GigRequest created;
}

class GigRequestEditSuccess extends GigPostRequestState {
  const GigRequestEditSuccess(this.updated);
  final GigRequest updated;
}

class GigPostRequestError extends GigPostRequestState {
  const GigPostRequestError(this.message);
  final String message;
}

class GigPostRequestBloc extends Bloc<GigPostRequestEvent, GigPostRequestState> {
  GigPostRequestBloc(this._service)
      : super(GigPostRequestIdle(categories: GigCategoryCache.getOrdered())) {
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
          locationId: e.locationId,
          subwayStationId: e.subwayStationId,
          subwayLineId: e.subwayLineId,
          addressText: e.addressText,
          isRemote: e.isRemote,
        );
        emit(GigPostRequestSuccess(req));
      } catch (err) {
        emit(GigPostRequestError(err.toString()));
      }
    });

    on<SubmitGigRequestEdit>((e, emit) async {
      emit(const GigPostRequestSubmitting());
      try {
        final patch = <String, dynamic>{
          "category_id": e.categoryId,
          "title": e.title,
          "budget_type": gigBudgetTypeToString(e.budgetType),
          "currency_code": e.currencyCode,
          "description_ru": e.descriptionRu,
          "location_id": e.locationId,
          "subway_station_id": e.subwayStationId,
          "subway_line_id": e.subwayLineId,
          "address_text": e.addressText,
          "is_remote": e.isRemote,
          "budget_amount": e.budgetType == GigRequestBudgetType.open
              ? null
              : e.budgetAmount,
        };
        final updated =
            await _service.updateRequest(id: e.requestId, patch: patch);
        emit(GigRequestEditSuccess(updated));
      } catch (err) {
        emit(GigPostRequestError(err.toString()));
      }
    });
  }

  final IGigService _service;
}
