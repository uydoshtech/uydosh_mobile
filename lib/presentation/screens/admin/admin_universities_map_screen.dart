import "package:flutter/material.dart";
import "package:uy_dosh/base/cache/university_cache.dart";
import "package:uy_dosh/base/constants/app_config.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/domain/models/university.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_error_retry_column.dart";
import "package:uy_dosh/presentation/widgets/common/yandex_map_widget.dart";

class AdminUniversitiesMapScreen extends StatefulWidget {
  const AdminUniversitiesMapScreen({super.key});

  @override
  State<AdminUniversitiesMapScreen> createState() =>
      _AdminUniversitiesMapScreenState();
}

class _AdminUniversitiesMapScreenState
    extends State<AdminUniversitiesMapScreen> {
  List<UniversityMapMarker> _markers = const [];
  bool _isLoading = true;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  Future<void> _loadMarkers({bool refresh = false}) async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      if (refresh) {
        await UniversityCache.refreshCache();
      } else if (!UniversityCache.isInitialized) {
        await UniversityCache.initialize();
      } else if (UniversityCache.shouldRefresh()) {
        await UniversityCache.refreshCache();
      }

      final language = L10n.currentLanguage;
      final markers = UniversityCache.getAllUniversities()
          .map((university) => _markerForUniversity(university, language))
          .whereType<UniversityMapMarker>()
          .toList()
        ..sort((a, b) => a.title.compareTo(b.title));

      if (!mounted) return;
      setState(() {
        _markers = markers;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error;
        _isLoading = false;
      });
    }
  }

  UniversityMapMarker? _markerForUniversity(
    University university,
    String language,
  ) {
    final latitude = double.tryParse(university.latitude ?? "");
    final longitude = double.tryParse(university.longitude ?? "");
    if (latitude == null || longitude == null) return null;

    final shortName = university.getLocalizedShortName(language);
    final fullName = university.getLocalizedName(language);
    return UniversityMapMarker(
      id: university.id.toString(),
      latitude: latitude,
      longitude: longitude,
      title: shortName.isNotEmpty ? shortName : fullName,
      fullTitle: fullName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = L10n.get("admin_universities_map_title");
    return Scaffold(
      appBar: UydoshAppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: _buildBody(title),
    );
  }

  Widget _buildBody(String title) {
    if (_isLoading) {
      return const Center(child: HouseLoadingIndicator());
    }

    if (_loadError != null) {
      return UydoshErrorRetryColumn(
        title: L10n.get("admin_universities_map_error"),
        message: _loadError.toString(),
        retryLabel: L10n.get("admin_universities_map_retry"),
        onRetry: () => _loadMarkers(refresh: true),
        padding: const EdgeInsets.all(24),
      );
    }

    if (_markers.isEmpty) {
      return UydoshErrorRetryColumn(
        icon: Icons.school_outlined,
        iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
        title: L10n.get("admin_universities_map_empty"),
        retryLabel: L10n.get("admin_universities_map_retry"),
        onRetry: () => _loadMarkers(refresh: true),
        padding: const EdgeInsets.all(24),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: YandexMapWidget(
        apiKey: AppConfig.yandexMapsApiKey,
        pins: const [],
        universityMarkers: _markers,
        title: title,
        height: double.infinity,
        showDefaultPlacemark: false,
      ),
    );
  }
}
