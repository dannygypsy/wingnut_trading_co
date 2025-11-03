import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dart_mysql/dart_mysql.dart';

class Database {
  static Database? _instance;
  MySQLConnection? _connection;

  // Singleton pattern
  Database._();

  static Database get instance {
    _instance ??= Database._();
    return _instance!;
  }

  // Get or create connection
  Future<MySQLConnection> get connection async {
    try {
      if (_connection == null) {
        print('Connecting to: ${dotenv.env['DB_HOST']}:${dotenv.env['DB_PORT']}');

        _connection = await MySQLConnection.createConnection(
          host: dotenv.env['DB_HOST']!,
          port: int.parse(dotenv.env['DB_PORT']!),
          userName: dotenv.env['DB_USER']!,
          password: dotenv.env['DB_PASSWORD']!,
          databaseName: dotenv.env['DB_NAME']!,
        );

        await _connection!.connect();
        print('Connected successfully!');
      }
      return _connection!;
    } catch (e, stackTrace) {
      print('Connection error: $e');
      print('Stack trace: $stackTrace');
      _connection = null;
      rethrow;
    }
  }

  // Query multiple rows
  Future<List<Map<String, dynamic>>> query(
      String sql, [
        Map<String, dynamic>? params,
      ]) async {
    final conn = await connection;
    final result = await conn.execute(sql, params);

    List<Map<String, dynamic>> rows = [];
    for (final row in result.rows) {
      rows.add(row.assoc());
    }

    return rows;
  }

  // Query single row
  Future<Map<String, dynamic>?> querySingle(
      String sql, [
        Map<String, dynamic>? params,
      ]) async {
    final results = await query(sql, params);
    return results.isEmpty ? null : results.first;
  }

  // Insert and return inserted ID
  Future<int> insert(String sql, [Map<String, dynamic>? params]) async {
    final conn = await connection;
    final result = await conn.execute(sql, params);
    return result.lastInsertID;
  }

  // Update/Delete and return affected rows
  Future<int> execute(String sql, [Map<String, dynamic>? params]) async {
    final conn = await connection;
    final result = await conn.execute(sql, params);
    return result.affectedRows;
  }

  // Transaction support
  Future<T> transaction<T>(
      Future<T> Function(MySQLConnection conn) action,
      ) async {
    final conn = await connection;
    await conn.execute('START TRANSACTION');

    try {
      final result = await action(conn);
      await conn.execute('COMMIT');
      return result;
    } catch (e) {
      await conn.execute('ROLLBACK');
      rethrow;
    }
  }

  // Close connection
  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }
}