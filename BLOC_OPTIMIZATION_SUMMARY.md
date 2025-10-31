# BLoC State Management Optimization Summary

This document summarizes the optimizations implemented to reduce unnecessary rebuilds by replacing `BlocBuilder` with `BlocSelector` throughout the codebase.

## Overview

The optimization focuses on using `BlocSelector` instead of `BlocBuilder` when only specific data is needed, preventing unnecessary UI rebuilds when unrelated parts of the state change.

## Key Benefits

- **Reduced Rebuilds**: Widgets only rebuild when the specific data they depend on changes
- **Better Performance**: Improved app responsiveness and reduced CPU usage
- **Cleaner Code**: More explicit data dependencies and better separation of concerns
- **Optimized Memory Usage**: Less unnecessary widget recreation

## Implemented Optimizations

### 1. Home Screen (`lib/presentation/screens/home/home_screen.dart`)

**Before**: Used `BlocBuilder<ListingsBloc, ListingsState>` which rebuilt on any state change
**After**: Uses `BlocSelector<ListingsBloc, ListingsState, _HomeScreenData>` with custom data class

**Data Class**:
```dart
class _HomeScreenData {
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final List<Listing> listings;
  final bool hasMore;
  
  // Custom equality and hashCode for efficient comparison
}
```

**Optimization**: Only rebuilds when loading state, error state, listings count, or hasMore flag changes.

### 2. Profile Screen (`lib/presentation/screens/profile/profile_screen.dart`)

**Before**: Used `BlocBuilder<CurrentUserProfileBloc, CurrentUserProfileState>` which rebuilt on any profile state change
**After**: Uses `BlocSelector<CurrentUserProfileBloc, CurrentUserProfileState, _ProfileScreenData>` with custom data class

**Data Class**:
```dart
class _ProfileScreenData {
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final UserProfile? profile;
  
  // Custom equality and hashCode for efficient comparison
}
```

**Optimization**: Only rebuilds when loading state, error state, or profile ID changes.

### 3. User Listings Screen (`lib/presentation/screens/user_listings/user_listings_screen.dart`)

**Before**: Used `BlocBuilder<ListingsBloc, ListingsState>` which rebuilt on any listings state change
**After**: Uses `BlocSelector<ListingsBloc, ListingsState, _UserListingsData>` with custom data class

**Data Class**:
```dart
class _UserListingsData {
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final List<Listing> listings;
  final bool hasMore;
  
  // Custom equality and hashCode for efficient comparison
}
```

**Optimization**: Only rebuilds when loading state, error state, listings count, or hasMore flag changes.

### 4. Search Results Screen (`lib/presentation/screens/search_results/search_results_screen.dart`)

**Before**: Used `BlocBuilder<ListingsBloc, ListingsState>` which rebuilt on any listings state change
**After**: Uses `BlocSelector<ListingsBloc, ListingsState, _SearchResultsData>` with custom data class

**Data Class**:
```dart
class _SearchResultsData {
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final List<Listing> listings;
  final bool hasMore;
  
  // Custom equality and hashCode for efficient comparison
}
```

**Optimization**: Only rebuilds when loading state, error state, listings count, or hasMore flag changes.

### 5. Listing Owner Profile Screen (`lib/presentation/screens/listing_owner_profile/listing_owner_profile_screen.dart`)

**Before**: Used `BlocBuilder<ListingOwnerProfileBloc, ListingOwnerProfileState>` which rebuilt on any profile state change
**After**: Uses `BlocSelector<ListingOwnerProfileBloc, ListingOwnerProfileState, _ListingOwnerProfileData>` with custom data class

**Data Class**:
```dart
class _ListingOwnerProfileData {
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final UserProfile? profile;
  
  // Custom equality and hashCode for efficient comparison
}
```

**Optimization**: Only rebuilds when loading state, error state, or profile ID changes.

### 6. Search Bottom Sheet (`lib/presentation/widgets/search_bottom_sheet.dart`)

**Before**: Used `BlocBuilder<LocationsBloc, LocationsState>` which rebuilt on any locations state change
**After**: Uses `BlocSelector<LocationsBloc, LocationsState, _LocationPickerData>` with custom data class

**Data Class**:
```dart
class _LocationPickerData {
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final List<Location> locations;
  
  // Custom equality and hashCode for efficient comparison
}
```

**Optimization**: Only rebuilds when loading state, error state, or locations count changes.

### 7. Burger Menu Widget (`lib/presentation/widgets/burger_menu_widget.dart`)

**Before**: Used `BlocBuilder<CurrentUserProfileBloc, CurrentUserProfileState>` which rebuilt on any profile state change
**After**: Uses `BlocSelector<CurrentUserProfileBloc, CurrentUserProfileState, _BurgerMenuProfileData>` with custom data class

**Data Class**:
```dart
class _BurgerMenuProfileData {
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final UserProfile? profile;
  
  // Custom equality and hashCode for efficient comparison
}
```

**Optimization**: Only rebuilds when loading state, error state, or profile ID changes.

### 8. Listing Detail Screen (`lib/presentation/screens/listing_detail/listing_detail_screen.dart`)

**Before**: Used two `BlocBuilder<ListingDetailBloc, ListingDetailState>` instances which rebuilt on any state change
**After**: Uses two `BlocSelector<ListingDetailBloc, ListingDetailState, _ListingDetailData>` instances with custom data classes

**Data Classes**:
```dart
class _ListingDetailIconsData {
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final ListingDetail? listingDetail;
  
  // Custom equality and hashCode for efficient comparison
}

class _ListingDetailBodyData {
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final ListingDetail? listingDetail;
  
  // Custom equality and hashCode for efficient comparison
}
```

**Optimization**: 
- Icons section only rebuilds when loading state, error state, or listing detail ID changes
- Body section only rebuilds when loading state, error state, or listing detail ID changes

## Implementation Pattern

All optimizations follow the same pattern:

1. **Create a custom data class** that contains only the data needed by the widget
2. **Implement custom equality and hashCode** methods for efficient comparison
3. **Use BlocSelector** with a selector function that maps the full state to the custom data class
4. **Update the builder** to work with the custom data class instead of the full state

## Performance Impact

- **Reduced Rebuilds**: Widgets now only rebuild when their specific data dependencies change
- **Better User Experience**: Smoother animations and interactions
- **Lower CPU Usage**: Less unnecessary widget recreation
- **Optimized Memory**: Better memory management through targeted updates

## Best Practices Applied

1. **Custom Data Classes**: Each widget has its own data class with only necessary fields
2. **Efficient Equality**: Custom `==` and `hashCode` methods for optimal comparison
3. **Separation of Concerns**: Clear separation between data selection and UI building
4. **Consistent Pattern**: All optimizations follow the same implementation approach

## Future Considerations

- Monitor performance improvements in production
- Consider applying similar optimizations to other state management patterns
- Evaluate if some widgets could benefit from even more granular data selection
- Consider creating reusable data class patterns for common state scenarios

## Conclusion

These optimizations significantly improve the app's performance by reducing unnecessary rebuilds while maintaining clean, maintainable code. The use of `BlocSelector` with custom data classes provides a robust foundation for efficient state management throughout the application.
