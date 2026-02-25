import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class TransactionModel extends Equatable {
  final String id;
  final String note;
  final double amount;
  final String type; // "credit" or "debit"
  final String category_id;
  final String? categoryName; // Used for displaying the joined name
  final DateTime timestamp;
  final int is_synced;
  final int is_deleted;

  const TransactionModel({
    required this.id,
    required this.note,
    required this.amount,
    required this.type,
    required this.category_id,
    this.categoryName,
    required this.timestamp,
    this.is_synced = 0,
    this.is_deleted = 0,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      note: json['note'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] ?? 'debit',
      category_id:
          json['category_id'] ??
          json['category'] ??
          '', // Fallbacks during transition
      categoryName: json['categoryName'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      is_synced: json['is_synced'] ?? (json['synced'] ?? 0),
      is_deleted: json['is_deleted'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'note': note,
      'amount': amount,
      'type': type,
      'category_id': category_id,
      'timestamp': timestamp.toIso8601String(),
      'is_synced': is_synced,
      'is_deleted': is_deleted,
    };
  }

  Map<String, dynamic> toApiJson() {
    return {
      'id': id,
      'amount': amount,
      'note': note,
      'type': type,
      'category_id': category_id,
      'timestamp': DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp),
    };
  }

  TransactionModel copyWith({
    String? id,
    String? note,
    double? amount,
    String? type,
    String? category_id,
    String? categoryName,
    DateTime? timestamp,
    int? is_synced,
    int? is_deleted,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      note: note ?? this.note,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category_id: category_id ?? this.category_id,
      categoryName: categoryName ?? this.categoryName,
      timestamp: timestamp ?? this.timestamp,
      is_synced: is_synced ?? this.is_synced,
      is_deleted: is_deleted ?? this.is_deleted,
    );
  }

  @override
  List<Object?> get props => [
    id,
    note,
    amount,
    type,
    category_id,
    categoryName,
    timestamp,
    is_synced,
    is_deleted,
  ];
}
