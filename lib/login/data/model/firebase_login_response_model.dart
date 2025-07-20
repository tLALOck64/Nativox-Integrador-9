class FirebaseLoginResponseModel {
  final bool success;
  final String message;
  final FirebaseLoginDataModel data;

  const FirebaseLoginResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory FirebaseLoginResponseModel.fromJson(Map<String, dynamic> json) {
    return FirebaseLoginResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: FirebaseLoginDataModel.fromJson(json['data'] ?? {}),
    );
  }
}

class FirebaseLoginDataModel {
  final String token;
  final String expiresAt;
  final FirebaseUserModel user;

  const FirebaseLoginDataModel({
    required this.token,
    required this.expiresAt,
    required this.user,
  });

  factory FirebaseLoginDataModel.fromJson(Map<String, dynamic> json) {
    return FirebaseLoginDataModel(
      token: json['token'] ?? '',
      expiresAt: json['expiresAt'] ?? '',
      user: FirebaseUserModel.fromJson(json['user'] ?? {}),
    );
  }
}

class FirebaseUserModel {
  final String uid;
  final String email;
  final String displayName;
  final String phoneNumber;
  final bool emailVerified;

  const FirebaseUserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.phoneNumber,
    required this.emailVerified,
  });

  factory FirebaseUserModel.fromJson(Map<String, dynamic> json) {
    return FirebaseUserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      emailVerified: json['emailVerified'] ?? false,
    );
  }
}
