# Common Components

This directory contains reusable components that provide centralized control over your app's appearance and behavior.

## Components

### 1. CommonAppBar
Centralized control over AppBar appearance across all screens.

```dart
import 'package:uy_dosh/presentation/widgets/common/index.dart';

// Basic usage
appBar: CommonAppBar(
  title: 'Screen Title',
  showBackButton: true,
),

// Custom styling
appBar: CommonAppBar(
  title: 'Custom Title',
  backgroundColor: Colors.blue,
  foregroundColor: Colors.white,
  centerTitle: false,
),
```

### 2. CommonStateBuilder
Consistent loading, error, and empty states across all screens.

```dart
// Loading state
CommonStateBuilder(
  isLoading: true,
  hasError: false,
  isEmpty: false,
  child: YourContent(),
)

// Error state
CommonStateBuilder(
  isLoading: false,
  hasError: true,
  errorMessage: 'Something went wrong',
  child: YourContent(),
)

// Empty state
CommonStateBuilder(
  isLoading: false,
  hasError: false,
  isEmpty: true,
  emptyMessage: 'No items found',
  emptySubtitle: 'Try refreshing',
  emptyIcon: Icons.inbox_outlined,
  child: YourContent(),
)
```

### 3. CommonListView
Consistent list behavior with built-in spacing and refresh support.

```dart
CommonListView(
  children: yourWidgets,
  padding: EdgeInsets.all(16.0),
  showRefreshIndicator: true,
  onRefresh: () async { /* refresh logic */ },
  showLoadMoreIndicator: true,
  hasMore: true,
  itemSpacing: 16.0,
)
```

## Benefits

- **Centralized Control**: Change colors, spacing, fonts in one place
- **Consistency**: All screens automatically follow app standards
- **Maintainability**: Fix bugs or update design in one location
- **Developer Experience**: New screens automatically follow app standards

## Usage Example

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'My Screen',
        showBackButton: true,
      ),
      body: CommonStateBuilder(
        isLoading: false,
        hasError: false,
        isEmpty: false,
        child: CommonListView(
          children: myItems,
          showRefreshIndicator: true,
          onRefresh: () async { /* refresh */ },
        ),
      ),
    );
  }
}
```
