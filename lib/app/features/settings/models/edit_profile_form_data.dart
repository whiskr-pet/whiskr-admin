class EditProfileFormData {
  final String businessName;
  final String phoneNumber;
  final String description;
  final String email;
  final String website;

  const EditProfileFormData({
    required this.businessName,
    required this.phoneNumber,
    required this.description,
    required this.email,
    required this.website,
  });

  EditProfileFormData copyWith({
    String? businessName,
    String? phoneNumber,
    String? description,
    String? email,
    String? website,
  }) {
    return EditProfileFormData(
      businessName: businessName ?? this.businessName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      description: description ?? this.description,
      email: email ?? this.email,
      website: website ?? this.website,
    );
  }
}

