class Folder {
  final int? id;
  final String name;
  final int? parentId;

  const Folder({
    this.id,
    required this.name,
    this.parentId,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (parentId != null) 'parent_id': parentId,
    };
  }

  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'] as int?,
      name: map['name'] as String,
      parentId: map['parent_id'] as int?,
    );
  }

  Folder copyWith({
    int? id,
    String? name,
    int? parentId,
    bool clearParentId = false,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: clearParentId ? null : (parentId ?? this.parentId),
    );
  }
}
