class Squad {
  final int id;
  final String squadName;
  final String squadDescription;
  final int squadCapacity;
  final int squadRange;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isExpired;
  // final List<Route> routes;
  // final List<UserSquad> userSquads;

  Squad({
    required this.id,
    required this.squadName,
    required this.squadDescription,
    required this.squadCapacity,
    required this.squadRange,
    required this.createdAt,
    required this.updatedAt,
    required this.isExpired,
    // required this.routes,
    // required this.userSquads,
  });

  factory Squad.fromJson(Map<String, dynamic> json) {
    return Squad(
      id: json['id'],
      squadName: json['squadName'],
      squadDescription: json['squadDescription'],
      squadCapacity: json['squadCapacity'],
      squadRange: json['squadRange'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isExpired: json['isExpired'],
      // routes: (json['routes'] as List<dynamic>)
      //     .map((route) => Route.fromJson(route))
      //     .toList(),
      // userSquads: (json['userSquads'] as List<dynamic>)
      //     .map((userSquad) => UserSquad.fromJson(userSquad))
      //     .toList(),
    );
  }

  factory Squad.fromMap(Map<String, dynamic> map) {
    return Squad(
      id: map['id'],
      squadName: map['squadName'],
      squadDescription: map['squadDescription'],
      squadCapacity: map['squadCapacity'],
      squadRange: map['squadRange'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      isExpired: map['isExpired'],
      // routes: (map['routes'] as List<dynamic>)
      //     .map((route) => Route.fromMap(route))
      //     .toList(),
      // userSquads: (map['userSquads'] as List<dynamic>)
      //     .map((userSquad) => UserSquad.fromMap(userSquad))
      //     .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'squadName': squadName,
      'squadDescription': squadDescription,
      'squadCapacity': squadCapacity,
      'squadRange': squadRange,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isExpired': isExpired,
    };
  }
}

// class Route {
//   // Define the fields and methods for the Route class
//   final int id;
//   final String routeName;
//   final double startLatitude;
//   final double startLongitude;
//   final double endLatitude;
//   final double endLongitude;

//   Route({
//     required this.id,
//     required this.routeName,
//     required this.startLatitude,
//     required this.startLongitude,
//     required this.endLatitude,
//     required this.endLongitude,
//   });

//   factory Route.fromJson(Map<String, dynamic> json) {
//     return Route(
//       id: json['id'],
//       routeName: json['routeName'],
//       startLatitude: json['startLatitude'],
//       startLongitude: json['startLongitude'],
//       endLatitude: json['endLatitude'],
//       endLongitude: json['endLongitude'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'routeName': routeName,
//       'startLatitude': startLatitude,
//       'startLongitude': startLongitude,
//       'endLatitude': endLatitude,
//       'endLongitude': endLongitude,
//     };
//   }
// }

// class UserSquad {
//   // Define the fields and methods for the UserSquad class
//   final int id;
//   final int userId;
//   final int squadId;

//   UserSquad({
//     required this.id,
//     required this.userId,
//     required this.squadId,
//   });

//   factory UserSquad.fromJson(Map<String, dynamic> json) {
//     return UserSquad(
//       id: json['id'],
//       userId: json['userId'],
//       squadId: json['squadId'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'userId': userId,
//       'squadId': squadId,
//     };
//   }
// }
