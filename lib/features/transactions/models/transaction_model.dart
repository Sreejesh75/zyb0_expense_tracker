import 'package:equatable/equatable.dart';

class TransactionModel extends Equatable {
  final String id;
  final String note;
  final double amount;
  final String type; // "credit" or "debit"
  final String category;
  final DateTime timestamp;

  const TransactionModel({
    required this.id,
    required this.note,
    required this.amount,
    required this.type,
    required this.category,
    required this.timestamp,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      note: json['note'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] ?? 'debit',
      category: json['category'] ?? json['category_id'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'note': note,
      'amount': amount,
      'type': type,
      'category': category,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  Map<String, dynamic> toApiJson() {
    return {
      'id': id,
      'note': note,
      'amount': amount,
      'type': type,
      'category_id': category, // Based on API specs
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, note, amount, type, category, timestamp];
}
