part of "complaint_bloc.dart";

@freezed
class ComplaintState with _$ComplaintState {
  const factory ComplaintState.initial() = _Initial;
  const factory ComplaintState.loading() = _Loading;
  const factory ComplaintState.categoriesLoaded({
    required List<ComplaintCategory> categories,
  }) = _CategoriesLoaded;
  const factory ComplaintState.complaintCreated({
    required Complaint complaint,
  }) = _ComplaintCreated;
  const factory ComplaintState.complaintsLoaded({
    required List<Complaint> complaints,
  }) = _ComplaintsLoaded;
  const factory ComplaintState.complaintUpdated({
    required Complaint complaint,
  }) = _ComplaintUpdated;
  const factory ComplaintState.complaintDeleted({required int id}) =
      _ComplaintDeleted;
  const factory ComplaintState.error({required String message}) = _Error;
}
