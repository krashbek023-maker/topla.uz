import 'package:flutter_test/flutter_test.dart';
import 'package:topla_app/services/cache_service.dart';

void main() {
  group('MemoryCache Tests', () {
    late MemoryCache cache;

    setUp(() {
      cache = MemoryCache();
      cache.clear();
    });

    test('should store and retrieve value', () {
      cache.set('test_key', 'test_value');
      expect(cache.get<String>('test_key'), equals('test_value'));
    });

    test('should return null for non-existent key', () {
      expect(cache.get<String>('non_existent'), isNull);
    });

    test('should check if key exists', () {
      cache.set('exists', 'value');
      expect(cache.has('exists'), isTrue);
      expect(cache.has('not_exists'), isFalse);
    });

    test('should remove key', () {
      cache.set('to_remove', 'value');
      cache.remove('to_remove');
      expect(cache.get<String>('to_remove'), isNull);
    });

    test('should clear all cache', () {
      cache.set('key1', 'value1');
      cache.set('key2', 'value2');
      cache.clear();
      expect(cache.get<String>('key1'), isNull);
      expect(cache.get<String>('key2'), isNull);
    });

    test('should expire entries after TTL', () async {
      cache.set('expiring', 'value', ttl: const Duration(milliseconds: 100));
      expect(cache.get<String>('expiring'), equals('value'));

      await Future.delayed(const Duration(milliseconds: 150));
      expect(cache.get<String>('expiring'), isNull);
    });

    test('should store different types', () {
      cache.set('string', 'hello');
      cache.set('int', 42);
      cache.set('double', 3.14);
      cache.set('bool', true);
      cache.set('list', [1, 2, 3]);
      cache.set('map', {'key': 'value'});

      expect(cache.get<String>('string'), equals('hello'));
      expect(cache.get<int>('int'), equals(42));
      expect(cache.get<double>('double'), equals(3.14));
      expect(cache.get<bool>('bool'), equals(true));
      expect(cache.get<List>('list'), equals([1, 2, 3]));
      expect(cache.get<Map>('map'), equals({'key': 'value'}));
    });

    test('should remove entries matching pattern', () {
      cache.set('user_1', 'data1');
      cache.set('user_2', 'data2');
      cache.set('product_1', 'data3');

      cache.removeWhere((key) => key.startsWith('user_'));

      expect(cache.get<String>('user_1'), isNull);
      expect(cache.get<String>('user_2'), isNull);
      expect(cache.get<String>('product_1'), equals('data3'));
    });
  });

  group('CacheEntry Tests', () {
    test('should detect expired entry', () async {
      final entry = CacheEntry(
        data: 'test',
        createdAt: DateTime.now(),
        ttl: const Duration(milliseconds: 50),
      );

      expect(entry.isExpired, isFalse);
      await Future.delayed(const Duration(milliseconds: 100));
      expect(entry.isExpired, isTrue);
    });

    test('should serialize and deserialize', () {
      final entry = CacheEntry(
        data: {'key': 'value'},
        createdAt: DateTime.now(),
        ttl: const Duration(hours: 1),
      );

      final json = entry.toJson((data) => data);
      final restored = CacheEntry.fromJson<Map<String, dynamic>>(
        json,
        (data) => Map<String, dynamic>.from(data),
      );

      expect(restored, isNotNull);
      expect(restored!.data, equals({'key': 'value'}));
    });
  });

  group('CacheKeys Tests', () {
    test('should generate correct product detail key', () {
      expect(CacheKeys.productDetail('123'), equals('product_123'));
    });

    test('should generate correct category products key', () {
      expect(
        CacheKeys.categoryProducts('cat_1'),
        equals('category_products_cat_1'),
      );
    });

    test('should generate correct vendor products key', () {
      expect(
        CacheKeys.vendorProducts('vendor_1'),
        equals('vendor_products_vendor_1'),
      );
    });
  });
}
