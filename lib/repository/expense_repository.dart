import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/expense.dart';

class ExpenseRepository {
  Future<Database> get _db async => DatabaseHelper.instance.database;

  Future<void> insertExpense(Expense expense) async {
    final db = await _db;
    await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Expense>> getExpenses() async {
    final db = await _db;
    final maps = await db.query('expenses', orderBy: 'date DESC');
    return maps.map((m) => Expense.fromMap(m)).toList();
  }

  Future<void> updateExpense(Expense expense) async {
    final db = await _db;
    await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<void> deleteExpense(String id) async {
    final db = await _db;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }
}