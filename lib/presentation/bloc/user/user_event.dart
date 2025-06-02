import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

abstract class UserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadUser extends UserEvent {}

class CreateUser extends UserEvent {}

class UpdateUserPreferences extends UserEvent {
  final UserPreferences preferences;

  UpdateUserPreferences(this.preferences);

  @override
  List<Object?> get props => [preferences];
}

class PurchaseSubscription extends UserEvent {
  final String productId;

  PurchaseSubscription(this.productId);

  @override
  List<Object?> get props => [productId];
}

class RestorePurchases extends UserEvent {}

class LogOut extends UserEvent {}

class UserChanged extends UserEvent {
  final User? user;

  UserChanged(this.user);

  @override
  List<Object?> get props => [user];
}
