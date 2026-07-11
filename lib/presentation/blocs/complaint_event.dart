part of "complaint_bloc.dart";

@freezed
sealed class ComplaintEvent with _$ComplaintEvent {
  const factory ComplaintEvent.fetchComplaintCategories() =
      _FetchComplaintCategories;
  const factory ComplaintEvent.createComplaint(CreateComplaintRequest request) =
      _CreateComplaint;
  const factory ComplaintEvent.fetchUserComplaints(int userId) =
      _FetchUserComplaints;
  const factory ComplaintEvent.fetchListingComplaints(int listingId) =
      _FetchListingComplaints;
  const factory ComplaintEvent.updateComplaintStatus(int id, String status) =
      _UpdateComplaintStatus;
  const factory ComplaintEvent.deleteComplaint(int id) = _DeleteComplaint;
}
