import 'package:flutter/material.dart';
import 'package:uy_dosh/base/utils/haptic_feedback_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uy_dosh/presentation/blocs/complaint_bloc.dart';
import 'package:uy_dosh/base/logger/logger.dart';
import 'package:uy_dosh/domain/models/complaint.dart';
import 'package:uy_dosh/domain/models/complaint_category.dart';
import 'package:uy_dosh/presentation/widgets/language_switcher.dart';
import 'package:uy_dosh/presentation/widgets/common/theme_icon.dart';
import 'package:uy_dosh/presentation/widgets/common/ghost_button.dart';
import 'package:uy_dosh/presentation/widgets/common/uydosh_radio_tile.dart';
import 'package:uy_dosh/base/constants/app_colors.dart';
import 'package:uy_dosh/presentation/widgets/common/toast_theme.dart';
import 'package:uy_dosh/base/util/error_message_helper.dart';

class CreateComplaintScreen extends StatefulWidget {
  final int listingId;

  const CreateComplaintScreen({super.key, required this.listingId});

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
      appBar: AppBar(
        title: Text(
          LanguageAwareStringHelper.getCurrent(context, "create_complaint"),
        ),
        leading: IconButton(
          icon: const ThemeIcon(icon: Icons.arrow_back),
          onPressed: () {
            HapticFeedbackUtils.impact();
            Navigator.of(context).pop();
          },
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
                message: LanguageAwareStringHelper.getCurrent(
                  context,
                  "complaint_created_success",
                ),
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
                '=== COMPLAINT UI: Error state message: ${state.message} ===',
              );

              // The bloc now provides localized messages directly
              String errorMessage;
              if (state.message.startsWith('DIO_ERROR_')) {
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
                '=== COMPLAINT UI: Final error message: $errorMessage ===',
              );

              ToastTheme.showError(context, message: errorMessage);
            },
          );
        },
        child: BlocBuilder<ComplaintBloc, ComplaintState>(
          builder: (context, state) {
            logger.d(
              '=== COMPLAINT UI: Current state: ${state.runtimeType} ===',
            );
            return state.map(
              initial: (_) {
                logger.d('=== COMPLAINT UI: Initial state ===');
                return const Center(child: CircularProgressIndicator());
              },
              loading: (_) {
                logger.d('=== COMPLAINT UI: Loading state ===');
                return const Center(child: CircularProgressIndicator());
              },
              categoriesLoaded: (state) {
                logger.d(
                  '=== COMPLAINT UI: Categories loaded: ${state.categories.length} ===',
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
                        Icon(
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
                            LanguageAwareStringHelper.getCurrent(
                              context,
                              "back_to_listing",
                            ),
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LanguageAwareStringHelper.getCurrent(
              context,
              "select_complaint_category",
            ),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
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
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: LanguageAwareStringHelper.getCurrent(
                context,
                "complaint_description_hint",
              ),
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
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
                        LanguageAwareStringHelper.getCurrent(
                          context,
                          "submit_complaint",
                        ),
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
    final currentLanguage = LanguageAwareStringHelper.getCurrentLanguage(
      context,
    );

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
