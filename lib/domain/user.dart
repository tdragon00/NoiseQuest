import 'package:equatable/equatable.dart';

DateTime? _parseDate(dynamic value) {
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value)?.toUtc();
  return null;
}

int _asInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.bannerPresetId,
    required this.totalXp,
    required this.createdAt,
    required this.updatedAt,
    this.username,
    this.avatar,
  });

  final String id;
  final String email;
  final String? username;
  final String displayName;
  final String? avatar;
  final String bannerPresetId;
  final int totalXp;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory User.fromJson(Map<String, dynamic> json) {
    final username = json['username'] as String?;
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      username: username,
      displayName: (json['display_name'] as String?)?.trim().isNotEmpty == true
          ? json['display_name'] as String
          : (username ?? 'Wanderer'),
      avatar: json['avatar'] as String?,
      bannerPresetId: json['banner_preset_id'] as String? ?? 'neon_grid',
      totalXp: _asInt(json['total_xp']),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now().toUtc(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'username': username,
        'display_name': displayName,
        'avatar': avatar,
        'banner_preset_id': bannerPresetId,
        'total_xp': totalXp,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  User copyWith({
    String? username,
    bool clearUsername = false,
    String? displayName,
    String? avatar,
    bool clearAvatar = false,
    String? bannerPresetId,
    int? totalXp,
    DateTime? updatedAt,
  }) {
    return User(
      id: id,
      email: email,
      username: clearUsername ? null : (username ?? this.username),
      displayName: displayName ?? this.displayName,
      avatar: clearAvatar ? null : (avatar ?? this.avatar),
      bannerPresetId: bannerPresetId ?? this.bannerPresetId,
      totalXp: totalXp ?? this.totalXp,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        username,
        displayName,
        avatar,
        bannerPresetId,
        totalXp,
        createdAt,
        updatedAt,
      ];
}

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final User user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['access_token']?.toString() ?? '',
      refreshToken: json['refresh_token']?.toString() ?? '',
      expiresIn: _asInt(json['expires_in'], 3600),
      user: User.fromJson(
        (json['user'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );
  }
}
