// AFTER: A rule tree combines leaves and groups uniformly and explains itself.

// 1. CONTEXT AND RESULT TREE
class User {
  final Set<String> roles;
  final int requestedCents;
  User(Set<String> roles, this.requestedCents)
    : roles = Set.unmodifiable(roles);
}

class Decision {
  final String label;
  final bool allowed;
  final List<Decision> children;
  Decision(this.label, this.allowed, [List<Decision> children = const []])
    : children = List.unmodifiable(children);

  String format([int depth = 0]) {
    final line = '${'  ' * depth}$label: ${allowed ? 'PASS' : 'FAIL'}';
    return [
      line,
      ...children.map((child) => child.format(depth + 1)),
    ].join('\n');
  }
}

// 2. COMPONENT
abstract class ApprovalRule {
  Decision evaluate(User user);
}

// 3. LEAVES
class HasRole implements ApprovalRule {
  final String role;
  HasRole(this.role);

  @override
  Decision evaluate(User user) =>
      Decision('Role $role', user.roles.contains(role));
}

class WithinLimit implements ApprovalRule {
  final int cents;
  WithinLimit(this.cents);

  @override
  Decision evaluate(User user) =>
      Decision('Amount <= $cents', user.requestedCents <= cents);
}

// 4. COMPOSITES: Groups can contain arbitrary nested groups.
class AllOf implements ApprovalRule {
  final List<ApprovalRule> children;
  AllOf(List<ApprovalRule> children) : children = List.unmodifiable(children);

  @override
  Decision evaluate(User user) {
    final results = children.map((rule) => rule.evaluate(user)).toList();
    return Decision('All', results.every((result) => result.allowed), results);
  }
}

class AnyOf implements ApprovalRule {
  final List<ApprovalRule> children;
  AnyOf(List<ApprovalRule> children) : children = List.unmodifiable(children);

  @override
  Decision evaluate(User user) {
    final results = children.map((rule) => rule.evaluate(user)).toList();
    return Decision('Any', results.any((result) => result.allowed), results);
  }
}

// 5. CLIENT: Evaluates the root through the same interface as a leaf.
void main() {
  final ApprovalRule policy = AnyOf([
    HasRole('admin'),
    AllOf([HasRole('manager'), WithinLimit(10000)]),
  ]);
  final approved = policy.evaluate(User({'manager'}, 9000));
  final denied = policy.evaluate(User({'manager'}, 15000));
  assert(approved.allowed && !denied.allowed);
  assert(policy.evaluate(User({'admin'}, 99999)).allowed);
  print(approved.format());
  print(denied.format());
}
