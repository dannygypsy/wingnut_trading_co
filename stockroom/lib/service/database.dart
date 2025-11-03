import 'package:mysql1/mysql1.dart';
import 'package:stockroom/config/config.dart';

class Database {
  static Database? _instance;
  MySqlConnection? _connection;

  // Connection settings
  final ConnectionSettings _settings = ConnectionSettings(
    host: Config.databaseHost,
    port: 3306,
    user: 'your_username',
    password: 'your_password',
    db: 'your_database',
  );

  // Singleton pattern
  Database._();

  static Database get instance {
    _instance ??= Database._();
    return _instance!;
  }

  // Get or create connection
  Future<MySqlConnection> get connection async {
    if (_connection == null || _connection!.isClosed) {
      _connection = await MySqlConnection.connect(_settings);
    }
    return _connection!;
  }

  // Query multiple rows
  Future<List<Map<String, dynamic>>> query(
      String sql, [
        List<Object?>? values,
      ]) async {
    final conn = await connection;
    final results = await conn.query(sql, values);

    return results.map((row) => row.fields).toList();
  }

  // Query single row
  Future<Map<String, dynamic>?> querySingle(
      String sql, [
        List<Object?>? values,
      ]) async {
    final results = await query(sql, values);
    return results.isEmpty ? null : results.first;
  }

  // Insert and return inserted ID
  Future<int> insert(String sql, [List<Object?>? values]) async {
    final conn = await connection;
    final result = await conn.query(sql, values);
    return result.insertId ?? 0;
  }

  // Update/Delete and return affected rows
  Future<int> execute(String sql, [List<Object?>? values]) async {
    final conn = await connection;
    final result = await conn.query(sql, values);
    return result.affectedRows ?? 0;
  }

  // Transaction support
  Future<T> transaction<T>(
      Future<T> Function(MySqlConnection conn) action,
      ) async {
    final conn = await connection;
    await conn.query('START TRANSACTION');

    try {
      final result = await action(conn);
      await conn.query('COMMIT');
      return result;
    } catch (e) {
      await conn.query('ROLLBACK');
      rethrow;
    }
  }

  // Close connection
  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }
}