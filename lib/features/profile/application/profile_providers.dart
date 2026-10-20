import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_builder/features/auth/data/fake_auth_repository.dart';
import 'package:habit_builder/features/auth/domain/auth_user.dart';
import 'package:habit_builder/features/habits/application/habits_providers.dart';
import 'package:habit_builder/features/profile/domain/profile_stats.dart';

/// The signed-in user, kept up to date when the profile is edited.
class CurrentUserController extends Notifier<AuthUser?> {
  @override
  AuthUser? build() => ref.watch(authRepositoryProvider).currentUser;

  Future<void> rename(String name) async {
    state = await ref.read(authRepositoryProvider).updateName(name.trim());
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = null;
  }

  Future<void> deleteAccount() async {
    await ref.read(authRepositoryProvider).deleteAccount();
    state = null;
  }
}

final NotifierProvider<CurrentUserController, AuthUser?> currentUserProvider =
    NotifierProvider<CurrentUserController, AuthUser?>(
      CurrentUserController.new,
    );

/// The period chosen on the profile.
class ProfilePeriodController extends Notifier<ProfilePeriod> {
  @override
  ProfilePeriod build() => ProfilePeriod.thisWeek;

  ProfilePeriod get period => state;

  set period(ProfilePeriod value) => state = value;
}

final NotifierProvider<ProfilePeriodController, ProfilePeriod>
profilePeriodProvider =
    NotifierProvider<ProfilePeriodController, ProfilePeriod>(
      ProfilePeriodController.new,
    );

/// The profile numbers for the chosen period.
final Provider<AsyncValue<ProfileStats>> profileStatsProvider =
    Provider<AsyncValue<ProfileStats>>((ref) {
      final period = ref.watch(profilePeriodProvider);
      final today = ref.watch(todayProvider);
      return ref
          .watch(habitsProvider)
          .whenData((habits) => ProfileStats.of(habits, today, period));
    });
