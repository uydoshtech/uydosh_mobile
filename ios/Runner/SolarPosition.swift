import Foundation

/// Real solar position (NOAA algorithm) for the property's location and a given instant.
///
/// Azimuth is returned in compass convention (0° = north, 90° = east, clockwise), matching
/// `SunPositionMath`. Elevation is degrees above the horizon (negative = below / night).
enum SolarPosition {
  struct Result {
    let azimuthDeg: Double
    let elevationDeg: Double
  }

  struct Daylight {
    /// Local minutes from midnight.
    let sunriseMinute: Double
    let solarNoonMinute: Double
    let sunsetMinute: Double
  }

  /// App's primary market — central Tashkent. City-level coordinates are accurate to a
  /// fraction of a degree for solar azimuth/elevation, which is more than enough here.
  static let tashkentLatitude = 41.3111
  static let tashkentLongitude = 69.2797
  static var tashkentTimeZone: TimeZone {
    TimeZone(identifier: "Asia/Tashkent") ?? TimeZone(secondsFromGMT: 5 * 3600) ?? .current
  }

  // MARK: - Public

  static func position(
    latitude: Double,
    longitude: Double,
    date: Date,
    timeZone: TimeZone
  ) -> Result {
    let jc = julianCentury(for: date)
    let solar = solarParameters(julianCentury: jc)
    let localMin = localMinutesFromMidnight(date: date, timeZone: timeZone)
    let tzHours = Double(timeZone.secondsFromGMT(for: date)) / 3600.0

    var trueSolarTime = localMin + solar.eqTimeMinutes + 4.0 * longitude - 60.0 * tzHours
    trueSolarTime = trueSolarTime.truncatingRemainder(dividingBy: 1440)
    if trueSolarTime < 0 { trueSolarTime += 1440 }

    var hourAngle = trueSolarTime / 4.0 - 180.0
    if hourAngle < -180 { hourAngle += 360 }

    let latRad = latitude * .pi / 180
    let declRad = solar.declinationDeg * .pi / 180
    let haRad = hourAngle * .pi / 180

    let cosZenith = sin(latRad) * sin(declRad) + cos(latRad) * cos(declRad) * cos(haRad)
    let zenith = acos(clamp(cosZenith, -1, 1))
    let zenithDeg = zenith * 180 / .pi
    var elevation = 90 - zenithDeg
    elevation += atmosphericRefractionDeg(elevationDeg: elevation)

    let denom = cos(latRad) * sin(zenith)
    var azimuth: Double
    if abs(denom) < 1e-9 {
      azimuth = solar.declinationDeg > latitude ? 0 : 180
    } else {
      let c = clamp((sin(latRad) * cos(zenith) - sin(declRad)) / denom, -1, 1)
      let acDeg = acos(c) * 180 / .pi
      azimuth = hourAngle > 0
        ? (acDeg + 180).truncatingRemainder(dividingBy: 360)
        : (540 - acDeg).truncatingRemainder(dividingBy: 360)
    }
    if azimuth < 0 { azimuth += 360 }

    return Result(azimuthDeg: azimuth, elevationDeg: elevation)
  }

  /// Sunrise / solar noon / sunset for the calendar day containing `date`, in local minutes.
  /// Returns `nil` for polar day/night (never relevant for Tashkent).
  static func daylight(
    latitude: Double,
    longitude: Double,
    date: Date,
    timeZone: TimeZone
  ) -> Daylight? {
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = timeZone
    guard let noon = cal.date(bySettingHour: 12, minute: 0, second: 0, of: date) else { return nil }

    let solar = solarParameters(julianCentury: julianCentury(for: noon))
    let latRad = latitude * .pi / 180
    let declRad = solar.declinationDeg * .pi / 180

    let cosHA = cos(90.833 * .pi / 180) / (cos(latRad) * cos(declRad)) - tan(latRad) * tan(declRad)
    guard cosHA >= -1, cosHA <= 1 else { return nil }
    let haDeg = acos(cosHA) * 180 / .pi

    let tzHours = Double(timeZone.secondsFromGMT(for: noon)) / 3600.0
    let solarNoon = 720 - 4 * longitude - solar.eqTimeMinutes + tzHours * 60
    return Daylight(
      sunriseMinute: solarNoon - haDeg * 4,
      solarNoonMinute: solarNoon,
      sunsetMinute: solarNoon + haDeg * 4
    )
  }

  /// Playback-speed multiplier for day-cycle animations, as a function of the sun's true
  /// elevation. Daylight plays at 1× so the interesting moments (sunrise, the shadow sweep across
  /// the floor, golden hour, sunset) are easy to follow, while the dead-of-night stretch — where
  /// nothing visibly changes — is fast-forwarded up to `maxScale`. The ramp is smoothstep-eased
  /// across twilight so there's no abrupt jump in speed at sunset/sunrise.
  ///
  /// - elevationDeg: the sun's true elevation (negative below the horizon).
  /// - maxScale: top speed reached deep in the night (≥ 1).
  /// - dayElevationDeg: at/above this elevation playback runs at full 1× (normal) speed.
  /// - nightElevationDeg: at/below this elevation playback runs at `maxScale`.
  static func nightPlaybackSpeedScale(
    elevationDeg el: Double,
    maxScale: Double = 3.0,
    dayElevationDeg: Double = 6,
    nightElevationDeg: Double = -12
  ) -> Double {
    if el >= dayElevationDeg { return 1 }
    if el <= nightElevationDeg { return maxScale }
    let t = (dayElevationDeg - el) / (dayElevationDeg - nightElevationDeg)
    let eased = t * t * (3 - 2 * t)  // smoothstep: eases the speed in/out across twilight
    return 1 + (maxScale - 1) * eased
  }

  // MARK: - NOAA core

  private struct SolarParameters {
    let declinationDeg: Double
    let eqTimeMinutes: Double
  }

  private static func solarParameters(julianCentury jc: Double) -> SolarParameters {
    let gmls = mod360(280.46646 + jc * (36000.76983 + jc * 0.0003032))
    let gmas = 357.52911 + jc * (35999.05029 - 0.0001537 * jc)
    let eccent = 0.016708634 - jc * (0.000042037 + 0.0000001267 * jc)

    let mRad = gmas * .pi / 180
    let eqCenter = sin(mRad) * (1.914602 - jc * (0.004817 + 0.000014 * jc))
      + sin(2 * mRad) * (0.019993 - 0.000101 * jc)
      + sin(3 * mRad) * 0.000289

    let trueLong = gmls + eqCenter
    let appLong = trueLong - 0.00569 - 0.00478 * sin((125.04 - 1934.136 * jc) * .pi / 180)

    let meanObliq = 23 + (26 + (21.448 - jc * (46.815 + jc * (0.00059 - jc * 0.001813))) / 60) / 60
    let obliqCorr = meanObliq + 0.00256 * cos((125.04 - 1934.136 * jc) * .pi / 180)

    let declRad = asin(sin(obliqCorr * .pi / 180) * sin(appLong * .pi / 180))
    let declinationDeg = declRad * 180 / .pi

    let y = pow(tan(obliqCorr * .pi / 180 / 2), 2)
    let gmlsRad = gmls * .pi / 180
    let eqTimeRad = y * sin(2 * gmlsRad)
      - 2 * eccent * sin(mRad)
      + 4 * eccent * y * sin(mRad) * cos(2 * gmlsRad)
      - 0.5 * y * y * sin(4 * gmlsRad)
      - 1.25 * eccent * eccent * sin(2 * mRad)
    let eqTimeMinutes = 4 * eqTimeRad * 180 / .pi

    return SolarParameters(declinationDeg: declinationDeg, eqTimeMinutes: eqTimeMinutes)
  }

  private static func julianCentury(for date: Date) -> Double {
    let jd = date.timeIntervalSince1970 / 86400.0 + 2440587.5
    return (jd - 2451545.0) / 36525.0
  }

  private static func localMinutesFromMidnight(date: Date, timeZone: TimeZone) -> Double {
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = timeZone
    let c = cal.dateComponents([.hour, .minute, .second], from: date)
    return Double(c.hour ?? 0) * 60 + Double(c.minute ?? 0) + Double(c.second ?? 0) / 60
  }

  /// NOAA atmospheric refraction correction (degrees). Negligible high in the sky.
  private static func atmosphericRefractionDeg(elevationDeg: Double) -> Double {
    if elevationDeg > 85 { return 0 }
    let te = tan(elevationDeg * .pi / 180)
    let arcSeconds: Double
    if elevationDeg > 5 {
      arcSeconds = 58.1 / te - 0.07 / pow(te, 3) + 0.000086 / pow(te, 5)
    } else if elevationDeg > -0.575 {
      arcSeconds = 1735
        + elevationDeg * (-518.2 + elevationDeg * (103.4 + elevationDeg * (-12.79 + elevationDeg * 0.711)))
    } else {
      arcSeconds = -20.774 / te
    }
    return arcSeconds / 3600.0
  }

  private static func mod360(_ value: Double) -> Double {
    var v = value.truncatingRemainder(dividingBy: 360)
    if v < 0 { v += 360 }
    return v
  }

  private static func clamp(_ value: Double, _ lower: Double, _ upper: Double) -> Double {
    min(upper, max(lower, value))
  }
}
