class HostelUnit {
  const HostelUnit({required this.id, required this.name, required this.bedsAvailable, required this.price, required this.gender});
  final int id; final String name; final int bedsAvailable; final int price; final String gender;
  factory HostelUnit.fromJson(Map<String, dynamic> json) => HostelUnit(id: (json['id'] as num).toInt(), name: json['name'] as String? ?? '', bedsAvailable: (json['beds_available'] as num?)?.toInt() ?? 0, price: (json['price'] as num?)?.toInt() ?? 0, gender: json['gender'] as String? ?? 'mixed');
}
class Hostel {
  const Hostel({required this.id, required this.name, required this.genderPolicy, this.address, this.latitude, this.longitude, this.photos = const [], this.units = const []});
  final int id; final String name; final String genderPolicy; final String? address; final double? latitude; final double? longitude; final List<String> photos; final List<HostelUnit> units;
  int? get minimumPrice => units.isEmpty ? null : units.map((u) => u.price).reduce((a,b) => a < b ? a : b);
  int get bedsAvailable => units.fold(0, (sum, unit) => sum + unit.bedsAvailable);
  factory Hostel.fromJson(Map<String, dynamic> json) { final photos = (json['photos'] as List? ?? []).map((p) => (p as Map)['photo_url'] as String?).whereType<String>().toList(); return Hostel(id:(json['id'] as num).toInt(),name:json['name'] as String? ?? '',genderPolicy:json['gender_policy'] as String? ?? 'mixed',address:json['address'] as String?,latitude:(json['latitude'] as num?)?.toDouble(),longitude:(json['longitude'] as num?)?.toDouble(),photos:photos,units:(json['units'] as List? ?? []).map((u)=>HostelUnit.fromJson(Map<String,dynamic>.from(u as Map))).toList()); }
}
