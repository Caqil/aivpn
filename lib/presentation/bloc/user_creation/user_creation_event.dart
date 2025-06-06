// lib/presentation/bloc/user_creation/user_creation_event.dart
import 'package:equatable/equatable.dart';

abstract class UserCreationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateUserAccount extends UserCreationEvent {
  final String userId;
  final bool isPremium;

  CreateUserAccount({
    required this.userId,
    this.isPremium = false,
  });

  @override
  List<Object?> get props => [userId, isPremium];
}

class CheckUserExists extends UserCreationEvent {
  final String userId;

  CheckUserExists(this.userId);

  @override
  List<Object?> get props => [userId];
}

class FetchUserProfile extends UserCreationEvent {
  final String userId;

  FetchUserProfile(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateUserStatus extends UserCreationEvent {
  final String userId;
  final bool isPremium;

  UpdateUserStatus({
    required this.userId,
    required this.isPremium,
  });

  @override
  List<Object?> get props => [userId, isPremium];
}
