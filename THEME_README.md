# UyDosh Theme System

This document explains how to use the new dual-theme system in the UyDosh app.

## Overview

The app now supports two visual themes:

1. **Purple Theme** (Original) - The default theme with deep purple colors
2. **Blue Theme** (New) - A new theme using the two blue colors from your image:
   - Primary: `#3A7BBF` (Medium blue from inner square)
   - Secondary: `#70C0C8` (Light teal from outer square)

## How to Use

### 1. Theme Switcher Button
- Look for the **palette icon** (🎨) in the top-right corner of the splash screen
- Tap it to open the theme selection dialog
- Choose between "Purple Theme" and "Blue Theme"
- Tap "Apply Theme" to switch

### 2. Theme Comparison
- Look for the **compare icon** (⚖️) next to the theme switcher
- Tap it to open a side-by-side comparison of both themes
- This shows how various UI components look in each theme

### 3. Theme Preview
- The theme preview screen shows how the selected theme looks with:
  - Buttons (Elevated, Outlined, Text)
  - Cards and list items
  - Input fields
  - Navigation elements
  - Color palette

## Theme Features

### Purple Theme (Original)
- Primary: Deep purple (`#673AB7`)
- Secondary: Blue (`#2196F3`)
- Background: Dark (`#121212`)
- Surface: Dark (`#1E1E1E`)

### Blue Theme (New)
- Primary: Medium blue (`#3A7BBF`)
- Secondary: Light teal (`#70C0C8`)
- Background: Dark blue-tinted (`#0A1A2A`)
- Surface: Dark blue-tinted (`#1A2A3A`)

## Technical Details

### Files Created/Modified
- `lib/base/constants/app_colors.dart` - Added `BlueThemeColors` class
- `lib/base/constants/app_theme.dart` - New theme manager
- `lib/presentation/widgets/theme_switcher_widget.dart` - Theme switching UI
- `lib/presentation/screens/theme_preview/theme_preview_screen.dart` - Theme preview
- `lib/presentation/screens/theme_preview/theme_comparison_screen.dart` - Side-by-side comparison
- `lib/main.dart` - Modified to support theme switching

### Theme Switching
The app uses a stateful `MyApp` widget that can switch themes dynamically. The theme change is propagated through the widget tree, allowing all screens to update their appearance immediately.

## Customization

To add more themes:

1. Create a new color class similar to `BlueThemeColors`
2. Add the theme to `AppTheme.getAvailableThemes()`
3. Implement the theme in `AppTheme.getTheme()`
4. Add a display name in `AppTheme.getThemeDisplayName()`

## Testing

1. Run the app: `flutter run`
2. On the splash screen, tap the palette icon (🎨)
3. Select "Blue Theme" and tap "Apply Theme"
4. Navigate through the app to see the new theme
5. Use the compare icon (⚖️) to see both themes side by side

## Notes

- The blue theme maintains the same dark aesthetic as the purple theme
- All UI components automatically adapt to the selected theme
- Theme switching is immediate and affects the entire app
- The theme system is extensible for future themes
