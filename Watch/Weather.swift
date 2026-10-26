import CoreLocation
import Foundation

/// Погода с Open-Meteo (без ключа) по текущему месту; обновляем не чаще раза в 30 минут.
@MainActor
final class Weather: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var symbol: String? = UserDefaults.standard.string(forKey: "weatherSymbol")

    private let manager = CLLocationManager()
    private var lastFetch = Date.distantPast

    func refresh() {
        guard Date().timeIntervalSince(lastFetch) > 1800 else { return }
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let c = locations.last?.coordinate else { return }
        Task { @MainActor in await fetch(lat: c.latitude, lon: c.longitude) }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        manager.requestLocation()
    }

    private func fetch(lat: Double, lon: Double) async {
        let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current=weather_code,is_day")!
        struct Reply: Decodable {
            struct Current: Decodable { let weather_code: Int; let is_day: Int }
            let current: Current
        }
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let reply = try? JSONDecoder().decode(Reply.self, from: data) else { return }
        lastFetch = Date()
        let s = Self.symbol(code: reply.current.weather_code, day: reply.current.is_day == 1)
        symbol = s
        UserDefaults.standard.set(s, forKey: "weatherSymbol")
    }

    /// Коды WMO → контурные SF Symbols.
    static func symbol(code: Int, day: Bool) -> String {
        switch code {
        case 0: return day ? "sun.max" : "moon.stars"
        case 1, 2: return day ? "cloud.sun" : "cloud.moon"
        case 3: return "cloud"
        case 45, 48: return "cloud.fog"
        case 51...57: return "cloud.drizzle"
        case 61...67, 80...82: return "cloud.rain"
        case 71...77, 85, 86: return "cloud.snow"
        case 95...99: return "cloud.bolt.rain"
        default: return "cloud"
        }
    }
}
