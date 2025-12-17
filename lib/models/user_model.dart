enum AccountType {
  personal,
  business;

  String toJson() => name;
  static AccountType fromJson(String json) {
    return AccountType.values.firstWhere((e) => e.name == json);
  }
}

class UserModel {
  final String name;
  final String phone;
  final String? photoPath;
  final bool showDate;
  final AccountType accountType;
  final bool isOnboardingComplete;
  final String aboutYourself;
  final String contactDetails;
  final String organizationDetails;

  UserModel({
    required this.name,
    required this.phone,
    this.photoPath,
    this.showDate = true,
    this.accountType = AccountType.personal,
    this.isOnboardingComplete = false,
    this.aboutYourself = '',
    this.contactDetails = '',
    this.organizationDetails = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'photoPath': photoPath,
      'showDate': showDate,
      'accountType': accountType.toJson(),
      'isOnboardingComplete': isOnboardingComplete,
      'aboutYourself': aboutYourself,
      'contactDetails': contactDetails,
      'organizationDetails': organizationDetails,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      photoPath: json['photoPath'],
      showDate: json['showDate'] ?? true,
      accountType: json['accountType'] != null 
          ? AccountType.fromJson(json['accountType'])
          : AccountType.personal,
      isOnboardingComplete: json['isOnboardingComplete'] ?? false,
      aboutYourself: json['aboutYourself'] ?? '',
      contactDetails: json['contactDetails'] ?? '',
      organizationDetails: json['organizationDetails'] ?? '',
    );
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? photoPath,
    bool? showDate,
    AccountType? accountType,
    bool? isOnboardingComplete,
    String? aboutYourself,
    String? contactDetails,
    String? organizationDetails,
  }) {
    return UserModel(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoPath: photoPath ?? this.photoPath,
      showDate: showDate ?? this.showDate,
      accountType: accountType ?? this.accountType,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      aboutYourself: aboutYourself ?? this.aboutYourself,
      contactDetails: contactDetails ?? this.contactDetails,
      organizationDetails: organizationDetails ?? this.organizationDetails,
    );
  }
}
