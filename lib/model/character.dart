class Character {
  final int id;
  final String name;
  final String status; // Alive / Dead / unknown
  final String species;
  final String gender;
  final String origin;
  final String location;
  final String image;

  const Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.gender,
    required this.origin,
    required this.location,
    required this.image,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? '-',
      status: (json['status'] as String?) ?? 'unknown',
      species: (json['species'] as String?) ?? '-',
      gender: (json['gender'] as String?) ?? '-',
      origin: ((json['origin'] as Map?)?['name'] as String?) ?? '-',
      location: ((json['location'] as Map?)?['name'] as String?) ?? '-',
      image: (json['image'] as String?) ?? '',
    );
  }

  // Bentuknya sengaja dibuat sama dengan response API,
  // sehingga fromJson() bisa dipakai lagi untuk membaca data favorit.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'status': status,
        'species': species,
        'gender': gender,
        'origin': {'name': origin},
        'location': {'name': location},
        'image': image,
      };
}
