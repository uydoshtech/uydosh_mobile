# Price Badge Widget

A reusable Flutter widget for displaying price information in a consistent and customizable way across the application.

## Overview

The `PriceBadge` widget provides a standardized way to display prices throughout the app, replacing the previously hardcoded price containers in listing tiles and detail screens. It follows the same design pattern as the existing `ListingTypeBadge` widget.

## Components

### 1. PriceBadge
The main widget for displaying prices with badge styling.

**Features:**
- Customizable currency symbol (defaults to '$')
- Active/inactive state with different colors
- Optional icon display
- Customizable font size and padding
- Consistent styling with the app's design system

**Usage:**
```dart
PriceBadge(
  price: 500,
  isActive: true,
  fontSize: 12,
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
)
```

### 2. CompactPriceBadge
A smaller version of the price badge for tight spaces.

**Usage:**
```dart
CompactPriceBadge(
  price: 450,
  fontSize: 10,
)
```

### 3. PriceText
Simple text display without badge styling.

**Usage:**
```dart
PriceText(
  price: 650,
  showCurrency: true,
)
```

### 4. PriceHelper
Utility class for price formatting operations.

**Available Methods:**
- `formatPrice(int price)` - Basic price formatting
- `formatPriceWithSeparators(int price)` - Adds thousand separators
- `formatPriceWithCurrency(int price, {String currencySymbol})` - Formats with currency
- `formatPriceWithSeparatorsAndCurrency(int price, {String currencySymbol})` - Combines both
- `getPriceLabel(BuildContext context)` - Gets localized price label

## Implementation Details

### Where It's Used

1. **ListingTile** - Main listing display component
2. **ListingDetailScreen** - Individual listing detail view
3. **SearchResultsScreen** - Search results (via ListingTile)
4. **FavoritesScreen** - User's favorite listings (via ListingTile)
5. **UserListingsScreen** - User's own listings (via ListingTile)
6. **HomeScreen** - Home screen listings (via ListingTile)

### Benefits

1. **Consistency** - All price displays now use the same styling and behavior
2. **Maintainability** - Price styling changes can be made in one place
3. **Reusability** - Easy to add price displays to new components
4. **Customization** - Flexible parameters for different use cases
5. **Accessibility** - Consistent text sizing and color contrast

### Customization Options

- **price** (required): The price amount to display
- **showCurrency** (default: true): Whether to show the currency symbol
- **showIcon** (default: false): Whether to show a money icon
- **fontSize**: Custom font size for the price text
- **padding**: Custom padding around the badge
- **isActive** (default: true): Whether the listing is active
- **currencySymbol**: Custom currency symbol (defaults to '$')
- **activeColor**: Custom color for active state
- **inactiveColor**: Custom color for inactive state

## Migration

The widget has been automatically integrated into existing components:

- ✅ `ListingTile` - Updated to use `PriceBadge`
- ✅ `ListingDetailScreen` - Updated to use `PriceBadge`
- ✅ All screens using `ListingTile` automatically benefit from the new widget

No manual changes are required in existing code.

## Examples

See `price_badge_examples.dart` for comprehensive usage examples and demonstrations of all available features.

## Future Enhancements

The widget is designed to be easily extensible for future needs:

- Support for different currencies
- Price range indicators
- Animated price changes
- Localization for different price formats
- Accessibility improvements
