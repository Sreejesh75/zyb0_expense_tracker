import 'package:equatable/equatable.dart';
import 'package:zybo_expense_tracker/features/transactions/models/transaction_model.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactionsEvent extends TransactionEvent {}

class AddTransactionEvent extends TransactionEvent {
  final TransactionModel transaction;
  const AddTransactionEvent(this.transaction);

  @override
  List<Object> get props => [transaction];
}

class DeleteTransactionEvent extends TransactionEvent {
  final String id;
  const DeleteTransactionEvent(this.id);

  @override
  List<Object> get props => [id];
}

class SyncTransactionsEvent extends TransactionEvent {}
