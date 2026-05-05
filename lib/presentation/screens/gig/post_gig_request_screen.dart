import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/state/language_state.dart";
import "package:uy_dosh/domain/models/gig/gig_category.dart";
import "package:uy_dosh/domain/models/gig/gig_request.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_post_request_bloc.dart";

class PostGigRequestScreen extends StatefulWidget {
  const PostGigRequestScreen({super.key});

  @override
  State<PostGigRequestScreen> createState() => _PostGigRequestScreenState();
}

class _PostGigRequestScreenState extends State<PostGigRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _addressController = TextEditingController();
  GigCategory? _selectedCategory;
  GigRequestBudgetType _budgetType = GigRequestBudgetType.fixed;
  bool _isRemote = false;

  @override
  void initState() {
    super.initState();
    context
        .read<GigPostRequestBloc>()
        .add(const LoadCategoriesForRequest());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Choose a category")),
      );
      return;
    }
    final budget = _budgetController.text.isEmpty
        ? null
        : int.tryParse(_budgetController.text);
    context.read<GigPostRequestBloc>().add(
          SubmitGigRequest(
            categoryId: _selectedCategory!.id,
            title: _titleController.text.trim(),
            budgetType: _budgetType,
            budgetAmount: budget,
            descriptionRu: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            addressText: _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim(),
            isRemote: _isRemote,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final language = LanguageState().currentLanguage;
    return BlocConsumer<GigPostRequestBloc, GigPostRequestState>(
      listener: (context, state) {
        if (state is GigPostRequestSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Task posted.")),
          );
          Navigator.of(context).pop();
        } else if (state is GigPostRequestError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final categories =
            state is GigPostRequestIdle ? state.categories : <GigCategory>[];
        final submitting = state is GigPostRequestSubmitting;

        return Scaffold(
          appBar: AppBar(title: const Text("Post a task")),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<GigCategory>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(labelText: "Category"),
                  items: [
                    for (final c in categories)
                      DropdownMenuItem(
                        value: c,
                        child: Text(c.localizedName(language)),
                      ),
                  ],
                  onChanged: (v) => setState(() => _selectedCategory = v),
                  validator: (v) => v == null ? "Required" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: "Title"),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? "Required" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: "Description (optional)",
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<GigRequestBudgetType>(
                        initialValue: _budgetType,
                        decoration:
                            const InputDecoration(labelText: "Budget type"),
                        items: const [
                          DropdownMenuItem(
                            value: GigRequestBudgetType.fixed,
                            child: Text("Fixed"),
                          ),
                          DropdownMenuItem(
                            value: GigRequestBudgetType.hourly,
                            child: Text("Hourly"),
                          ),
                          DropdownMenuItem(
                            value: GigRequestBudgetType.open,
                            child: Text("Open"),
                          ),
                        ],
                        onChanged: (v) => setState(
                          () => _budgetType =
                              v ?? GigRequestBudgetType.fixed,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _budgetController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Amount (UZS)",
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: "Address (optional)",
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text("Remote"),
                  value: _isRemote,
                  onChanged: (v) => setState(() => _isRemote = v),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: submitting ? null : _submit,
                    child: submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("Post task"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
