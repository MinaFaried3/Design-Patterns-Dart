// BEFORE: Deployment choices are repeated across unrelated constructors.
class ObjectStore {
  final String environment;
  ObjectStore(this.environment);
  String put(String payload) => '$environment/object-1';
}

class JobQueue {
  final String environment;
  JobQueue(this.environment);
  String enqueue(String key) => '$environment queue <- $key';
}

class AuditLog {
  final String environment;
  AuditLog(this.environment);
  String record(String event) => '$environment audit: $event';
}

void main() {
  final store = ObjectStore('local');
  final queue = JobQueue('cloud'); // Accidental cross-environment reference.
  final audit = AuditLog('local');
  final key = store.put('inventory report');
  print(queue.enqueue(key));
  print(audit.record('Queued $key'));
}
