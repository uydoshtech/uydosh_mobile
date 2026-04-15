import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/error_message_helper.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/domain/models/complaint.dart";
import "package:uy_dosh/domain/models/complaint_category.dart";
import "package:uy_dosh/presentation/blocs/complaint_bloc.dart";
import "package:uy_dosh/presentation/widgets/common/common_list_view.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_radio_tile.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";

class CreateComplaintScreen extends StatefulWidget {

  const CreateComplaintScreen({required this.listingId, super.key});
  final int listingId;

  @override
  State<CreateComplaintScreen> createState() => _CreateComplaintScreenState();
}

class _CreateComplaintScreenState extends State<CreateComplaintScreen> {
  ComplaintCategory? _selectedCategory;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<ComplaintBloc>().add(
      const ComplaintEvent.fetchComplaintCategories(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UydoshAppBar(
        title: Text(
          L10n.get("create_complaint"),
        ),
        leading: ThreeDAppBarIconButton.backLeading(
          context,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocListener<ComplaintBloc, ComplaintState>(
        listener: (context, state) {
          state.map(
            initial: (_) {},
            loading: (_) {
              if (!_isSubmitting) {
                setState(() {
                  _isSubmitting = true;
                });
              }
            },
            categoriesLoaded: (state) {
              setState(() {
                _isSubmitting = false;
              });
            },
            complaintCreated: (state) {
              setState(() {
                _isSubmitting = false;
              });
              ToastTheme.showSuccess(
                context,
                message: L10n.get("complaint_created_success"),
              );
              Navigator.of(context).pop(true);
            },
            complaintsLoaded: (_) {},
            complaintUpdated: (_) {},
            complaintDeleted: (_) {},
            error: (state) {
              setState(() {
                _isSubmitting = false;
              });

              logger.d(
                "=== COMPLAINT UI: Error state message: ${state.message} ===",
              );

              // The bloc now provides localized messages directly
              String errorMessage;
              if (state.message.startsWith("DIO_ERROR_")) {
                // Handle other Dio errors with ErrorMessageHelper
                errorMessage = ErrorMessageHelper.sanitizeErrorMessage(
                  state.message,
                  context: context,
                );
              } else {
                // Use the message directly (already localized for 409 errors)
                errorMessage = state.message;
              }

              logger.d(
                "=== COMPLAINT UI: Final error message: $errorMessage ===",
              );

              ToastTheme.showError(context, message: errorMessage);
            },
          );
        },
        child: BlocBuilder<ComplaintBloc, ComplaintState>(
          builder: (context, state) {
            logger.d(
              "=== COMPLAINT UI: Current state: ${state.runtimeType} ===",
            );
            return state.map(
              initial: (_) {
                logger.d("=== COMPLAINT UI: Initial state ===");
                return const Center(child: CircularProgressIndicator());
              },
              loading: (_) {
                logger.d("=== COMPLAINT UI: Loading state ===");
                return const Center(child: CircularProgressIndicator());
              },
              categoriesLoaded: (state) {
                logger.d(
                  "=== COMPLAINT UI: Categories loaded: ${state.categories.length} ===",
                );
                return _buildContent(state.categories);
              },
              complaintCreated: (_) => const SizedBox.shrink(),
              complaintsLoaded: (_) => const SizedBox.shrink(),
              complaintUpdated: (_) => const SizedBox.shrink(),
              complaintDeleted: (_) => const SizedBox.shrink(),
              error:
                  (state) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const ThemeIcon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        GhostButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            L10n.get("back_to_listing"),
                          ),
                        ),
                      ],
                    ),
                  ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(List<ComplaintCategory> categories) {
    final textBaseSize = Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Expanded(
            child: CommonListView(
              padding: EdgeInsets.zero,
              itemSpacing: 0,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];

                return UydoshRadioTile<ComplaintCategory>(
                  value: category,
                  groupValue: _selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  title: Text(_getLocalizedCategoryName(context, category)),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(minHeight: 96),
            child: WheelPickerPlateContainer(
              theme: Theme.of(context),
              child: TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: L10n.get("complaint_description_hint"),
                  hintStyle: TextStyle(
                    fontSize: textBaseSize + 2,
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant.withOpacity(0.7)
                            : Colors.grey[400],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  alignLabelWithHint: true,
                ),
                style: TextStyle(
                  fontSize: textBaseSize + 2,
                  color:
                      ThemeState().isLightTheme
                          ? Colors.black
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _selectedCategory != null && !_isSubmitting
                      ? _submitComplaint
                      : null,
              child:
                  _isSubmitting
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Text(
L10n.get("submit_complaint"),
                      ),
            ),
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  void _submitComplaint() {
    if (_selectedCategory == null) return;

    final descriptionText = _descriptionController.text.trim();
    final request = CreateComplaintRequest(
      listingId: widget.listingId,
      categoryId: _selectedCategory!.id!,
      text: descriptionText.isNotEmpty ? descriptionText : null,
    );

    context.read<ComplaintBloc>().add(ComplaintEvent.createComplaint(request));
  }

  String _getLocalizedCategoryName(
    BuildContext context,
    ComplaintCategory category,
  ) {
    final currentLanguage = L10n.currentLanguage;

    switch (currentLanguage) {
      case "ru":
        return category.nameRu;
      case "uz":
        return category.nameUz;
      case "en":
        return category.nameEn;
      default:
        return category.nameEn;
    }
  }
}
