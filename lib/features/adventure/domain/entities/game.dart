import 'package:equatable/equatable.dart';
import '../enums/score_bonus.dart';
import 'dwarf.dart';
import 'game_object.dart';
import 'hint.dart';
import 'location_state.dart';

class Game extends Equatable {
  final int lcgX;
  final int abbNum;
  final ScoreBonus bonus;
  final int chLoc;
  final int chLoc2;
  final int clock1;
  final int clock2;
  final bool clshnt;
  final bool closed;
  final bool closng;
  final bool lmwarn;
  final bool novice;
  final bool panic;
  final bool wzdark;
  final bool blooded;
  final int conds;
  final int detail;
  final int dflag;
  final int dkill;
  final int dtotal;
  final int foobar;
  final int holdng;
  final int igo;
  final int iwest;
  final int knfloc;
  final int limit;
  final int loc;
  final int newloc;
  final int numdie;
  final int oldloc;
  final int oldlc2;
  final int oldobj;
  final int saved;
  final int tally;
  final int thresh;
  final bool seenbigwords;
  final int trnluz;
  final int turns;
  final String zzword;
  final List<LocationState> locs;
  final List<Dwarf> dwarves;
  final List<GameObject> objects;
  final List<Hint> hints;
  final List<int> link;

  const Game({
    required this.lcgX,
    required this.abbNum,
    required this.bonus,
    required this.chLoc,
    required this.chLoc2,
    required this.clock1,
    required this.clock2,
    required this.clshnt,
    required this.closed,
    required this.closng,
    required this.lmwarn,
    required this.novice,
    required this.panic,
    required this.wzdark,
    required this.blooded,
    required this.conds,
    required this.detail,
    required this.dflag,
    required this.dkill,
    required this.dtotal,
    required this.foobar,
    required this.holdng,
    required this.igo,
    required this.iwest,
    required this.knfloc,
    required this.limit,
    required this.loc,
    required this.newloc,
    required this.numdie,
    required this.oldloc,
    required this.oldlc2,
    required this.oldobj,
    required this.saved,
    required this.tally,
    required this.thresh,
    required this.seenbigwords,
    required this.trnluz,
    required this.turns,
    required this.zzword,
    required this.locs,
    required this.dwarves,
    required this.objects,
    required this.hints,
    required this.link,
  });

  @override
  List<Object?> get props => [
    lcgX,
    abbNum,
    bonus,
    chLoc,
    chLoc2,
    clock1,
    clock2,
    clshnt,
    closed,
    closng,
    lmwarn,
    novice,
    panic,
    wzdark,
    blooded,
    conds,
    detail,
    dflag,
    dkill,
    dtotal,
    foobar,
    holdng,
    igo,
    iwest,
    knfloc,
    limit,
    loc,
    newloc,
    numdie,
    oldloc,
    oldlc2,
    oldobj,
    saved,
    tally,
    thresh,
    seenbigwords,
    trnluz,
    turns,
    zzword,
    locs,
    dwarves,
    objects,
    hints,
    link,
  ];
}
