import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";

class FullScreenPhotoViewer extends StatefulWidget {

  const FullScreenPhotoViewer({
    required this.photoUrls, required this.initialIndex, super.key,
    this.baseUrl,
  });
  final List<String> photoUrls;
  final int initialIndex;
  final String? baseUrl;

  @override
  State<FullScreenPhotoViewer> createState() => _FullScreenPhotoViewerState();
}

class _FullScreenPhotoViewerState extends State<FullScreenPhotoViewer>
    with TickerProviderStateMixin {
  late PageController _pageController;
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier(0);
  final ValueNotifier<Offset> _dragOffsetNotifier = ValueNotifier(Offset.zero);
  late AnimationController _dismissAnimationController;
  late Animation<double> _dismissAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndexNotifier.value = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Initialize dismiss animation
    _dismissAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _dismissAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _dismissAnimationController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _currentIndexNotifier.dispose();
    _dragOffsetNotifier.dispose();
    _pageController.dispose();
    _dismissAnimationController.dispose();
    super.dispose();
  }

  String _buildPhotoUrl(String photoUrl) {
    if (photoUrl.startsWith("http://") || photoUrl.startsWith("https://")) {
      return photoUrl;
    }

    if (widget.baseUrl != null) {
      return "${widget.baseUrl}$photoUrl";
    }

    // Default base URL if none provided
    return "${EnvironmentUtil.basePath}$photoUrl";
  }

  void _onPageChanged(int index) {
    _currentIndexNotifier.value = index;
  }

  void _onVerticalDragStart(DragStartDetails details) {
    _dragOffsetNotifier.value = Offset.zero;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (details.delta.dy > 0) {
      _dragOffsetNotifier.value =
          _dragOffsetNotifier.value + details.delta;
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    final offset = _dragOffsetNotifier.value;
    if (offset.dy > 100) {
      _dismissViewer();
    } else {
      _dragOffsetNotifier.value = Offset.zero;
    }
  }

  Future<void> _dismissViewer() async {
    await _dismissAnimationController.forward();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onVerticalDragStart: _onVerticalDragStart,
          onVerticalDragUpdate: _onVerticalDragUpdate,
          onVerticalDragEnd: _onVerticalDragEnd,
          child: AnimatedBuilder(
            animation: _dismissAnimation,
            builder: (context, child) {
              return ValueListenableBuilder<Offset>(
                valueListenable: _dragOffsetNotifier,
                builder: (context, dragOffset, _) {
                  return Transform.translate(
                    offset: dragOffset,
                    child: Transform.scale(
                      scale: _dismissAnimation.value,
                      child: Opacity(
                        opacity: _dismissAnimation.value,
                        child: Stack(
                          children: [
                            // Photo PageView
                            PageView.builder(
                          controller: _pageController,
                          onPageChanged: _onPageChanged,
                          itemCount: widget.photoUrls.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                // Optional: Close on tap
                              },
                              child: InteractiveViewer(
                                minScale: 0.5,
                                maxScale: 3.0,
                                child: Center(
                                  child: CachedNetworkImage(
                                    imageUrl: _buildPhotoUrl(
                                      widget.photoUrls[index],
                                    ),
                                    fit: BoxFit.contain,
                                    memCacheWidth: 1080,
                                    memCacheHeight: 1080,
                                    fadeInDuration: const Duration(
                                      milliseconds: 300,
                                    ),
                                    fadeInCurve: Curves.easeOut,
                                    placeholder:
                                        (context, url) => Container(
                                          color: Colors.grey[900],
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 3,
                                            ),
                                          ),
                                        ),
                                    errorWidget:
                                        (context, url, error) => Container(
                                          color: Colors.grey[900],
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ThemeIcon(
                                                Icons.image_not_supported,
                                                color: Colors.grey[600],
                                                size: 64,
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                L10n.get("image_load_error"),
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Top bar with close button and photo counter
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: ValueListenableBuilder<int>(
                            valueListenable: _currentIndexNotifier,
                            builder: (context, currentIndex, _) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.7),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Photo counter
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.5,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        "${currentIndex + 1} / ${widget.photoUrls.length}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),

                                    const Spacer(),

                                    // Close button
                                    ThreeDAppBarIconButton(
                                      iconData: Icons.close,
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      semanticsLabel:
                                          MaterialLocalizations.of(context)
                                              .closeButtonTooltip,
                                      borderRadius:
                                          const BorderRadius.all(
                                        Radius.circular(999),
                                      ),
                                      iconSize: 20,
                                      contentSlotSize: 24,
                                      padding: const EdgeInsets.all(6),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        // Bottom navigation arrows (if multiple photos)
                        if (widget.photoUrls.length > 1)
                          ValueListenableBuilder<int>(
                            valueListenable: _currentIndexNotifier,
                            builder: (context, currentIndex, _) {
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // Previous button
                                  if (currentIndex > 0)
                            Positioned(
                              left: 16,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {
                                    _pageController.previousPage(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.5,
                                      ),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: const ThemeIcon(
                                      Icons.chevron_left,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                                  // Next button
                                  if (currentIndex < widget.photoUrls.length - 1)
                            Positioned(
                              right: 16,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {
                                    _pageController.nextPage(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.5,
                                      ),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: const ThemeIcon(
                                      Icons.chevron_right,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    ),
  ),
    );
  }
}
