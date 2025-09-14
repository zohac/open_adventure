/// ActionModel represents an action definition from assets/data/actions.json.
class ActionModel {
  /// Canonical action key (e.g., 'CARRY', 'DROP').
  final String name;

  /// Optional default message associated with the action; can be a literal or a key.
  final String? message;

  /// Optional list of word aliases mapped to this action.
  final List<String>? words;

  /// Whether legacy/old-style parsing applies (present for some actions).
  final bool oldstyle;

  const ActionModel({
    required this.name,
    this.message,
    this.words,
    this.oldstyle = false,
  });

  /// Constructs from flattened map: { 'name': String, 'message'?: String, 'words'?: [String], 'oldstyle'?: bool }.
  factory ActionModel.fromJson(Map<String, dynamic> json) {
    final words = (json['words'] as List?)?.cast<String>();
    final msg = json['message'] as String?;
    final oldstyle = (json['oldstyle'] as bool?) ?? false;
    return ActionModel(
      name: (json['name'] ?? 'UNKNOWN') as String,
      message: (msg != null && msg.isEmpty) ? null : msg,
      words: (words != null && words.isEmpty) ? null : words,
      oldstyle: oldstyle,
    );
  }

  /// Constructs from entry [name, data] in the source JSON list.
  factory ActionModel.fromEntry(List<dynamic> entry) {
    final name = entry.first as String;
    final data = Map<String, dynamic>.from(entry.last as Map);
    return ActionModel.fromJson(<String, dynamic>{'name': name, ...data});
  }
}

