// lib/presentation/bloc/user_creation/user_creation_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/repositories/user_creation_repository.dart';
import 'user_creation_event.dart';
import 'user_creation_state.dart';

class UserCreationBloc extends Bloc<UserCreationEvent, UserCreationState> {
  final UserCreationRepository repository;

  UserCreationBloc(this.repository) : super(UserCreationInitial()) {
    on<CreateUserAccount>(_onCreateUserAccount);
    on<CheckUserExists>(_onCheckUserExists);
    on<FetchUserProfile>(_onFetchUserProfile);
    on<UpdateUserStatus>(_onUpdateUserStatus);
  }

  Future<void> _onCreateUserAccount(
    CreateUserAccount event,
    Emitter<UserCreationState> emit,
  ) async {
    emit(UserCreationLoading());
    try {
      final userProfile = await repository.createUser(
        userId: event.userId,
        isPremium: event.isPremium,
      );

      emit(UserCreationSuccess(userProfile));
    } catch (e) {
      emit(UserCreationError(e.toString()));
    }
  }

  Future<void> _onCheckUserExists(
    CheckUserExists event,
    Emitter<UserCreationState> emit,
  ) async {
    emit(UserCreationLoading());
    try {
      final exists = await repository.checkUserExists(event.userId);
      if (exists) {
        final userProfile = await repository.fetchUserProfile(event.userId);
        emit(UserProfileLoaded(userProfile));
      } else {
        emit(UserNotFound());
      }
    } catch (e) {
      emit(UserCreationError(e.toString()));
    }
  }

  Future<void> _onFetchUserProfile(
    FetchUserProfile event,
    Emitter<UserCreationState> emit,
  ) async {
    emit(UserCreationLoading());
    try {
      final userProfile = await repository.fetchUserProfile(event.userId);
      emit(UserProfileLoaded(userProfile));
    } catch (e) {
      emit(UserCreationError(e.toString()));
    }
  }

  Future<void> _onUpdateUserStatus(
    UpdateUserStatus event,
    Emitter<UserCreationState> emit,
  ) async {
    emit(UserCreationLoading());
    try {
      await repository.updateUserStatus(
        userId: event.userId,
        isPremium: event.isPremium,
      );

      final userProfile = await repository.fetchUserProfile(event.userId);
      emit(UserProfileLoaded(userProfile));
    } catch (e) {
      emit(UserCreationError(e.toString()));
    }
  }
}
