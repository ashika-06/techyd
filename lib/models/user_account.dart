/// Local demo account. There is no backend: it lives in shared_preferences.
class UserAccount {
  const UserAccount({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password; // demo only - a real app would never store this

  Map<String, dynamic> toJson() =>
      {'name': name, 'email': email, 'password': password};

  factory UserAccount.fromJson(Map<String, dynamic> j) => UserAccount(
        name: j['name'] as String,
        email: j['email'] as String,
        password: j['password'] as String,
      );
}
