

import Foundation

// MARK: - WeatherResponse
struct WeatherResponse : Codable {
    let lat, lon: Double
    let timezone: String
    let current: Current
    let hourly: [Current]
    let daily: [Daily]
}

// MARK: - Current
struct Current : Codable{
    let dt: Int
    let sunrise, sunset: Int?
    let temp, feels_like: Double
    let pressure, humidity: Int
    let wind_speed: Double
    let weather: [Weather]
    
}

// MARK: - Weather
struct Weather : Codable{
    let id: Int
    let main: String
    let description: String
    let icon: String
}


// MARK: - Daily
struct Daily: Codable {
    let dt, sunrise, sunset: Int
    let temp: Temp
    let feels_like: FeelsLike
    let pressure, humidity: Int
    let wind_speed: Double
    let weather: [Weather]

}

// MARK: - FeelsLike
struct FeelsLike : Codable{
    let day, night, eve, morn: Double
}

// MARK: - Temp
struct Temp: Codable {
    let day, min, max, night: Double
    let eve, morn: Double
}

