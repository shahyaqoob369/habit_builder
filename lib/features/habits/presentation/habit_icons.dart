import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';

extension HabitIconX on HabitIcon {
  /// The Font Awesome (free, solid) glyph, as in the design's
  /// "fa-solid:book-reader".
  FaIconData get glyph => switch (this) {
    HabitIcon.book => FontAwesomeIcons.bookOpenReader,
    HabitIcon.run => FontAwesomeIcons.personRunning,
    HabitIcon.workout => FontAwesomeIcons.dumbbell,
    HabitIcon.walk => FontAwesomeIcons.personWalking,
    HabitIcon.bike => FontAwesomeIcons.bicycle,
    HabitIcon.swim => FontAwesomeIcons.personSwimming,
    HabitIcon.sleep => FontAwesomeIcons.bed,
    HabitIcon.wakeUp => FontAwesomeIcons.sun,
    HabitIcon.water => FontAwesomeIcons.droplet,
    HabitIcon.fruit => FontAwesomeIcons.appleWhole,
    HabitIcon.veggies => FontAwesomeIcons.carrot,
    HabitIcon.meds => FontAwesomeIcons.pills,
    HabitIcon.teeth => FontAwesomeIcons.tooth,
    HabitIcon.relax => FontAwesomeIcons.spa,
    HabitIcon.pray => FontAwesomeIcons.personPraying,
    HabitIcon.learn => FontAwesomeIcons.brain,
    HabitIcon.write => FontAwesomeIcons.pen,
    HabitIcon.language => FontAwesomeIcons.language,
    HabitIcon.music => FontAwesomeIcons.music,
    HabitIcon.dog => FontAwesomeIcons.dog,
    HabitIcon.plants => FontAwesomeIcons.seedling,
    HabitIcon.clean => FontAwesomeIcons.broom,
    HabitIcon.save => FontAwesomeIcons.piggyBank,
    HabitIcon.quit => FontAwesomeIcons.ban,
  };
}
