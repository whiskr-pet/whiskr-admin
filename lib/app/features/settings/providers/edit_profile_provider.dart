import 'package:flutter/material.dart';
import 'package:whiskr_admin_panel/app/features/settings/models/edit_profile_form_data.dart';

class EditProfileProvider extends ChangeNotifier {
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;

  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  EditProfileFormData get currentFormData => EditProfileFormData(
        businessName: businessNameController.text,
        phoneNumber: phoneController.text,
        description: descriptionController.text,
        email: emailController.text,
        website: websiteController.text,
      );

  void setInitialValues({
    required String? businessName,
    required String? phoneNumber,
    required String? description,
    required String? email,
    required String? website,
  }) {
    businessNameController.text = businessName ?? '';
    phoneController.text = phoneNumber ?? '';
    descriptionController.text = description ?? '';
    emailController.text = email ?? '';
    websiteController.text = website ?? '';
  }

  Future<void> submit() async {
    _errorMessage = null;
    _isSubmitting = true;
    notifyListeners();

    try {
      final EditProfileFormData formData = currentFormData;
      // Intentionally unused for now - will be mapped to Swagger DTO when API is provided.
      // ignore: unused_local_variable
      final EditProfileFormData debugSnapshot = formData;
      throw UnimplementedError('Edit Profile API not integrated yet.');
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    businessNameController.dispose();
    phoneController.dispose();
    descriptionController.dispose();
    emailController.dispose();
    websiteController.dispose();
    super.dispose();
  }
}

