class AppUser {
  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
    this.phone,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final String? avatar;
  final String? phone;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        role: json['role'] as String? ?? 'student',
        avatar: json['avatar'] as String?,
        phone: json['phone'] as String?,
      );

  /// First rune of the first name segment - safe for Arabic text, where
  /// `substring(0, 1)` can split a combining character in two.
  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '؟';
    final firstRune = trimmed.runes.first;
    return String.fromCharCode(firstRune);
  }
}
