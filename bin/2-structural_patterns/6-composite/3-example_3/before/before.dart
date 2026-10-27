// BEFORE: Nested policy and explanation logic are duplicated.
class User {
  final Set<String> roles;
  final int requestedCents;
  User(this.roles, this.requestedCents);
}

bool canApprove(User user) =>
    user.roles.contains('admin') ||
    (user.roles.contains('manager') && user.requestedCents <= 10000);

String explain(User user) {
  if (user.roles.contains('admin')) return 'Administrator approved';
  if (!user.roles.contains('manager')) return 'Manager role missing';
  if (user.requestedCents > 10000) return 'Manager limit exceeded';
  return 'Manager approved';
}

void main() {
  for (final user in [
    User({'manager'}, 9000),
    User({'manager'}, 15000),
  ]) {
    print('Allowed: ${canApprove(user)}; ${explain(user)}');
  }
}
