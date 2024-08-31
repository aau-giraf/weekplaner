/// Defines access levels of Pictogram in the system
enum AccessLevel {
  /// Accessible by everyone, even non-users.
  PUBLIC,

  /// Accessible to all users associated with the owning department.
  PROTECTED,

  /// Accessible only to the owning user.
  PRIVATE,
}
