/// Static cache for location and subway station coordinates in Tashkent
/// These are approximate coordinates for major locations and metro stations
class CoordinatesCache {
  /// Approximate coordinates for major districts in Tashkent
  static const Map<String, Map<String, double>> locationCoordinates = {
    "Uchtepa": {"latitude": 41.2995, "longitude": 69.2401},
    "Chilanzar": {"latitude": 41.2856, "longitude": 69.2031},
    "Yunusobod": {"latitude": 41.3667, "longitude": 69.2833},
    "Mirabad": {"latitude": 41.3167, "longitude": 69.2500},
    "Shaykhontohur": {"latitude": 41.3500, "longitude": 69.2167},
    "Sergeli": {"latitude": 41.2167, "longitude": 69.1833},
    "Bektemir": {"latitude": 41.2000, "longitude": 69.3333},
    "Yangihayot": {"latitude": 41.1833, "longitude": 69.1500},
  };

  /// Approximate coordinates for Tashkent metro stations
  static const Map<String, Map<String, double>> metroStationCoordinates = {
    // Line 1 (Chilanzar Line)
    "Chinor": {"latitude": 41.20601, "longitude": 69.21950},
    "Yangikhayot": {"latitude": 41.2126, "longitude": 69.21467},
    "Sergeli": {"latitude": 41.22065, "longitude": 69.20887},
    "Uzgarish": {"latitude": 41.22727, "longitude": 69.20404},
    "Chashtepa": {"latitude": 41.23805, "longitude": 69.19623},
    "Almazar": {"latitude": 41.255611, "longitude": 69.196014},
    "Chilanzar": {"latitude": 41.274547, "longitude": 69.204739},
    "Mirzo Ulugbek": {"latitude": 41.282081, "longitude": 69.212453},
    "Novza": {"latitude": 41.292028, "longitude": 69.223342},
    "Milliy bog": {"latitude": 41.304281, "longitude": 69.235414},
    "Xalqlar Doʻstligi": {"latitude": 41.311881, "longitude": 69.241392},
    "Paxtakor": {"latitude": 41.321264, "longitude": 69.254325},
    "Mustaqillik Maydoni": {"latitude": 41.318925, "longitude": 69.271292},
    "Amir Temur Xiyoboni": {"latitude": 41.312164, "longitude": 69.28145},
    "Hamid Olimjon": {"latitude": 41.317769, "longitude": 69.294878},
    "Pushkin": {"latitude": 41.321708, "longitude": 69.311244},
    "Buyuk Ipak Yoli": {"latitude": 41.326344, "longitude": 69.327769},

    // Line 2 (Uzbekistan Line)
    "Beruniy": {
      //41.345428°N 69.206767°E
      "latitude": 41.345428,
      "longitude": 69.206767,
    },
    "Tinchlik": {
      //41.331861°N 69.219925°E
      "latitude": 41.331861,
      "longitude": 69.219925,
    },
    "Chorsu": {
      //41.325239°N 69.232064°E
      "latitude": 41.325239,
      "longitude": 69.232064,
    },
    "Gafur Gulyam": {
      //41.327831°N 69.246981°E
      "latitude": 41.327831,
      "longitude": 69.246981,
    },
    "Alisher Navoiy": {
      //41.321125°N 69.254714°E
      "latitude": 41.321125,
      "longitude": 69.254714,
    },
    "Ozbekiston": {
      //41.311397°N 69.253408°E
      "latitude": 41.311397,
      "longitude": 69.253408,
    },
    "Kosmonavtlar": {
      //41.305022°N 69.265344°E
      "latitude": 41.305022,
      "longitude": 69.265344,
    },
    "Oybek": {
      //41.298686°N 69.273333°E
      "latitude": 41.298686,
      "longitude": 69.273333,
    },
    "Toshkent": {
      //41.292136°N 69.28615°E
      "latitude": 41.292136,
      "longitude": 69.28615,
    },
    "Mashinasozlar": {
      //41.299439°N 69.303947°E
      "latitude": 41.299439,
      "longitude": 69.303947,
    },
    "Do'stlik": {
      //41.293539°N 69.322686°E
      "latitude": 41.293539,
      "longitude": 69.322686,
    },
  };

  /// Get coordinates for a location by name
  static Map<String, double>? getLocationCoordinates(String locationName) {
    // Try exact match first
    if (locationCoordinates.containsKey(locationName)) {
      return locationCoordinates[locationName];
    }

    // Try partial match (case insensitive)
    for (final key in locationCoordinates.keys) {
      if (key.toLowerCase().contains(locationName.toLowerCase()) ||
          locationName.toLowerCase().contains(key.toLowerCase())) {
        return locationCoordinates[key];
      }
    }

    return null;
  }

  /// Get coordinates for a metro station by name
  static Map<String, double>? getMetroStationCoordinates(String stationName) {
    // Try exact match first
    if (metroStationCoordinates.containsKey(stationName)) {
      return metroStationCoordinates[stationName];
    }

    // Try partial match (case insensitive)
    for (final key in metroStationCoordinates.keys) {
      if (key.toLowerCase().contains(stationName.toLowerCase()) ||
          stationName.toLowerCase().contains(key.toLowerCase())) {
        return metroStationCoordinates[key];
      }
    }

    return null;
  }

  /// Get default Tashkent center coordinates
  static Map<String, double> getDefaultCoordinates() {
    return {"latitude": 41.2995, "longitude": 69.2401};
  }

  /// Bounding box covering greater Tashkent for default map camera when no
  /// search filters are applied.
  static Map<String, double> getCityBounds() {
    var minLat = double.infinity;
    var maxLat = -double.infinity;
    var minLon = double.infinity;
    var maxLon = -double.infinity;
    for (final coords in locationCoordinates.values) {
      final lat = coords["latitude"]!;
      final lon = coords["longitude"]!;
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lon < minLon) minLon = lon;
      if (lon > maxLon) maxLon = lon;
    }
    const padding = 0.035;
    return {
      "minLat": minLat - padding,
      "maxLat": maxLat + padding,
      "minLon": minLon - padding,
      "maxLon": maxLon + padding,
    };
  }
}
