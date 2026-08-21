import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/borrow_record.dart';
import '../models/device.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  final _uuid = const Uuid();

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
        ALTER TABLE borrow_records
        ADD COLUMN dueDate TEXT NOT NULL DEFAULT ''
      ''');
        }
      },
    );
  }


  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE devices (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        status TEXT NOT NULL,
        isNew INTEGER NOT NULL
      )
    ''');

    await db.execute('''
  CREATE TABLE borrow_records (
    id TEXT PRIMARY KEY,
    userId TEXT NOT NULL,
    deviceId TEXT NOT NULL,
    borrowDate TEXT NOT NULL,
    dueDate TEXT NOT NULL,
    returnDate TEXT NOT NULL,
    status TEXT NOT NULL,
    FOREIGN KEY (userId) REFERENCES users (id),
    FOREIGN KEY (deviceId) REFERENCES devices (id)
  )
''');

    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    await db.insert('users', {
      'id': 'u1',
      'name': 'Sinh viên A',
      'email': 'sv@gmail.com',
      'password': '123',
      'role': 'student',
    });

    final devices = [
      {
        'id': 'd1',
        'name': 'Máy chiếu Panasonic PT-LB303',
        'description': 'Máy chiếu độ phân giải cao, phù hợp phòng học.',
        'category': 'Máy chiếu',
        'imageUrl':
            'https://media.meta.vn/Data/image/2021/02/22/may-chieu-panasonic-pt-lb303.jpg',
        'status': 'available',
        'isNew': 1,
      },
      {
        'id': 'd2',
        'name': 'Micro Không Dây Shure',
        'description': 'Micro thu âm tốt, chống ồn hiệu quả.',
        'category': 'Âm thanh',
        'imageUrl':
            'https://images.hdradio.vn/upload/hinhanh/micro-karaoke/micro-khong-day-shure/pga58lc/pga58lc-avt.jpg?v=1.1.2.6',
        'status': 'available',
        'isNew': 1,
      },
      {
        'id': 'd3',
        'name': 'Loa Kéo Karaoke',
        'description': 'Loa di động, công suất lớn.',
        'category': 'Âm thanh',
        'imageUrl':
            'https://cdn11.dienmaycholon.vn/filewebdmclnew/DMCL21/Picture//Apro/Apro_product_32621/loa-keo-nanomax-k18x5-multi-0.png',
        'status': 'available',
        'isNew': 0,
      },
      {
        'id': 'd4',
        'name': 'Cáp HDMI 5m',
        'description': 'Cáp nối máy tính với máy chiếu.',
        'category': 'Phụ kiện',
        'imageUrl': 'https://www.civip.com.vn/media/product/5080_hdmi5.jpg',
        'status': 'available',
        'isNew': 0,
      },
      {
        'id': 'd5',
        'name': 'Laptop Dell Latitude',
        'description': 'Laptop dự phòng cho giảng viên.',
        'category': 'Máy tính',
        'imageUrl':
            'https://down-vn.img.susercontent.com/file/vn-11134207-7ras8-m5thv23zpkk7a1@resize_w900_nl.webp',
        'status': 'unavailable',
        'isNew': 0,
      },
      {
        'id': 'd6',
        'name': 'Bảng Vẽ Điện Tử Wacom',
        'description': 'Hỗ trợ dạy học online.',
        'category': 'Phụ kiện',
        'imageUrl':
            'https://media.meta.vn/Data/image/2019/12/06/bang-ve-wacom-intuos-medium-bluetooth-black-ctl-6100wl-k0-cx-1.jpg',
        'status': 'available',
        'isNew': 1,
      },
    ];

    for (final device in devices) {
      await db.insert('devices', device);
    }
  }

  Future<User?> authenticate(String email, String password) async {
    final db = await database;

    final maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isEmpty) return null;

    return User.fromMap(maps.first);
  }

  Future<List<Device>> getAllDevices() async {
    final db = await database;
    final result = await db.query('devices');
    return result.map((e) => Device.fromMap(e)).toList();
  }

  Future<Device?> getDeviceById(String id) async {
    final db = await database;

    final maps = await db.query('devices', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) return null;

    return Device.fromMap(maps.first);
  }

  Future<int> updateDeviceStatus(String id, String status) async {
    final db = await database;

    return db.update(
      'devices',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> createDevice(Device device) async {
    final db = await database;

    final data = device.toMap();

    if (data['id'] == null || data['id'].toString().isEmpty) {
      data['id'] = _uuid.v4();
    }

    return db.insert('devices', data);
  }

  Future<int> updateDevice(Device device) async {
    final db = await database;

    return db.update(
      'devices',
      device.toMap(),
      where: 'id = ?',
      whereArgs: [device.id],
    );
  }

  Future<int> deleteDevice(String id) async {
    final db = await database;

    return db.delete('devices', where: 'id = ?', whereArgs: [id]);
  }

  Future<BorrowRecord> createBorrowRecord(BorrowRecord record) async {
    final db = await database;

    final data = record.toMap();

    if (data['id'] == null || data['id'].toString().isEmpty) {
      data['id'] = _uuid.v4();
    }

    await db.insert('borrow_records', data);

    return BorrowRecord.fromMap(data);
  }

  Future<List<BorrowRecord>> getBorrowRecordsByUser(String userId) async {
    final db = await database;

    final result = await db.query(
      'borrow_records',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'borrowDate DESC',
    );

    return result.map((e) => BorrowRecord.fromMap(e)).toList();
  }

  Future<int> updateBorrowRecordStatus(String id, String status) async {
    final db = await database;

    return db.update(
      'borrow_records',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteBorrowRecord(String id) async {
    final db = await database;

    return db.delete('borrow_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<int> updateUser(User user) async {
    final db = await database;

    return db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> changePassword(String userId, String newPassword) async {
    final db = await database;

    return db.update(
      'users',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> returnDevice(String recordId, String deviceId) async {
    final db = await database;

    await db.update(
      'borrow_records',
      {'status': 'returned', 'returnDate': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [recordId],
    );

    return await db.update(
      'devices',
      {'status': 'available'},
      where: 'id = ?',
      whereArgs: [deviceId],
    );
  }

  Future<bool> emailExists(String email) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    return result.isNotEmpty;
  }

  Future<bool> registerUser(User user) async {
    final db = await database;

    if (await emailExists(user.email)) {
      return false;
    }

    await db.insert('users', user.toMap());

    return true;
  }

  Future<List<BorrowRecord>> getOverdueRecords() async {
    final db = await database;

    final result = await db.query('borrow_records', where: "returnDate = ''");

    final records = result.map((e) => BorrowRecord.fromMap(e)).toList();

    return records.where((record) {
      return DateTime.now().isAfter(DateTime.parse(record.dueDate));
    }).toList();
  }
}
