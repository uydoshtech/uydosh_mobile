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
    this.descriptionRu,
    this.scheduledAt,
    this.addressText,
    this.isRemote = false,
  });
  final int categoryId;
  final String title;
  final GigRequestBudgetType budgetType;
  final int? budgetAmount;
  final String? descriptionRu;
  final DateTime? scheduledAt;
  final String? addressText;
  final bool isRemote;
}

abstract class GigPostRequestState {
  const GigPostRequestState();
}

class GigPostRequestIdle extends GigPostRequestState {
  const GigPostRequestIdle({this.categories = const <GigCategory>[]});
  final List<GigCategory> categories;
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
      try {
        final cats = await _service.listCategories();
        emit(GigPostRequestIdle(categories: cats));
      } catch (err) {
        emit(GigPostRequestError(err.toString()));
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
