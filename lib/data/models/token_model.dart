  class TokenModel {
  final String accessToken;
  final String tokenType;
  final String? role;  // ← agregamos esto

  TokenModel({required this.accessToken, required this.tokenType, required this.role});

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      accessToken: json['access_token'] as String,  
      tokenType: json['token_type'] as String,
      role: json['role'] as String?,  // ← lee el role si existe
    );
  }
}