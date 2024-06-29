import 'package:inventory24/MODEL/logModel.dart';
import 'package:inventory24/MODEL/regModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class INVENT {
  static final INVENT instance = INVENT._init();
  static Database? _database;
  INVENT._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("INVENT.db");
    return _database!;
  }

////////////////////////////////////////////////////////

  Future<Database> _initDB(String filepath) async {
    final dbpath = await getDatabasesPath();
    final path = join(dbpath, filepath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  //////////////////////////////////////////////////////////
  Future _createDB(Database db, int version) async {
    ///////////////barcode store table ////////////////
    await db.execute('''
          CREATE TABLE companyRegistrationTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            msg TEXT,
            flag INTEGER,
            cid TEXT NOT NULL,
            cname TEXT NOT NULL,
            regk TEXT NOT NULL,
            apipath TEXT
          )
          ''');
    await db.execute('''
          CREATE TABLE loginDetailsTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            msg TEXT,
            flag INTEGER,
            branch_validate_id TEXT,
            session_id TEXT,
            user_id TEXT,
            user_print_name TEXT,
            user_type INTEGER,
            company_id TEXT,
            branch_id TEXT,
            company_name TEXT,
            company_state INTEGER,
            company_GSTIN TEXT
          )
          ''');
  }

  Future insertToCompanyRegistration(RegisterModel data) async {
    final db = await database;
    var query1 =
        'INSERT INTO companyRegistrationTable(msg,flag,cid,cname,regk,apipath)VALUES ("${data.msg}","${data.flag}","${data.com_id}","${data.com_name}","${data.reg_key}","${data.api_path}")';
    var res = await db.rawInsert(query1);
    print(query1);
    print("COM registered ----$res");
    return res;
  }

  Future insertTologinDetailsTable(LoginModel logdata) async {
    // loginDetailsTable
    final db = await database;
    var query =
        'INSERT INTO loginDetailsTable(msg,flag,branch_validate_id,session_id,user_id,user_print_name,user_type,company_id,branch_id,company_name,company_state,company_GSTIN)VALUES("${logdata.msg}","${logdata.flag}","${logdata.br_val_id}","${logdata.sesn_id}","${logdata.user_id}","${logdata.user_printNM}","${logdata.user_typ}","${logdata.com_id}","${logdata.br_id}","${logdata.com_name}","${logdata.com_state}","${logdata.com_gst}")';
    var res = await db.rawInsert(query);
    print("LoginAdded TO Table ----$res");
    return res;
  }

  deleteFromTableCommonQuery(String table, String? condition) async {
    // ignore: avoid_print
    print("table--condition -$table---$condition");
    Database db = await instance.database;
    if (condition == null || condition.isEmpty || condition == "") {
      // ignore: avoid_print
      print("no condition");
      await db.delete('$table');
    } else {
      // ignore: avoid_print
      print("condition");
      await db.rawDelete('DELETE FROM "$table" WHERE $condition');
    }
  }

  getCompanyData() async {
    Database db = await instance.database;
    final result = await db.rawQuery(
        "SELECT cid,cname,regk,apipath FROM companyRegistrationTable");
    print("company table data.............$result");
    return result;
  }
  getListOfTables() async {
    Database db = await instance.database;
    var list = await db.query('sqlite_master', columns: ['type', 'name']);
    print(list);
    list.map((e) => print(e["name"])).toList();
    return list;
    // list.forEach((row) {
    //   print(row.values);
    // });
  }
   getTableData(String tablename) async {
    Database db = await instance.database;
    print(tablename);
    var list = await db.rawQuery('SELECT * FROM $tablename');
    print(list);
    return list;
    // list.map((e) => print(e["name"])).toList();
    // return list;
    // list.forEach((row) {
    //   print(row.values);
    // });
  }
}
