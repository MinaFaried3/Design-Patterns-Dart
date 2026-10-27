import 'dart:async';

import 'package:test/test.dart';

import '../bin/1-creational_patterns/1-singleton/1-example_1/after/after.dart'
    as singleton;
import '../bin/1-creational_patterns/1-singleton/3-example_3/after/after.dart'
    as async_singleton;
import '../bin/1-creational_patterns/2-prototype/2-example_2/after/after.dart'
    as employee;
import '../bin/1-creational_patterns/2-prototype/3-example_3/after/after.dart'
    as prototype;
import '../bin/1-creational_patterns/3-builder/1-example_1/after/after.dart'
    as sandwich;
import '../bin/1-creational_patterns/3-builder/2-example_2/after/after.dart'
    as query;
import '../bin/1-creational_patterns/3-builder/3-example_3/after/after.dart'
    as builder;
import '../bin/1-creational_patterns/4-factory_method/1-example_1/after/after.dart'
    as factory_method;
import '../bin/1-creational_patterns/4-factory_method/3-example_3/after/after.dart'
    as importer;
import '../bin/1-creational_patterns/5-abstract_factory/2-example_2/after/after.dart'
    as codec;
import '../bin/1-creational_patterns/5-abstract_factory/3-example_3/after/after.dart'
    as family;
import '../bin/2-structural_patterns/1-proxy/2-example_2/after/after.dart'
    as protection;
import '../bin/2-structural_patterns/1-proxy/3-example_3/after/after.dart'
    as proxy;
import '../bin/2-structural_patterns/2-decorator/1-example_1/after/after.dart'
    as drink;
import '../bin/2-structural_patterns/2-decorator/3-example_3/after/after.dart'
    as decorator;
import '../bin/2-structural_patterns/3-adapter/3-example_3/after/after.dart'
    as adapter;
import '../bin/2-structural_patterns/4-facade/3-example_3/after/after.dart'
    as facade;
import '../bin/2-structural_patterns/5-flyweight/2-example_2/after/after.dart'
    as style;
import '../bin/2-structural_patterns/5-flyweight/3-example_3/after/after.dart'
    as flyweight;
import '../bin/2-structural_patterns/6-composite/1-example_1/after/after.dart'
    as files;
import '../bin/2-structural_patterns/6-composite/3-example_3/after/after.dart'
    as composite;
import '../bin/2-structural_patterns/7-bridge/3-example_3/after/after.dart'
    as bridge;

// These tests check observable contracts and failure paths. The separate
// tool/verify_examples.dart runner executes all 72 standalone programs.
void main() {
  group('Singleton', () {
    test('callers share one object and cannot mutate its exposed history', () {
      final first = singleton.AppLogger();
      final second = singleton.AppLogger();
      first.log('Created');
      second.log('Paid');

      expect(identical(first, second), isTrue);
      expect(first.messages, ['Created', 'Paid']);
      expect(() => first.messages.add('Injected'), throwsUnsupportedError);
    });

    test(
      'failed initialization retries and concurrent callers share work',
      () async {
        var calls = 0;
        Future<Map<String, String>> load() {
          calls++;
          if (calls == 1) throw StateError('Synchronous loader failure');
          return Future.value({'theme': 'dark'});
        }

        await expectLater(
          async_singleton.Settings.load(load),
          throwsStateError,
        );
        final first = async_singleton.Settings.load(load);
        final second = async_singleton.Settings.load(load);
        expect(identical(first, second), isTrue);
        final settings = await Future.wait([first, second]);
        expect(calls, 2);
        expect(identical(settings[0], settings[1]), isTrue);
        expect(
          () => settings.first.values['theme'] = 'light',
          throwsUnsupportedError,
        );
      },
    );
  });

  group('Prototype', () {
    test('nested mutable objects and collections are independent', () {
      final original = employee.Employee(
        'Template',
        employee.Address('Cairo'),
        ['Dart'],
      );
      final copy = original.clone()
        ..address.city = 'Alexandria'
        ..skills.add('SQL');

      expect(original.address.city, 'Cairo');
      expect(original.skills, ['Dart']);
      expect(copy.address.city, 'Alexandria');
    });

    test('registry snapshots and recursive clones protect the template', () {
      final source = prototype.Section([
        prototype.Paragraph('Intro'),
        prototype.Section([prototype.Paragraph('Body')]),
      ]);
      final registry = prototype.TemplateRegistry()..register('report', source);
      (source.children.first as prototype.Paragraph).text = 'Source changed';
      final first = registry.create('report') as prototype.Section;
      final nested = first.children[1] as prototype.Section;
      (nested.children.first as prototype.Paragraph).text = 'Copy changed';

      expect(registry.create('report').render(), 'Intro | Body');
      expect(first.render(), 'Intro | Copy changed');
      expect(() => registry.create('missing'), throwsArgumentError);
    });
  });

  group('Builder', () {
    test(
      'validation and snapshots prevent unfinished or changing products',
      () {
        final builder = sandwich.SandwichBuilder();
        expect(builder.build, throwsStateError);
        builder.add('Cheese');
        final first = builder.build();
        builder.add('Tomato');

        expect(first.fillings, ['Cheese']);
        expect(() => first.fillings.add('Olives'), throwsUnsupportedError);
        expect(builder.build().fillings, ['Cheese', 'Tomato']);
      },
    );

    test('query construction preserves parameter order and old snapshots', () {
      final builder = query.SelectQueryBuilder('stock')
        ..whereEquals('sku', "PEN' OR 1=1")
        ..limit(2);
      final first = builder.build();
      builder.whereEquals('warehouse', 'CAIRO');

      expect(first.sql, 'SELECT * FROM stock WHERE sku = ? LIMIT 2');
      expect(first.parameters, ["PEN' OR 1=1"]);
      expect(builder.build().parameters, ["PEN' OR 1=1", 'CAIRO']);
      expect(() => builder.limit(0), throwsArgumentError);
      expect(() => query.SelectQueryBuilder('stock;drop'), throwsArgumentError);
    });

    test('director reuses a recipe and resets a reused representation', () {
      final director = builder.InventoryReportDirector();
      final markdown = builder.MarkdownReportBuilder();
      expect(
        director.construct(markdown, {'Pen': 2}),
        '# Inventory\n- Pen: 2\nTotal: 2',
      );
      expect(
        director.construct(markdown, {'Book': 3}),
        '# Inventory\n- Book: 3\nTotal: 3',
      );

      final csv = director.construct(builder.CsvReportBuilder(), {
        'Pen, "blue"': 2,
      });
      expect(csv.split('\n')[1], '"Pen, ""blue""",2');
      expect(csv, endsWith('Total,2'));
    });
  });

  group('Factory Method', () {
    test('a new product participates in the inherited creator workflow', () {
      final sender = _RecordingSender();
      final flow = _RecordingFlow(sender);

      expect(flow.notify('Welcome'), 'Recorded');
      expect(sender.messages, ['[APP] Welcome']);
    });

    test('different readers share aggregation and validation', () async {
      expect(await importer.PipeImportJob().run('PEN|2\nPEN|3'), {'PEN': 5});
      expect(
        await importer.JsonImportJob().run(
          '[{"sku":"PEN","quantity":2},{"sku":"PEN","quantity":3}]',
        ),
        {'PEN': 5},
      );
      await expectLater(
        importer.PipeImportJob().run('PEN|-1'),
        throwsFormatException,
      );
      await expectLater(
        importer.PipeImportJob().run('broken'),
        throwsFormatException,
      );
      await expectLater(
        importer.JsonImportJob().run('[{"sku":"","quantity":2}]'),
        throwsFormatException,
      );
    });
  });

  group('Abstract Factory', () {
    test('each codec family provides compatible products', () {
      for (final factory in <codec.CodecFactory>[
        codec.JsonCodecFactory(),
        codec.PipeCodecFactory(),
      ]) {
        expect(codec.roundTrip(factory, ['Pen', 'Book']), ['Pen', 'Book']);
      }
      expect(
        () => codec.roundTrip(codec.PipeCodecFactory(), ['A|B']),
        throwsArgumentError,
      );
    });

    test('changing a factory changes the whole infrastructure family', () {
      final local = family.ReportApplication(family.LocalDeploymentFactory());
      final cloud = family.ReportApplication(family.CloudDeploymentFactory());

      expect(local.submit('report'), [
        'local queue <- local/object-1',
        'local audit: Queued local/object-1',
      ]);
      expect(cloud.submit('report'), [
        'cloud queue <- cloud/object-1',
        'cloud audit: Queued cloud/object-1',
      ]);
      expect(local.submit('second').first, contains('local/object-2'));
    });
  });

  group('Proxy', () {
    test('denied access never reaches the subject', () {
      final subject = protection.DocumentStore();
      final denied = protection.ProtectedDocumentReader(
        subject,
        canRead: false,
      );
      expect(() => protection.openDocument(denied), throwsStateError);
      expect(subject.reads, 0);

      final allowed = protection.ProtectedDocumentReader(
        subject,
        canRead: true,
      );
      expect(protection.openDocument(allowed), contains('DOC-1'));
      expect(subject.reads, 1);
    });

    test(
      'matching concurrent reads share work and retain successful results',
      () async {
        final subject = _ControlledCatalog();
        final catalog = proxy.CachedCatalog(subject);
        final first = catalog.fetch('PEN');
        final second = catalog.fetch('PEN');
        expect(identical(first, second), isTrue);
        expect(subject.requests.length, 1);
        subject.requests[0].complete('Pen');
        expect(await first, 'Pen');
        expect(await catalog.fetch('PEN'), 'Pen');
        expect(subject.requests.length, 1);
      },
    );

    test('failure is evicted and a later request can retry', () async {
      final subject = _ControlledCatalog();
      final catalog = proxy.CachedCatalog(subject);
      final failed = catalog.fetch('PEN');
      final failureCheck = expectLater(failed, throwsStateError);
      subject.requests[0].completeError(StateError('Offline'));
      await failureCheck;

      final retry = catalog.fetch('PEN');
      expect(subject.requests.length, 2);
      subject.requests[1].complete('Recovered');
      expect(await retry, 'Recovered');
    });

    test(
      'an old failure cannot evict a replacement after invalidation',
      () async {
        final subject = _ControlledCatalog();
        final catalog = proxy.CachedCatalog(subject);
        final old = catalog.fetch('PEN');
        final failureCheck = expectLater(old, throwsStateError);
        catalog.invalidate('PEN');
        final replacement = catalog.fetch('PEN');

        subject.requests[0].completeError(StateError('Old request failed'));
        await failureCheck;
        expect(identical(catalog.fetch('PEN'), replacement), isTrue);
        expect(subject.requests.length, 2);
        subject.requests[1].complete('Fresh');
        expect(await replacement, 'Fresh');
      },
    );
  });

  group('Decorator', () {
    test('responsibilities combine without paired subclasses', () {
      final drink.Drink order = drink.Sugar(drink.Milk(drink.Coffee()));
      expect(order.cost, 27);
      expect(order.description, 'Coffee + milk + sugar');
      expect(drink.Milk(drink.Milk(drink.Coffee())).cost, 30);
    });

    test('nested transformations round-trip in either composition order', () {
      for (final reverse in [false, true]) {
        final memory = decorator.MemoryTextStore();
        final decorator.TextStore store = reverse
            ? decorator.Base64TextStore(decorator.GzipTextStore(memory))
            : decorator.GzipTextStore(decorator.Base64TextStore(memory));
        for (final text in ['', 'Dart patterns', 'مرحبا']) {
          store.write(text);
          expect(store.read(), text);
          expect(memory.read(), isNot(text));
        }
      }
    });
  });

  group('Adapter', () {
    test(
      'both vendors satisfy accepted and declined target semantics',
      () async {
        for (final gateway in <adapter.PaymentGateway>[
          adapter.LegacyPaymentAdapter(adapter.LegacyPaymentSdk()),
          adapter.ModernPaymentAdapter(adapter.ModernPaymentSdk()),
        ]) {
          final accepted = await gateway.charge(2500);
          final declined = await gateway.charge(6000);
          expect(accepted.accepted, isTrue);
          expect(accepted.reference, isNotNull);
          expect(declined.accepted, isFalse);
          expect(declined.reference, isNull);
          await expectLater(gateway.charge(0), throwsArgumentError);
        }
      },
    );

    test(
      'unexpected vendor errors propagate instead of becoming declines',
      () async {
        final gateway = adapter.ModernPaymentAdapter(_BrokenPaymentSdk());
        await expectLater(gateway.charge(100), throwsStateError);
      },
    );
  });

  group('Facade', () {
    test('payment and shipping failures restore completed subsystem steps', () {
      final stock = facade.Inventory(10);
      final wallet = facade.PaymentService(1000);
      final shipping = facade.ShippingService();
      final checkout = facade.CheckoutFacade(stock, wallet, shipping);

      expect(checkout.placeOrder(quantity: 2, totalCents: 200).success, isTrue);
      expect(
        checkout.placeOrder(quantity: 2, totalCents: 2000).success,
        isFalse,
      );
      expect(stock.stock, 8);
      expect(wallet.balance, 800);

      shipping.failNext = true;
      expect(
        checkout.placeOrder(quantity: 1, totalCents: 100).success,
        isFalse,
      );
      expect(stock.stock, 8);
      expect(wallet.balance, 800);
    });

    test('invalid input and insufficient stock have no side effects', () {
      final stock = facade.Inventory(2);
      final wallet = facade.PaymentService(1000);
      final checkout = facade.CheckoutFacade(
        stock,
        wallet,
        facade.ShippingService(),
      );
      expect(
        checkout.placeOrder(quantity: 0, totalCents: 100).success,
        isFalse,
      );
      expect(checkout.placeOrder(quantity: 1, totalCents: 0).success, isFalse);
      expect(
        checkout.placeOrder(quantity: 3, totalCents: 100).success,
        isFalse,
      );
      expect(stock.stock, 2);
      expect(wallet.balance, 1000);
    });
  });

  group('Flyweight', () {
    test('the cache key includes every style dimension', () {
      final styles = style.TextStyleFactory();
      final normal = styles.get('Mono', 14);
      expect(identical(normal, styles.get('Mono', 14)), isTrue);
      expect(identical(normal, styles.get('Mono', 14, bold: true)), isFalse);
      expect(identical(normal, styles.get('Mono', 16)), isFalse);
      expect(styles.count, 3);
    });

    test('shared intrinsic data is immutable and damage remains extrinsic', () {
      final pool = flyweight.TexturePool();
      final first = flyweight.Tile(0, 0, pool.get('grass', 'summer'));
      final second = flyweight.Tile(1, 0, pool.get('grass', 'summer'));
      first.damage(20);
      expect(identical(first.texture, second.texture), isTrue);
      expect(first.durability, 80);
      expect(second.durability, 100);
      expect(() => first.texture.pixels[0] = 9, throwsUnsupportedError);
      expect(identical(first.texture, pool.get('grass', 'winter')), isFalse);
      expect(pool.count, 2);
    });
  });

  group('Composite', () {
    test('one contract handles leaves, nested groups, and empty groups', () {
      final children = <files.StorageEntry>[files.FileItem(100)];
      final root = files.Folder([files.Folder(children), files.FileItem(50)]);
      children.add(files.FileItem(999));
      expect(root.size, 150);
      expect(files.Folder([]).size, 0);
      expect(() => root.children.clear(), throwsUnsupportedError);
    });

    test('nested policies produce decisions and explanations consistently', () {
      final composite.ApprovalRule rule = composite.AnyOf([
        composite.HasRole('admin'),
        composite.AllOf([
          composite.HasRole('manager'),
          composite.WithinLimit(10000),
        ]),
      ]);
      final denied = rule.evaluate(composite.User({'manager'}, 15000));
      expect(denied.allowed, isFalse);
      expect(denied.children.length, 2);
      expect(denied.format(), contains('Amount <= 10000: FAIL'));
      expect(rule.evaluate(composite.User({'manager'}, 9000)).allowed, isTrue);
      expect(rule.evaluate(composite.User({'admin'}, 99999)).allowed, isTrue);
      expect(
        composite.AllOf([]).evaluate(composite.User({}, 0)).allowed,
        isTrue,
      );
      expect(
        composite.AnyOf([]).evaluate(composite.User({}, 0)).allowed,
        isFalse,
      );
    });
  });

  group('Bridge', () {
    test(
      'both report refinements work with both delivery implementations',
      () async {
        final email = bridge.EmailDelivery('Mona');
        final archive = bridge.ArchiveDelivery();
        for (final delivery in <bridge.ReportDelivery>[email, archive]) {
          await bridge.SummaryReport(delivery).publish([10, 2, 4]);
          await bridge.LowStockReport(delivery).publish([10, 2, 4]);
        }
        expect(email.outbox, ['Total stock: 16', 'Low stock: 2, 4']);
        expect(archive.documents.values.toList(), email.outbox);
      },
    );

    test('common validation happens before delivery', () {
      final email = bridge.EmailDelivery('Mona');
      final report = bridge.SummaryReport(email);
      expect(() => report.publish([-1]), throwsArgumentError);
      expect(email.outbox, isEmpty);
    });
  });
}

class _RecordingSender implements factory_method.MessageSender {
  final List<String> messages = [];
  @override
  String send(String message) {
    messages.add(message);
    return 'Recorded';
  }
}

class _RecordingFlow extends factory_method.NotificationFlow {
  final factory_method.MessageSender sender;
  _RecordingFlow(this.sender);
  @override
  factory_method.MessageSender createSender() => sender;
}

class _ControlledCatalog implements proxy.Catalog {
  final List<Completer<String>> requests = [];
  @override
  Future<String> fetch(String sku) {
    final request = Completer<String>();
    requests.add(request);
    return request.future;
  }
}

class _BrokenPaymentSdk extends adapter.ModernPaymentSdk {
  @override
  Future<String> debit({required int amountInCents}) async {
    throw StateError('Unexpected SDK failure');
  }
}
