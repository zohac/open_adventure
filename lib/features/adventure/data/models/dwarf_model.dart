import '../../domain/entities/dwarf.dart';

class DwarfModel extends Dwarf {
  const DwarfModel({
    required super.seen,
    required super.loc,
    required super.oldloc,
  });

  factory DwarfModel.fromJson(Map<String, dynamic> json) {
    return DwarfModel(
      seen: json['seen'],
      loc: json['loc'],
      oldloc: json['oldloc'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seen': seen,
      'loc': loc,
      'oldloc': oldloc,
    };
  }

  Dwarf toEntity() {
    return Dwarf(
      seen: seen,
      loc: loc,
      oldloc: oldloc,
    );
  }

  factory DwarfModel.fromEntity(Dwarf dwarf) {
    return DwarfModel(
      seen: dwarf.seen,
      loc: dwarf.loc,
      oldloc: dwarf.oldloc,
    );
  }
}
