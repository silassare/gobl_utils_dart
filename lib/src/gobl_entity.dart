import 'package:gobl_utils_dart/src/gobl.dart';
import 'package:gobl_utils_dart/src/gobl_exception.dart';

enum GoblEntityState {
  UNKNOWN,
  SAVING,
  DELETING,
  UPDATING,
}

abstract class GoblEntity {
  Map<String, dynamic> _data;
  Map<String, GoblEntity> _cache;
  String _name;
  List<String> _columns;

  GoblEntityState _state = GoblEntityState.UNKNOWN;

  GoblEntity(
      {Map<String, dynamic> initialData = const {},
      String name,
      String prefix,
      List<String> columns}) {
    _name = name;
    _columns = columns;

    _columns.forEach((col) {
      _data[col] =
          _cache[col] = initialData.containsKey(col) ? initialData[col] : null;
    });
  }

  /// Checks if the entity is clean.
  bool isClean() {
    return toObject(diff: true).keys.isEmpty;
  }

  /// Checks if the entity is saved.
  bool isSaved(bool setSaved) {
    if (setSaved) {
      _cache = toObject();
      return true;
    }

    return isClean();
  }

  /// Checks if the entity is being saved.
  bool isSaving({bool setAsSaving}) {
    if (setAsSaving is bool) {
      _state = setAsSaving ? GoblEntityState.SAVING : GoblEntityState.UNKNOWN;
    }

    return _state == GoblEntityState.SAVING;
  }

  /// Checks if the entity is being deleted.
  bool isDeleting({bool setAsDeleting}) {
    if (setAsDeleting is bool) {
      _state =
          setAsDeleting ? GoblEntityState.DELETING : GoblEntityState.UNKNOWN;
    }

    return _state == GoblEntityState.DELETING;
  }

  /// Checks if the entity is being updated.
  bool isUpdating({bool setAsUpdating}) {
    if (setAsUpdating is bool) {
      _state =
          setAsUpdating ? GoblEntityState.UPDATING : GoblEntityState.UNKNOWN;
    }

    return _state == GoblEntityState.UPDATING;
  }

  /// Returns current data in a clean new object
  ///
  /// if `diff` is true, returns modified columns only
  Map<String, dynamic> toObject({bool diff = false}) {
    var o = {};

    if (diff) {
      for (var k in _cache.keys) {
        if (_cache[k] != _data[k]) {
          o[k] = _data[k];
        }
      }

      return o;
    }

    return {..._data};
  }

  /// Returns some column values
  Map<String, dynamic> toObjectSome(List<String> columns) {
    var o = {}, len = columns.length;

    for (var i = 0; i < len; i++) {
      var col = columns[i];
      if (_data.containsKey(col)) {
        o[col] = _data[col];
      } else {
        throw GoblException(
            message: 'Column "${col}" is not defined in "${_name}".',
            data: {'entity': _name});
      }
    }

    return o;
  }

  /// Returns the entity cache key.
  ///
  /// `null` is returned when we can't have a valid cache key.
  dynamic cacheKey() {
    var columns = identifierColumns();
    columns.sort((a, b) {
      return a.compareTo(b);
    });

    var len = columns.length, value = '', i = 0;

    if (len == 1) {
      value = _data[columns[0]];
    } else {
      for (; i < len; i++) {
        var v = _data[columns[i]];
        if (v != null) {
          value += '_' + v;
        }
      }
    }

    return value;
  }

  /// Hydrate the entity and set as saved when `save` is true
  GoblEntity doHydrate(Map<String, dynamic> data, bool save) {
    data.keys.forEach((k) {
      doSet(k, data[k]);
    });

    if (save) {
      isSaved(true);
    }

    return this;
  }

  /// Magic type convertion.
  dynamic doTypeCast(String column, dynamic value, [Type type = String]) {
    if (value == null) return null;

    switch (type) {
      case String:
        value = value.toString();
        break;
      case bool:
        value = value == false || value == 0 || value == '0' ? false : true;
        break;
      case num:
        value = num.tryParse(value);
        break;
    }

    return value;
  }

  /// Set a column value.
  void doSet(String column, dynamic value, [Type type = String]) {
    if (_data.containsKey(column)) {
      _data[column] = doTypeCast(column, value, type);
    }
  }

  /// Get a column value.
  dynamic doGet(String column, [Type type = String]) {
    if (_data.containsKey(column)) {
      return doTypeCast(column, _data[column], type);
    }

    return null;
  }

  /// JSON helper
  Map<String, dynamic> toJSON() {
    var data = toObject();
    data[Gobl.marker] = _name;

    return data;
  }

  /// Create instance from json
  dynamic fromJson(Map<String, dynamic> json);

  /// Returns the primary keys of the entity.
  List<String> identifierColumns();
}
