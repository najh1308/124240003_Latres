class Episode {
  final int id;
  final String name;
  final String airDate;
  final String code; // contoh: S01E01

  const Episode({
    required this.id,
    required this.name,
    required this.airDate,
    required this.code,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? '-',
      airDate: (json['air_date'] as String?) ?? '-',
      code: (json['episode'] as String?) ?? '',
    );
  }
}
