// AFTER: Three related infrastructure products come from one family.
// All products below are in-memory simulations.

// 1. PRODUCT CONTRACTS
abstract class ObjectStore {
  String put(String payload);
}

abstract class JobQueue {
  String enqueue(String key);
}

abstract class AuditLog {
  String record(String event);
}

// 2. LOCAL FAMILY
class LocalObjectStore implements ObjectStore {
  int _nextId = 0;
  @override
  String put(String payload) => 'local/object-${++_nextId}';
}

class LocalJobQueue implements JobQueue {
  @override
  String enqueue(String key) => 'local queue <- $key';
}

class LocalAuditLog implements AuditLog {
  @override
  String record(String event) => 'local audit: $event';
}

// 3. CLOUD FAMILY
class CloudObjectStore implements ObjectStore {
  int _nextId = 0;
  @override
  String put(String payload) => 'cloud/object-${++_nextId}';
}

class CloudJobQueue implements JobQueue {
  @override
  String enqueue(String key) => 'cloud queue <- $key';
}

class CloudAuditLog implements AuditLog {
  @override
  String record(String event) => 'cloud audit: $event';
}

// 4. ABSTRACT FACTORY AND CONCRETE FACTORIES
abstract class DeploymentFactory {
  ObjectStore createStore();
  JobQueue createQueue();
  AuditLog createAuditLog();
}

class LocalDeploymentFactory implements DeploymentFactory {
  @override
  ObjectStore createStore() => LocalObjectStore();
  @override
  JobQueue createQueue() => LocalJobQueue();
  @override
  AuditLog createAuditLog() => LocalAuditLog();
}

class CloudDeploymentFactory implements DeploymentFactory {
  @override
  ObjectStore createStore() => CloudObjectStore();
  @override
  JobQueue createQueue() => CloudJobQueue();
  @override
  AuditLog createAuditLog() => CloudAuditLog();
}

// 5. CLIENT: Knows contracts, not concrete environments.
class ReportApplication {
  final ObjectStore _store;
  final JobQueue _queue;
  final AuditLog _audit;

  ReportApplication(DeploymentFactory factory)
      : _store = factory.createStore(),
        _queue = factory.createQueue(),
        _audit = factory.createAuditLog();

  List<String> submit(String payload) {
    final key = _store.put(payload);
    return [_queue.enqueue(key), _audit.record('Queued $key')];
  }
}

// 6. USAGE
void main() {
  final local = ReportApplication(LocalDeploymentFactory());
  final cloud = ReportApplication(CloudDeploymentFactory());
  final localResult = local.submit('inventory report');
  final cloudResult = cloud.submit('inventory report');
  assert(localResult.every((line) => line.startsWith('local')));
  assert(cloudResult.every((line) => line.startsWith('cloud')));
  print(localResult.join('\n'));
  print(cloudResult.join('\n'));
}
