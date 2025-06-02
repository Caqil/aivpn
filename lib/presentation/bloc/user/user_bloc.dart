import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;
  StreamSubscription<User?>? _userSubscription;

  UserBloc(this.repository) : super(UserInitial()) {
    on<LoadUser>(_onLoadUser);
    on<CreateUser>(_onCreateUser);
    on<UpdateUserPreferences>(_onUpdateUserPreferences);
    on<PurchaseSubscription>(_onPurchaseSubscription);
    on<RestorePurchases>(_onRestorePurchases);
    on<LogOut>(_onLogOut);
    on<UserChanged>(_onUserChanged);

    _subscribeToUserStream();
  }

  void _subscribeToUserStream() {
    _userSubscription = repository.userStream.listen(
      (user) => add(UserChanged(user)),
    );
  }

  Future<void> _onLoadUser(LoadUser event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final user = await repository.getCurrentUser();
      if (user != null) {
        emit(UserLoaded(user));
      } else {
        emit(UserNotFound());
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onCreateUser(CreateUser event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final user = await repository.createOrUpdateUser();
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUpdateUserPreferences(
    UpdateUserPreferences event,
    Emitter<UserState> emit,
  ) async {
    try {
      await repository.updateUserPreferences(event.preferences);

      if (state is UserLoaded) {
        final currentState = state as UserLoaded;
        final updatedUser = currentState.user.copyWith(
          preferences: event.preferences,
        );
        emit(UserLoaded(updatedUser));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onPurchaseSubscription(
    PurchaseSubscription event,
    Emitter<UserState> emit,
  ) async {
    if (state is UserLoaded) {
      final currentState = state as UserLoaded;
      emit(UserPurchasing(currentState.user));

      try {
        final success = await repository.purchaseSubscription(event.productId);

        if (success) {
          // The subscription will be updated through the user stream
          final updatedUser = await repository.getCurrentUser();
          if (updatedUser != null) {
            emit(UserPurchaseSuccess(updatedUser));
          }
        } else {
          emit(UserPurchaseError(currentState.user, 'Purchase failed'));
        }
      } catch (e) {
        emit(UserPurchaseError(currentState.user, e.toString()));
      }
    }
  }

  Future<void> _onRestorePurchases(
    RestorePurchases event,
    Emitter<UserState> emit,
  ) async {
    if (state is UserLoaded) {
      final currentState = state as UserLoaded;
      emit(UserPurchasing(currentState.user));

      try {
        final success = await repository.restorePurchases();

        if (success) {
          final updatedUser = await repository.getCurrentUser();
          if (updatedUser != null) {
            emit(UserPurchaseSuccess(updatedUser));
          }
        } else {
          emit(UserPurchaseError(currentState.user, 'No purchases to restore'));
        }
      } catch (e) {
        emit(UserPurchaseError(currentState.user, e.toString()));
      }
    }
  }

  Future<void> _onLogOut(LogOut event, Emitter<UserState> emit) async {
    try {
      await repository.logOut();
      emit(UserNotFound());
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  void _onUserChanged(UserChanged event, Emitter<UserState> emit) {
    if (event.user != null) {
      emit(UserLoaded(event.user!));
    } else {
      emit(UserNotFound());
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
