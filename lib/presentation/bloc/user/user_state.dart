import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

abstract class UserState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final User user;

  UserLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class UserNotFound extends UserState {}

class UserPurchasing extends UserState {
  final User user;

  UserPurchasing(this.user);

  @override
  List<Object?> get props => [user];
}

class UserPurchaseSuccess extends UserState {
  final User user;

  UserPurchaseSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class UserPurchaseError extends UserState {
  final User user;
  final String message;

  UserPurchaseError(this.user, this.message);

  @override
  List<Object?> get props => [user, message];
}

class UserError extends UserState {
  final String message;

  UserError(this.message);

  @override
  List<Object?> get props => [message];
}
