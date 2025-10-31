# UyDosh - Find Your Perfect Home 🏠

A modern Flutter application for finding and connecting with property listings in Uzbekistan. UyDosh provides a seamless experience for users to discover rooms, apartments, and shared living spaces with integrated metro station information.

## 🌟 Features

### **Core Functionality**
- **Property Listings**: Browse thousands of active property listings
- **Metro Station Integration**: Find properties near specific metro stations
- **Infinite Scroll**: Smooth pagination for browsing large datasets
- **Pull-to-Refresh**: Update listings with a simple swipe gesture
- **Phone Call Integration**: Direct contact with property owners

### **User Experience**
- **Beautiful Onboarding**: 3-screen onboarding with smooth page indicators
- **Splash Screen**: Animated loading screen with app branding
- **Modern Navigation**: Curved navigation bar with smooth animations
- **Responsive Design**: Optimized for both iOS and Android devices

### **Property Details**
- **Comprehensive Information**: Title, price, description, location
- **Listing Types**: Room available, roommate needed with color-coded badges
- **Location Details**: District and nearest metro station information
- **Contact Information**: Direct phone call functionality to property owners
- **Creation Date**: When the listing was posted

### **Metro Station Features**
- **Line-based Filtering**: Browse stations by metro line (1-4)
- **Color-coded Lines**: 
  - Line 1: Red
  - Line 2: Blue  
  - Line 3: Green
  - Line 4: Yellow
- **Station-specific Listings**: View all properties near selected stations

## 🏗️ Architecture

### **State Management**
- **BLoC Pattern**: Clean separation of business logic and UI
- **flutter_bloc**: Reactive state management
- **bloc_concurrency**: Advanced event handling

### **Dependency Injection**
- **GetIt**: Service locator for dependency management
- **Injectable**: Code generation for dependency injection
- **Modular Architecture**: Clean separation of concerns

### **API Integration**
- **Dio**: HTTP client with interceptors
- **Pretty Dio Logger**: Beautiful API request/response logging
- **Error Handling**: Comprehensive error management
- **OAuth Support**: Authentication ready

### **Data Models**
- **Freezed**: Immutable data classes with JSON serialization
- **Type Safety**: Compile-time safety with generated code
- **Pagination Support**: PageableResponse for infinite scroll

## 📱 Screens

### **Onboarding Screens**
1. **Find Your Perfect Home**: Custom composite image with search functionality
2. **Metro Stations Nearby**: Train icon with location-based filtering
3. **Easy & Secure**: Security icon with trust indicators

### **Main Navigation**
1. **Home Tab**: Property listings with infinite scroll
2. **Metro Tab**: Metro line selection with station browsing
3. **History Tab**: Previously viewed listings (placeholder)

### **Detail Screens**
- **Listing Detail**: Comprehensive property information
- **Station Listings**: Properties filtered by metro station

## 🎨 Design System

### **Color Scheme**
- **Primary**: Deep Purple (#673AB7)
- **Background**: Deep Purple theme
- **Accent Colors**: Green for success, Red for location pins
- **Metro Lines**: Red, Blue, Green, Yellow

### **Typography**
- **Headings**: Bold, 18-28px
- **Body Text**: Regular, 14-16px
- **Captions**: Medium, 10-12px

### **Components**
- **Cards**: Rounded corners with consistent padding
- **Buttons**: Rounded with proper touch targets
- **Icons**: Material Design icons with semantic colors
- **Animations**: Smooth transitions and micro-interactions

## 🚀 Getting Started

### **Prerequisites**
- Flutter SDK (>=3.7.0)
- Dart SDK (>=3.0.0)
- iOS Simulator or Android Emulator
- Physical device for testing phone calls

### **Installation**

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd uydosh
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

### **iOS Setup**
- Open `ios/Runner.xcworkspace` in Xcode
- Configure signing and capabilities
- Run on iOS Simulator or device

### **Android Setup**
- Open `android/` in Android Studio
- Configure signing if needed
- Run on Android Emulator or device

## 📁 Project Structure

```
lib/
├── base/                    # Core infrastructure
│   ├── api/                # API client and configuration
│   │   ├── client/         # HTTP clients (OAuth, Public)
│   │   ├── converter/      # JSON converters
│   │   ├── dto/           # Data transfer objects
│   │   └── interceptors/  # Request/response interceptors
│   ├── injection/         # Dependency injection
│   ├── localization/      # Multi-language support
│   ├── logger/           # Logging utilities
│   └── util/             # Utility classes
├── domain/               # Business logic layer
│   ├── models/          # Data models
│   └── services/        # Business services
├── presentation/         # UI layer
│   ├── blocs/          # State management
│   ├── screens/        # Application screens
│   │   ├── home/       # Home screen
│   │   ├── metro/      # Metro screen
│   │   ├── listing_detail/ # Detail screens
│   │   └── onboarding/ # Onboarding screens
│   └── router/         # Navigation configuration
└── main.dart           # Application entry point
```

## 🔧 Configuration

### **API Endpoints**
- **Base URL**: Configured in `lib/base/util/environment_util.dart` (default: `http://3.140.249.173:3000`)
- **Listings**: `/listings?page=1&limit=10&isActive=true`
- **Listing Detail**: `/listings/{id}`
- **Metro Stations**: `/subway-stations`
- **Station Listings**: `/listings/search?subwayStationId={id}`

### **Environment Variables**
- Configure API base URL in `lib/base/util/environment_util.dart`
- Set up OAuth credentials if needed
- Configure logging levels

## 📊 Dependencies

### **Core Dependencies**
- `flutter_bloc`: State management
- `dio`: HTTP client
- `get_it`: Dependency injection
- `freezed`: Immutable data classes
- `json_annotation`: JSON serialization

### **UI Dependencies**
- `curved_navigation_bar`: Animated navigation
- `smooth_page_indicator`: Onboarding indicators
- `flutter_localizations`: Multi-language support

### **Development Dependencies**
- `build_runner`: Code generation
- `freezed`: Model generation
- `injectable_generator`: DI generation

## 🧪 Testing

### **Unit Tests**
```bash
flutter test
```

### **Widget Tests**
```bash
flutter test test/widget_test.dart
```

### **Integration Tests**
```bash
flutter drive --target=test_driver/app.dart
```

## 📱 Platform Support

### **iOS**
- **Minimum Version**: iOS 12.0
- **Features**: Full support including phone calls
- **Architecture**: ARM64, x86_64

### **Android**
- **Minimum Version**: API 21 (Android 5.0)
- **Features**: Full support including phone calls
- **Architecture**: ARM, ARM64, x86, x86_64

## 🔄 State Management

### **BLoC Pattern**
- **ListingsBloc**: Manages property listings with pagination
- **ListingDetailBloc**: Handles individual listing details
- **SubwayStationsBloc**: Metro station data management

### **Events & States**
- **Events**: User actions (fetch, load more, refresh)
- **States**: UI states (loading, loaded, error)
- **Streams**: Reactive data flow

## 🌐 Localization

### **Supported Languages**
- **Russian**: Primary language
- **English**: Secondary language
- **Uzbek**: Local language

### **Localization Files**
- `lib/base/localization/intl/intl_ru.arb`
- `lib/base/localization/intl/intl_en.arb`
- `lib/base/localization/intl/intl_uz.arb`

## 🔐 Security

### **API Security**
- **HTTPS**: All API calls use secure connections
- **Error Handling**: Comprehensive error management
- **Input Validation**: Client-side validation

### **Data Privacy**
- **Local Storage**: Minimal local data storage
- **Network Security**: Secure API communication
- **User Privacy**: No unnecessary data collection

## 🚀 Deployment

### **iOS App Store**
1. Configure signing in Xcode
2. Update version in `ios/Runner/Info.plist`
3. Archive and upload to App Store Connect

### **Google Play Store**
1. Configure signing in Android Studio
2. Update version in `android/app/build.gradle`
3. Build APK/AAB and upload to Play Console

## 🤝 Contributing

### **Development Workflow**
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

### **Code Style**
- Follow Dart/Flutter conventions
- Use meaningful variable names
- Add comments for complex logic
- Keep functions small and focused

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team**: For the amazing framework
- **BLoC Team**: For state management solution
- **Dio Team**: For HTTP client library
- **Material Design**: For design guidelines

## 📞 Support

For support and questions:
- **Email**: support@uydosh.com
- **GitHub Issues**: [Create an issue](https://github.com/your-repo/issues)
- **Documentation**: [Wiki](https://github.com/your-repo/wiki)

---

**Made with ❤️ for the people of Uzbekistan**
# Test commit for version bump
