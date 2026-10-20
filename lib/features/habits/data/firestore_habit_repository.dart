import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:habit_builder/features/habits/data/habit_mapper.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';
import 'package:habit_builder/features/habits/domain/habit_repository.dart';

/// [HabitRepository] backed by Firestore at `users/{uid}/habits`.
///
/// Works offline: Firestore keeps a local copy, so changes show at once
/// and sync when the device is back online. Writes therefore don't wait
/// for the server (that would hang the UI while offline); a write the
/// server rejects is logged and rolled back by Firestore.
class FirestoreHabitRepository implements HabitRepository {
  FirestoreHabitRepository({required String uid, FirebaseFirestore? firestore})
    : _habits = (firestore ?? FirebaseFirestore.instance)
          .collection('users')
          .doc(uid)
          .collection(collection);

  /// The subcollection name, also used when deleting the account.
  static const collection = 'habits';

  final CollectionReference<Map<String, Object?>> _habits;

  @override
  Stream<List<Habit>> watchHabits() => _habits
      .orderBy('sortKey')
      .snapshots()
      .map(
        (snapshot) => [
          for (final doc in snapshot.docs)
            HabitMapper.fromFirestore(doc.id, doc.data()),
        ],
      );

  @override
  Future<Habit> addHabit(Habit habit) async {
    final doc = _habits.doc();
    final data = HabitMapper.toFirestore(
      habit,
      sortKey: DateTime.now().millisecondsSinceEpoch,
    );
    _write(doc.set(data));
    return HabitMapper.fromFirestore(doc.id, data);
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    // update() replaces each field, so days cleared from the log go away.
    // createdAt and sortKey never change.
    final data = HabitMapper.toFirestore(habit)
      ..remove('createdAt')
      ..remove('sortKey');
    _write(_habits.doc(habit.id).update(data));
  }

  @override
  Future<void> deleteHabit(String id) async => _write(_habits.doc(id).delete());

  @override
  Future<void> setStatus(String id, DateTime day, DayStatus? status) async {
    final key = HabitMapper.dayKey(day);
    _write(
      _habits.doc(id).update({
        FieldPath(['log', key]): status?.name ?? FieldValue.delete(),
        // A day that is no longer done has no easiness rating.
        if (status != DayStatus.done)
          FieldPath(['easiness', key]): FieldValue.delete(),
      }),
    );
  }

  static void _write(Future<void> write) {
    unawaited(
      write.catchError((Object error) {
        debugPrint('Habit write failed: $error');
      }),
    );
  }
}

/// Used while nobody is signed in: no habits, and nothing can be saved.
class SignedOutHabitRepository implements HabitRepository {
  const SignedOutHabitRepository();

  @override
  Stream<List<Habit>> watchHabits() => Stream.value(const []);

  @override
  Future<Habit> addHabit(Habit habit) => Future.error(_signedOut);

  @override
  Future<void> updateHabit(Habit habit) => Future.error(_signedOut);

  @override
  Future<void> deleteHabit(String id) => Future.error(_signedOut);

  @override
  Future<void> setStatus(String id, DateTime day, DayStatus? status) =>
      Future.error(_signedOut);

  static final _signedOut = StateError('Not signed in');
}
