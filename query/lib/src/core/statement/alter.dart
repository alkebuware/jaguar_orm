part of query.core;

abstract class AlterClause {}

class AddColumn<T> implements AlterClause {
  final CreateCol<T> column;

  AddColumn(this.column);

  String get name => column.name;

  static AddColumn<core.int> int(String name,
      {core.bool notNull = false,
        core.bool auto = false,
        core.bool primary = false,
        core.bool unsigned = false,
        core.bool big = false,
        References foreign,
        List<Constraint> constraints = const []}) {
    return AddColumn(CreateCol(
      name,
      Int(auto: auto, unsigned: unsigned, big: big),
      notNull: notNull,
      isPrimary: primary,
      foreign: foreign,
      constraints: constraints,
    ));
  }

  static AddColumn<core.double> double(String name,
      {core.bool notNull = false,
        core.bool primary = false,
        References foreign,
        List<Constraint> constraints = const []}) {
    return AddColumn(CreateCol(
      name,
      Double(),
      notNull: notNull,
      isPrimary: primary,
      foreign: foreign,
      constraints: constraints,
    ));
  }

  static AddColumn<String> string(String name,
      {core.int length = null,
        core.bool notNull = false,
        core.bool primary = false,
        References foreign,
        List<Constraint> constraints = const []}) {
    return AddColumn(CreateCol(
      name,
      Str(length: length),
      notNull: notNull,
      isPrimary: primary,
      foreign: foreign,
      constraints: constraints,
    ));
  }

  static AddColumn<core.bool> bool(String name,
      {core.bool notNull = false, List<Constraint> constraints = const []}) {
    return AddColumn(CreateCol(
      name,
      Bool(),
      notNull: notNull,
      constraints: constraints,
    ));
  }

  static AddColumn<DateTime> timestamp(String name,
      {core.bool notNull = false,
        core.bool primary = false,
        References foreign,
        List<Constraint> constraints = const []}) {
    return AddColumn(CreateCol(
      name,
      Timestamp(),
      notNull: notNull,
      isPrimary: primary,
      foreign: foreign,
      constraints: constraints,
    ));
  }
}

/* TODO
class ModifyColumn<T> implements AlterClause {
  final CreateColumn<T> column;

  ModifyColumn(this.column);

  String get name => column.name;

  static ModifyColumn<core.int> int(String name,
      {core.bool isNullable = false,
      core.bool autoIncrement = false,
      core.bool primary = false,
      String foreignTable,
      String foreignCol,
      String uniqueGroup}) {
    Foreign foreign;
    if (foreignTable != null) {
      foreign = Foreign(foreignTable, foreignCol != null ? foreignCol : name);
    }
    return ModifyColumn(CreateInt(
      name,
      isNullable: isNullable,
      autoIncrement: autoIncrement,
      isPrimary: primary,
      foreignKey: foreign,
      uniqueGroup: uniqueGroup,
    ));
  }

  static ModifyColumn<core.double> double(String name,
      {core.bool isNullable = false,
      core.bool primary = false,
      String foreignTable,
      String foreignCol,
      String uniqueGroup}) {
    Foreign foreign;
    if (foreignTable != null) {
      foreign = Foreign(foreignTable, foreignCol != null ? foreignCol : name);
    }
    return ModifyColumn(CreateDouble(name,
        isNullable: isNullable,
        isPrimary: primary,
        foreignKey: foreign,
        uniqueGroup: uniqueGroup));
  }

  static ModifyColumn<String> string(String name,
      {core.bool isNullable = false,
      core.int length = 20,
      core.bool primary = false,
      String foreignTable,
      String foreignCol,
      String uniqueGroup}) {
    Foreign foreign;
    if (foreignTable != null) {
      foreign = Foreign(foreignTable, foreignCol != null ? foreignCol : name);
    }
    return ModifyColumn(CreateStr(name,
        isNullable: isNullable,
        length: length,
        isPrimary: primary,
        foreignKey: foreign,
        uniqueGroup: uniqueGroup));
  }

  static ModifyColumn<core.bool> bool(String name,
      {core.bool isNullable = false, String uniqueGroup}) {
    return ModifyColumn(
        CreateBool(name, isNullable: isNullable, uniqueGroup: uniqueGroup));
  }

  static ModifyColumn<DateTime> datetime(String name,
      {core.bool isNullable = false, String uniqueGroup}) {
    return ModifyColumn(
        CreateDateTime(name, isNullable: isNullable, uniqueGroup: uniqueGroup));
  }
}
 */

class DropColumn implements AlterClause {
  final String name;

  const DropColumn(this.name);
}

/// Alter table statement
class Alter implements Statement {
  /// Table to alter
  final String table;

  final List<AlterClause> others = [];

  final adds = <String, AddColumn>{};

  final drops = <String, DropColumn>{};

  // TODO final mods = <String, ModifyColumn>{};

  final List<String> primaryKeys = [];

  bool shouldDropPrimary = false;

  Alter(this.table);

  Alter dropPrimaryKey() {
    shouldDropPrimary = true;
    return this;
  }

  Alter addPrimaryKey(Iterable<String> pkeys) {
    primaryKeys.addAll(pkeys);
    return this;
  }

  Alter add(AlterClause cl) {
    if (cl is AddColumn) {
      adds[cl.name] = cl;
    } else if (cl is DropColumn) {
      drops[cl.name] = cl;
    }
    /* TODO  else if (cl is ModifyColumn) {
      mods[cl.name] = cl;
    } */
    else {
      others.add(cl);
    }
    return this;
  }

  Alter addAll(Iterable<AlterClause> clauses) {
    clauses.forEach(add);
    return this;
  }

  /*
  Alter addInt(String name,
      {core.bool isNullable = false,
      core.bool autoIncrement = false,
      core.bool primary = false,
      String foreignTable,
      String foreignCol,
      String uniqueGroup}) {
    final cl = AddColumn.int(name,
        isNullable: isNullable,
        autoIncrement: autoIncrement,
        primary: primary,
        foreignTable: foreignTable,
        foreignCol: foreignCol,
        uniqueGroup: uniqueGroup);
    adds[name] = cl;
    return this;
  }

  Alter addDouble(String name,
      {core.bool isNullable = false,
      core.bool primary = false,
      String foreignTable,
      String foreignCol,
      String uniqueGroup}) {
    final cl = AddColumn.double(name,
        isNullable: isNullable,
        primary: primary,
        foreignTable: foreignTable,
        foreignCol: foreignCol,
        uniqueGroup: uniqueGroup);
    adds[name] = cl;
    return this;
  }

  Alter addString(String name,
      {core.bool isNullable = false,
      core.int length = 20,
      core.bool primary = false,
      String foreignTable,
      String foreignCol,
      String uniqueGroup}) {
    final cl = AddColumn.string(name,
        isNullable: isNullable,
        primary: primary,
        length: length,
        foreignTable: foreignTable,
        foreignCol: foreignCol,
        uniqueGroup: uniqueGroup);
    adds[name] = cl;
    return this;
  }

  Alter addBool(String name,
      {core.bool isNullable = false, String uniqueGroup}) {
    final cl =
        AddColumn.bool(name, isNullable: isNullable, uniqueGroup: uniqueGroup);
    adds[name] = cl;
    return this;
  }

  Alter addDatetime(String name,
      {core.bool isNullable = false, String uniqueGroup}) {
    final cl = AddColumn.datetime(name,
        isNullable: isNullable, uniqueGroup: uniqueGroup);
    adds[name] = cl;
    return this;
  }

  Alter modifyInt(String name,
      {core.bool isNullable = false,
      core.bool autoIncrement = false,
      core.bool primary = false,
      String foreignTable,
      String foreignCol,
      String uniqueGroup}) {
    final cl = ModifyColumn.int(name,
        isNullable: isNullable,
        autoIncrement: autoIncrement,
        primary: primary,
        foreignTable: foreignTable,
        foreignCol: foreignCol,
        uniqueGroup: uniqueGroup);
    mods[name] = cl;
    return this;
  }

  Alter modifyDouble(String name,
      {core.bool isNullable = false,
      core.bool primary = false,
      String foreignTable,
      String foreignCol,
      String uniqueGroup}) {
    final cl = ModifyColumn.double(name,
        isNullable: isNullable,
        primary: primary,
        foreignTable: foreignTable,
        foreignCol: foreignCol,
        uniqueGroup: uniqueGroup);
    mods[name] = cl;
    return this;
  }

  Alter modifyString(String name,
      {core.bool isNullable = false,
      core.int length = 20,
      core.bool primary = false,
      String foreignTable,
      String foreignCol,
      String uniqueGroup}) {
    final cl = ModifyColumn.string(name,
        isNullable: isNullable,
        primary: primary,
        length: length,
        foreignTable: foreignTable,
        foreignCol: foreignCol,
        uniqueGroup: uniqueGroup);
    mods[name] = cl;
    return this;
  }

  Alter modifyBool(String name,
      {core.bool isNullable = false, String uniqueGroup}) {
    final cl = ModifyColumn.bool(name,
        isNullable: isNullable, uniqueGroup: uniqueGroup);
    mods[name] = cl;
    return this;
  }

  Alter modifyDatetime(String name,
      {core.bool isNullable = false, String uniqueGroup}) {
    final cl = ModifyColumn.datetime(name,
        isNullable: isNullable, uniqueGroup: uniqueGroup);
    mods[name] = cl;
    return this;
  }
   */

  Alter drop(String name) {
    final cl = DropColumn(name);
    drops[name] = cl;
    return this;
  }
}
