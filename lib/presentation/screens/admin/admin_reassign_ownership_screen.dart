import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/services/admin_entity_ownership_service.dart";
import "package:uy_dosh/presentation/widgets/common/keyboard_dismiss_scope.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";

class AdminReassignOwnershipScreen extends StatefulWidget {
  const AdminReassignOwnershipScreen({super.key});

  @override
  State<AdminReassignOwnershipScreen> createState() =>
      _AdminReassignOwnershipScreenState();
}

class _AdminReassignOwnershipScreenState
    extends State<AdminReassignOwnershipScreen> {
  final IAdminEntityOwnershipService _service =
      getIt<IAdminEntityOwnershipService>();

  final _entityIdController = TextEditingController();
  final _fromUserController = TextEditingController();
  final _toUserController = TextEditingController();

  AdminEntityOwnershipType _entityType = AdminEntityOwnershipType.listing;
  bool _submitting = false;

  @override
  void dispose() {
    _entityIdController.dispose();
    _fromUserController.dispose();
    _toUserController.dispose();
    super.dispose();
  }

  int? _tryParseOptionalUserId(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return null;
    final n = int.tryParse(t);
    if (n == null || n < 1) return -1;
    return n;
  }

  int? _tryParseRequiredPositive(String raw) {
    final n = int.tryParse(raw.trim());
    if (n == null || n < 1) return null;
    return n;
  }

  Future<void> _submit() async {
    if (_submitting) return;

    final entityId = _tryParseRequiredPositive(_entityIdController.text);
    final toUserId = _tryParseRequiredPositive(_toUserController.text);
    if (entityId == null) {
      ToastTheme.showErrorSimple(
        context,
        message: L10n.get("admin_reassign_ownership_entity_id_label"),
      );
      return;
    }
    if (toUserId == null) {
      ToastTheme.showErrorSimple(
        context,
        message: L10n.get("admin_reassign_ownership_to_user_label"),
      );
      return;
    }

    final fromParsed = _tryParseOptionalUserId(_fromUserController.text);
    if (fromParsed == -1) {
      ToastTheme.showErrorSimple(
        context,
        message: L10n.get("admin_reassign_ownership_from_user_label"),
      );
      return;
    }

    HapticFeedbackUtils.impact();
    setState(() => _submitting = true);
    try {
      await _service.reassignOwnership(
        entityType: _entityType,
        entityId: entityId,
        toUserId: toUserId,
        fromUserId: fromParsed,
      );
      if (!mounted) return;
      ToastTheme.showSuccessSimple(
        context,
        message: L10n.get("admin_reassign_ownership_success"),
      );
    } catch (e) {
      if (!mounted) return;
      var msg = e.toString();
      if (msg.startsWith("Exception: ")) {
        msg = msg.substring("Exception: ".length);
      }
      ToastTheme.showErrorSimple(context, message: msg);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  String _labelForType(AdminEntityOwnershipType t) {
    switch (t) {
      case AdminEntityOwnershipType.listing:
        return L10n.get("admin_reassign_ownership_type_listing");
      case AdminEntityOwnershipType.gigOffer:
        return L10n.get("admin_reassign_ownership_type_gig_offer");
      case AdminEntityOwnershipType.gigRequest:
        return L10n.get("admin_reassign_ownership_type_gig_request");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: UydoshAppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: Text(
          L10n.get("admin_reassign_ownership_title"),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: KeyboardDismissScope(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              L10n.get("admin_reassign_ownership_intro"),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<AdminEntityOwnershipType>(
              value: _entityType,
              decoration: InputDecoration(
                labelText: L10n.get("admin_reassign_ownership_entity_type_label"),
                border: const OutlineInputBorder(),
              ),
              items: AdminEntityOwnershipType.values
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(_labelForType(t)),
                    ),
                  )
                  .toList(),
              onChanged: _submitting
                  ? null
                  : (v) {
                      if (v != null) {
                        setState(() => _entityType = v);
                      }
                    },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _entityIdController,
              enabled: !_submitting,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: L10n.get("admin_reassign_ownership_entity_id_label"),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _fromUserController,
              enabled: !_submitting,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: L10n.get("admin_reassign_ownership_from_user_label"),
                hintText: L10n.get("admin_reassign_ownership_from_user_hint"),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _toUserController,
              enabled: !_submitting,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: L10n.get("admin_reassign_ownership_to_user_label"),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButtonFactory.text(
              onPressed: _submitting ? null : _submit,
              text: L10n.get("admin_reassign_ownership_submit"),
              isLoading: _submitting,
            ),
          ],
        ),
      ),
    );
  }
}
