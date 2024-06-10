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
  deleteFromTableCommonQuery(String table, String? condition) async {
    // ignore: avoid_print
    print("table--condition -$table---$condition");
    Database db = await instance.database;
    if (condition == null || condition.isEmpty || condition == "") 
    {
      // ignore: avoid_print
      print("no condition");
      await db.delete('$table');
    } 
    else 
    {
      // ignore: avoid_print
      print("condition");
      await db.rawDelete('DELETE FROM "$table" WHERE $condition');
    }
  }
  getCompanyData() async {
    Database db = await instance.database;
    final result =
        await db.rawQuery("SELECT cid,cname,regk,apipath FROM companyRegistrationTable");
    print("company table data.............$result");
    return result;
  }

}
