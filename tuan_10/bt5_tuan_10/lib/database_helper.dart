import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('favorite_routes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Tạo bảng lưu trữ [cite: 992]
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        destination_lat TEXT,
        destination_lng TEXT
      )
    ''');
  }

  // Hàm thêm vào mục yêu thích
  Future<int> saveFavorite(String name, String lat, String lng) async {
    final db = await instance.database;
    return await db.insert('favorites', {
      'name': name,
      'destination_lat': lat,
      'destination_lng': lng,
    });
  }

  // Hàm lấy danh sách yêu thích ra
  Future<List<Map<String, dynamic>>> getFavorites() async {
    final db = await instance.database;
    return await db.query('favorites', orderBy: 'id DESC');
  }
}
