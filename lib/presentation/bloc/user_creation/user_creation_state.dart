import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_profile.dart';

abstract class UserCreationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserCreationInitial extends UserCreationState {}

class UserCreationLoading extends UserCreationState {}

class UserCreationSuccess extends UserCreationState {
  final UserProfile userProfile;

  UserCreationSuccess(this.userProfile);

  @override
  List<Object?> get props => [userProfile];
}

class UserProfileLoaded extends UserCreationState {
  final UserProfile userProfile;

  UserProfileLoaded(this.userProfile);

  @override
  List<Object?> get props => [userProfile];
}

class UserNotFound extends UserCreationState {}

class UserCreationError extends UserCreationState {
  final String message;

  UserCreationError(this.message);

  @override
  List<Object?> get props => [message];
}
