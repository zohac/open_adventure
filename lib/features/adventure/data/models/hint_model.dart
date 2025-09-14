import '../../domain/entities/hint.dart';

class HintModel extends Hint {
  const HintModel({
    required super.used,
    required super.lc,
  });

  factory HintModel.fromJson(Map<String, dynamic> json) {
    return HintModel(
      used: json['used'],
      lc: json['lc'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'used': used,
      'lc': lc,
    };
  }

  Hint toEntity() {
    return Hint(
        used: used,
        lc: lc
    );
  }

  factory HintModel.fromEntity(Hint hint) {
    return HintModel(
        used: hint.used,
        lc: hint.lc
    );
  }
}
