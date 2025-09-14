import '../../domain/entities/game.dart';
import '../../domain/enums/score_bonus.dart';
import 'dwarf_model.dart';
import 'location_state_model.dart';
import 'game_object_model.dart';
import 'hint_model.dart';

class GameModel {
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
  final List<LocationStateModel> locs;
  final List<DwarfModel> dwarves;
  final List<GameObjectModel> objects;
  final List<HintModel> hints;
  final List<int> link;

  const GameModel({
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

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      lcgX: json['lcgX'],
      abbNum: json['abbNum'],
      bonus: ScoreBonus.values[json['bonus']],
      chLoc: json['chLoc'],
      chLoc2: json['chLoc2'],
      clock1: json['clock1'],
      clock2: json['clock2'],
      clshnt: json['clshnt'],
      closed: json['closed'],
      closng: json['closng'],
      lmwarn: json['lmwarn'],
      novice: json['novice'],
      panic: json['panic'],
      wzdark: json['wzdark'],
      blooded: json['blooded'],
      conds: json['conds'],
      detail: json['detail'],
      dflag: json['dflag'],
      dkill: json['dkill'],
      dtotal: json['dtotal'],
      foobar: json['foobar'],
      holdng: json['holdng'],
      igo: json['igo'],
      iwest: json['iwest'],
      knfloc: json['knfloc'],
      limit: json['limit'],
      loc: json['loc'],
      newloc: json['newloc'],
      numdie: json['numdie'],
      oldloc: json['oldloc'],
      oldlc2: json['oldlc2'],
      oldobj: json['oldobj'],
      saved: json['saved'],
      tally: json['tally'],
      thresh: json['thresh'],
      seenbigwords: json['seenbigwords'],
      trnluz: json['trnluz'],
      turns: json['turns'],
      zzword: json['zzword'],
      locs: (json['locs'] as List)
          .map((e) => LocationStateModel.fromJson(e))
          .toList(),
      dwarves: (json['dwarves'] as List)
          .map((e) => DwarfModel.fromJson(e))
          .toList(),
      objects: (json['objects'] as List)
          .map((e) => GameObjectModel.fromJson(e))
          .toList(),
      hints:
      (json['hints'] as List).map((e) => HintModel.fromJson(e)).toList(),
      link: List<int>.from(json['link']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lcgX': lcgX,
      'abbNum': abbNum,
      'bonus': bonus.index,
      'chLoc': chLoc,
      'chLoc2': chLoc2,
      'clock1': clock1,
      'clock2': clock2,
      'clshnt': clshnt,
      'closed': closed,
      'closng': closng,
      'lmwarn': lmwarn,
      'novice': novice,
      'panic': panic,
      'wzdark': wzdark,
      'blooded': blooded,
      'conds': conds,
      'detail': detail,
      'dflag': dflag,
      'dkill': dkill,
      'dtotal': dtotal,
      'foobar': foobar,
      'holdng': holdng,
      'igo': igo,
      'iwest': iwest,
      'knfloc': knfloc,
      'limit': limit,
      'loc': loc,
      'newloc': newloc,
      'numdie': numdie,
      'oldloc': oldloc,
      'oldlc2': oldlc2,
      'oldobj': oldobj,
      'saved': saved,
      'tally': tally,
      'thresh': thresh,
      'seenbigwords': seenbigwords,
      'trnluz': trnluz,
      'turns': turns,
      'zzword': zzword,
      'locs': locs.map((e) => e.toJson()).toList(),
      'dwarves': dwarves.map((e) => e.toJson()).toList(),
      'objects': objects.map((e) => e.toJson()).toList(),
      'hints': hints.map((e) => e.toJson()).toList(),
      'link': link,
    };
  }

  // Méthodes pour convertir entre GameModel et Game
  Game toEntity() {
    return Game(
      lcgX: lcgX,
      abbNum: abbNum,
      bonus: bonus,
      chLoc: chLoc,
      chLoc2: chLoc2,
      clock1: clock1,
      clock2: clock2,
      clshnt: clshnt,
      closed: closed,
      closng: closng,
      lmwarn: lmwarn,
      novice: novice,
      panic: panic,
      wzdark: wzdark,
      blooded: blooded,
      conds: conds,
      detail: detail,
      dflag: dflag,
      dkill: dkill,
      dtotal: dtotal,
      foobar: foobar,
      holdng: holdng,
      igo: igo,
      iwest: iwest,
      knfloc: knfloc,
      limit: limit,
      loc: loc,
      newloc: newloc,
      numdie: numdie,
      oldloc: oldloc,
      oldlc2: oldlc2,
      oldobj: oldobj,
      saved: saved,
      tally: tally,
      thresh: thresh,
      seenbigwords: seenbigwords,
      trnluz: trnluz,
      turns: turns,
      zzword: zzword,
      locs: locs.map((e) => e.toEntity()).toList(),
      dwarves: dwarves.map((e) => e.toEntity()).toList(),
      objects: objects.map((e) => e.toEntity()).toList(),
      hints: hints.map((e) => e.toEntity()).toList(),
      link: link,
    );
  }

  factory GameModel.fromEntity(Game game) {
    return GameModel(
      lcgX: game.lcgX,
      abbNum: game.abbNum,
      bonus: game.bonus,
      chLoc: game.chLoc,
      chLoc2: game.chLoc2,
      clock1: game.clock1,
      clock2: game.clock2,
      clshnt: game.clshnt,
      closed: game.closed,
      closng: game.closng,
      lmwarn: game.lmwarn,
      novice: game.novice,
      panic: game.panic,
      wzdark: game.wzdark,
      blooded: game.blooded,
      conds: game.conds,
      detail: game.detail,
      dflag: game.dflag,
      dkill: game.dkill,
      dtotal: game.dtotal,
      foobar: game.foobar,
      holdng: game.holdng,
      igo: game.igo,
      iwest: game.iwest,
      knfloc: game.knfloc,
      limit: game.limit,
      loc: game.loc,
      newloc: game.newloc,
      numdie: game.numdie,
      oldloc: game.oldloc,
      oldlc2: game.oldlc2,
      oldobj: game.oldobj,
      saved: game.saved,
      tally: game.tally,
      thresh: game.thresh,
      seenbigwords: game.seenbigwords,
      trnluz: game.trnluz,
      turns: game.turns,
      zzword: game.zzword,
      locs: game.locs.map((e) => LocationStateModel.fromEntity(e)).toList(),
      dwarves: game.dwarves.map((e) => DwarfModel.fromEntity(e)).toList(),
      objects: game.objects.map((e) => GameObjectModel.fromEntity(e)).toList(),
      hints: game.hints.map((e) => HintModel.fromEntity(e)).toList(),
      link: game.link,
    );
  }
}
