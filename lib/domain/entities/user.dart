class User {
  final String id;
  final String name;
  final String role;
  final String email;
  final String phoneNumber;
  final List<String> preferredNotifications;
  final List<String> managedTanks;

  const User({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.phoneNumber,
    required this.preferredNotifications,
    required this.managedTanks,
  });

  // Métodos útiles para la lógica de usuarios
  bool get isAdmin => role == 'community_manager';
  bool get isTechnician => role == 'technician';
  bool get isCommunityMember => role == 'community_member';
  bool managesTank(String tankId) => managedTanks.contains(tankId);
}