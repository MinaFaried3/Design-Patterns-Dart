class Address {
  String? building, street, city;

  Address({this.building, this.street, this.city});

  @override
  String toString() {
    return 'Address{\nbuilding: $building,\nstreet: $street,\ncity: $city}';
  }
}
