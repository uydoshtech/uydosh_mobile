// dart format width=100

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsIconGen {
  const $AssetsIconGen();

  /// Directory path: assets/icon/components
  $AssetsIconComponentsGen get components => const $AssetsIconComponentsGen();

  /// File path: assets/icon/new_icon.jpg
  AssetGenImage get newIcon => const AssetGenImage('assets/icon/new_icon.jpg');

  /// List of all assets
  List<AssetGenImage> get values => [newIcon];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/ios_dark_rd_ctn.svg
  String get iosDarkRdCtn => 'assets/images/ios_dark_rd_ctn.svg';

  /// File path: assets/images/ios_neutral_rd_ctn.svg
  String get iosNeutralRdCtn => 'assets/images/ios_neutral_rd_ctn.svg';

  /// File path: assets/images/tashkent_subway_map_simple.svg
  String get tashkentSubwayMapSimple => 'assets/images/tashkent_subway_map_simple.svg';

  /// File path: assets/images/vector_orig.svg
  String get vectorOrig => 'assets/images/vector_orig.svg';

  /// List of all assets
  List<String> get values => [iosDarkRdCtn, iosNeutralRdCtn, tashkentSubwayMapSimple, vectorOrig];
}

class $AssetsIconComponentsGen {
  const $AssetsIconComponentsGen();

  /// File path: assets/icon/components/chimney.svg
  String get chimney => 'assets/icon/components/chimney.svg';

  /// File path: assets/icon/components/red_roof.svg
  String get redRoof => 'assets/icon/components/red_roof.svg';

  /// File path: assets/icon/components/square.svg
  String get square => 'assets/icon/components/square.svg';

  /// File path: assets/icon/components/u_letter.svg
  String get uLetter => 'assets/icon/components/u_letter.svg';

  /// List of all assets
  List<String> get values => [chimney, redRoof, square, uLetter];
}

class Assets {
  const Assets._();

  static const $AssetsIconGen icon = $AssetsIconGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName, {this.size, this.flavors = const {}, this.animation});

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
