import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/domain/services/location_service.dart";
import "package:uy_dosh/presentation/blocs/locations_bloc.dart";
import "package:uy_dosh/presentation/blocs/subway_stations_bloc.dart";
import "package:uy_dosh/presentation/screens/create_listing/create_listing_screen.dart";

/// Navigation helpers for housing listing create/edit flows.
extension ListingNavigatorExtensions on BuildContext {
  /// Full-screen create listing (own app bar, back pops to caller).
  Future<void> pushCreateListing({int? listingTypeId}) {
    return Navigator.of(this).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => SubwayStationsBloc()),
            BlocProvider(
              create: (_) => LocationsBloc(getIt<ILocationService>()),
            ),
          ],
          child: CreateListingScreen(
            showAppBar: true,
            initialListingTypeId: listingTypeId,
          ),
        ),
      ),
    );
  }

  Future<void> pushCreateGroup() {
    return pushCreateListing(listingTypeId: ListingTypeIds.groupForming);
  }
}
