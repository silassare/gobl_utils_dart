import 'dart:convert';

import 'package:gobl_utils_dart/src/gobl_exception.dart';

class Gobl {
  static final Map<String, Type> _tableClasses = {};
  static final Map<String, Map<String, dynamic>> _entitiesCache = {};
  static final Map<String, String> _classMagicMap = {};

  static final String marker = '__gobl__';

  static final Gobl _gobl = Gobl._internal();
  Gobl._internal();

  factory Gobl() {
    return _gobl;
  }

  dynamic parse(String json,
      {Object Function(Object key, Object value) reviver}) {
    return jsonDecode(json, reviver: (key, value) {
      if (reviver is Function) {
        value = reviver(key, value);
      }

      if (value is Map) {
        var i = toInstance(value, cache: true);
        if (i == null) {
          return i;
        }
      }
      return value;
    });
  }

  /// Try to identify and instantiate the entity class
  /// that best matches the given data.
  dynamic toInstance(Map<String, dynamic> data, {bool cache = false}) {
    String entityName = data[marker];
    dynamic entity;
    String magic;
    dynamic old;
    dynamic e;
    String cacheKey;

    if (entityName != null) {
      entity = _tableClasses[entityName];
      // maybe the entity name change
      // this is to have a clean object
      data.remove(marker);
    }

    if (entity == null) {
      var keys = data.keys.toList();

      keys.sort((a, b) => a.compareTo(b));

      magic = keys.join();
      entityName = _classMagicMap[magic];

      if (entityName != null) {
        entity = _tableClasses[entityName];
      }
    }

    if (entity != null) {
      e = entity.fromJson(data);
      if (cache && (cacheKey = e.cacheKey())) {
        old = _entitiesCache[entityName][cacheKey];
        if (old) {
          e = old.doHydrate(data);
        }

        _entitiesCache[entityName][cacheKey] = e;
      }

      return e;
    }

    return null;
  }

  /// Register an entity class
  void register({String name, Type entity, List<String> columns}) {
    if (!_tableClasses.containsKey(name)) {
      _tableClasses[name] = entity;
      _entitiesCache[name] = {};

      var _columns = [...columns];

      _columns.sort((a, b) => a.compareTo(b));

      _classMagicMap[_columns.join()] = name;
    } else {
      throw GoblException(message: '$name must be registered once.');
    }
  }

  /// Get a given entity class cache
  Map<String, T> getEntityCache<T>(String entityName) {
    return _entitiesCache[entityName];
  }
}
