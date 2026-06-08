// lib/models/SalonModel.dart

class Salon {
  final String id;
  final String businessName;
  final String about;
  final double rating;
  final int reviewsCount;
  final String address;
  final int capacity;
  final String city;
  final String state;
  final double latitude;
  final double longitude;
  final List<Photos> photos;
  final List<Services> services;
  final List<Bookings> bookings;
  final bool isProfileCompleted;

  Salon({
    required this.id,
    required this.businessName,
    required this.about,
    required this.rating,
    required this.reviewsCount,
    required this.address,
    required this.capacity,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.photos,
    required this.services,
    required this.bookings,
    required this.isProfileCompleted,
  });

  // SAFETY FIX: Prevents crash if service list is empty
  int get minPrice {
    if (services.isEmpty) return 0;
    try {
      double min = services.first.price;
      for (var s in services) {
        if (s.price < min) min = s.price;
      }
      return min.toInt();
    } catch (e) {
      return 0;
    }
  }

  factory Salon.fromJson(Map<String, dynamic> json) {
    // 1. Safe parsing for Lists (prevent crash if null)
    var serviceList = json["services"] as List?;
    List<Services> parsedServices = serviceList != null
        ? serviceList.map((s) => Services.fromJson(s)).toList()
        : [];

    var photoList = json["photos"] as List?;
    List<Photos> parsedPhotos = photoList != null
        ? photoList.map((p) => Photos.fromJson(p)).toList()
        : [];

    return Salon(
      // 2. USE '??' EVERYWHERE. This prevents the "Null check operator" error.
      id: json["id"]?.toString() ?? "",
      businessName: json["businessName"]?.toString() ?? "Unknown Salon",
      about: json["about"]?.toString() ?? "",

      // Handle numbers safely (API might send int or double)
      rating: (json["rating"] as num?)?.toDouble() ?? 0.0,
      reviewsCount: (json["reviewsCount"] as num?)?.toInt() ?? 0,

      address: json["address"]?.toString() ?? "",
      capacity: (json["capacity"] as num?)?.toInt() ?? 0,
      city: json["city"]?.toString() ?? "",
      state: json["state"]?.toString() ?? "",

      // Parse coordinates as DOUBLE (handle both int and double from server)
      latitude: (json["latitude"] as num?)?.toDouble() ?? 0.0,
      longitude: (json["longitude"] as num?)?.toDouble() ?? 0.0,

      photos: parsedPhotos,
      services: parsedServices,

      // Default to empty list if bookings is missing
      bookings: [],

      // Safe boolean check (defaults to false if null)
      isProfileCompleted: json["profileCompleted"] == true,
    );
  }
}

// --- PHOTOS CLASS ---
class Photos {
  final String id;
  final String url;

  Photos({required this.id, required this.url});

  factory Photos.fromJson(Map<String, dynamic> json) {
    return Photos(
      id: json["id"]?.toString() ?? "",
      url: json["url"]?.toString() ?? "",
    );
  }
}

// --- SERVICES CLASS ---
class Services {
  final String serviceName;
  final double price;

  Services({required this.serviceName, required this.price});

  factory Services.fromJson(Map<String, dynamic> json) {
    return Services(
      serviceName: json["serviceName"]?.toString() ?? "Unknown Service",
      price: (json["price"] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {"serviceName": serviceName, "price": price};
  }
}

// --- BOOKINGS CLASS ---
class Bookings {
  Bookings();
  factory Bookings.fromJson(Map<String, dynamic> json) {
    return Bookings();
  }
}
