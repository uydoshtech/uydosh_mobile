import "package:bloc/bloc.dart";
import "package:dio/dio.dart";
import "package:freezed_annotation/freezed_annotation.dart";
import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/base/util/error_message_helper.dart";
import "package:uy_dosh/domain/models/complaint.dart";
import "package:uy_dosh/domain/models/complaint_category.dart";
import "package:uy_dosh/domain/services/complaint_service.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

part "complaint_bloc.freezed.dart";
part "complaint_event.dart";
part "complaint_state.dart";

class ComplaintBloc extends Bloc<ComplaintEvent, ComplaintState> {
  ComplaintBloc(this._complaintService)
    : super(const ComplaintState.initial()) {
    on<ComplaintEvent>((event, emit) async {
      await event.map(
        fetchComplaintCategories:
            (e) async => _onFetchComplaintCategories(emit),
        createComplaint: (e) async => _onCreateComplaint(emit, e.request),
        fetchUserComplaints:
            (e) async => _onFetchUserComplaints(emit, e.userId),
        fetchListingComplaints:
            (e) async => _onFetchListingComplaints(emit, e.listingId),
        updateComplaintStatus:
            (e) async => _onUpdateComplaintStatus(emit, e.id, e.status),
        deleteComplaint: (e) async => _onDeleteComplaint(emit, e.id),
      );
    });
  }

  final IComplaintService _complaintService;

  Future<void> _onFetchComplaintCategories(Emitter<ComplaintState> emit) async {
    emit(const ComplaintState.loading());

    try {
      final categories = await _complaintService.getComplaintCategories();
      emit(ComplaintState.categoriesLoaded(categories: categories));
    } catch (error) {
      final sanitizedMessage = ErrorMessageHelper.sanitizeErrorMessage(error);
      emit(ComplaintState.error(message: sanitizedMessage));
    }
  }

  Future<void> _onCreateComplaint(
    Emitter<ComplaintState> emit,
    CreateComplaintRequest request,
  ) async {
    emit(const ComplaintState.loading());

    try {
      final complaint = await _complaintService.createComplaint(request);
      emit(ComplaintState.complaintCreated(complaint: complaint));
    } catch (error) {
      // Handle DioException to extract status code
      if (error is DioException) {
        final statusCode = error.response?.statusCode;
        if (statusCode == 409) {
          // Get localized error message directly in the bloc
          final currentLanguage = LanguageState().currentLanguage;
          final localizedMessage = AppStrings.get(
            "error_resource_conflict",
            currentLanguage,
          );
          emit(ComplaintState.error(message: localizedMessage));
        } else {
          emit(ComplaintState.error(message: "DIO_ERROR_$statusCode"));
        }
      } else {
        emit(ComplaintState.error(message: error.toString()));
      }
    }
  }

  Future<void> _onFetchUserComplaints(
    Emitter<ComplaintState> emit,
    int userId,
  ) async {
    emit(const ComplaintState.loading());

    try {
      final complaints = await _complaintService.getUserComplaints(userId);
      emit(ComplaintState.complaintsLoaded(complaints: complaints));
    } catch (error) {
      final sanitizedMessage = ErrorMessageHelper.sanitizeErrorMessage(error);
      emit(ComplaintState.error(message: sanitizedMessage));
    }
  }

  Future<void> _onFetchListingComplaints(
    Emitter<ComplaintState> emit,
    int listingId,
  ) async {
    emit(const ComplaintState.loading());

    try {
      final complaints = await _complaintService.getListingComplaints(
        listingId,
      );
      emit(ComplaintState.complaintsLoaded(complaints: complaints));
    } catch (error) {
      final sanitizedMessage = ErrorMessageHelper.sanitizeErrorMessage(error);
      emit(ComplaintState.error(message: sanitizedMessage));
    }
  }

  Future<void> _onUpdateComplaintStatus(
    Emitter<ComplaintState> emit,
    int id,
    String status,
  ) async {
    try {
      final complaint = await _complaintService.updateComplaintStatus(
        id,
        status,
      );
      emit(ComplaintState.complaintUpdated(complaint: complaint));
    } catch (error) {
      final sanitizedMessage = ErrorMessageHelper.sanitizeErrorMessage(error);
      emit(ComplaintState.error(message: sanitizedMessage));
    }
  }

  Future<void> _onDeleteComplaint(Emitter<ComplaintState> emit, int id) async {
    try {
      await _complaintService.deleteComplaint(id);
      emit(ComplaintState.complaintDeleted(id: id));
    } catch (error) {
      final sanitizedMessage = ErrorMessageHelper.sanitizeErrorMessage(error);
      emit(ComplaintState.error(message: sanitizedMessage));
    }
  }
}
