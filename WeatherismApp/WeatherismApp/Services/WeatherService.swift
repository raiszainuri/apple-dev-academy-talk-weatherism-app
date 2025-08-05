//
//  WeatherService.swift
//  WeatherismApp
//
//  Created by Agustinus Pongoh on 05/08/25.
//

import Foundation

// MARK: - Weather Service Protocol
protocol WeatherServiceProtocol {
    func fetchWeather(for city: String) async throws -> (WeatherResponse, GeocodingResult)
}

// MARK: - Weather Service Implementation
class WeatherService: WeatherServiceProtocol {
    private let weatherBaseURL = "https://api.open-meteo.com/v1/forecast"
    private let geocodingBaseURL = "https://geocoding-api.open-meteo.com/v1/search"
    
    func fetchWeather(for city: String) async throws -> (WeatherResponse, GeocodingResult) {
        // First, get coordinates for the city
        let location = try await geocodeCity(city)
        let weather = try await fetchWeatherData(latitude: location.latitude, longitude: location.longitude)
        return (weather, location)
    }
    
    private func geocodeCity(_ city: String) async throws -> GeocodingResult {
        let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let urlString = "\(geocodingBaseURL)?name=\(encodedCity)&count=1&language=en&format=json"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let geocodingResponse = try JSONDecoder().decode(GeocodingResponse.self, from: data)
        
        guard let location = geocodingResponse.results?.first else {
            throw NetworkError.cityNotFound
        }
        
        return location
    }
    
    private func fetchWeatherData(latitude: Double, longitude: Double) async throws -> WeatherResponse {
        let urlString = "\(weatherBaseURL)?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,relative_humidity_2m,apparent_temperature,wind_speed_10m,wind_direction_10m,weather_code&daily=temperature_2m_max,temperature_2m_min&hourly=temperature_2m&timezone=auto"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
        return weatherResponse
    }
}