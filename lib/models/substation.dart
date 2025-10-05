class Substation {
  final String id;
  final String name;
  final String location;
  final List<String> coverageAreas;
  final String contactNumber;
  final String email;

  Substation({
    required this.id,
    required this.name,
    required this.location,
    required this.coverageAreas,
    required this.contactNumber,
    required this.email,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': location,
        'coverageAreas': coverageAreas,
        'contactNumber': contactNumber,
        'email': email,
      };

  factory Substation.fromJson(Map<String, dynamic> json) => Substation(
        id: json['id'],
        name: json['name'],
        location: json['location'],
        coverageAreas: List<String>.from(json['coverageAreas']),
        contactNumber: json['contactNumber'],
        email: json['email'],
      );
}