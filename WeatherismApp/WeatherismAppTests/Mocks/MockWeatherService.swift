//
//  MockWeatherService.swift
//  WeatherismAppTests
//
//  Created by Agustinus Pongoh on 05/08/25.
//

import Foundation
@testable import WeatherismApp

// MARK: - Mock Weather Service
class MockWeatherService: WeatherServiceProtocol {
    // MARK: - Properties
    var shouldThrowError = false
    var errorToThrow: Error = NetworkError.cityNotFound
    var mockWeatherResponse: WeatherResponse?
    var mockGeocodingResult: GeocodingResult?
    var fetchWeatherCallCount = 0
    var lastSearchedCity: String?
    
    // MARK: - Mock Implementation
    func fetchWeather(for city: String) async throws -> (WeatherResponse, GeocodingResult) {
        fetchWeatherCallCount += 1
        lastSearchedCity = city
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        guard let weather = mockWeatherResponse,
              let location = mockGeocodingResult else {
            throw NetworkError.noData
        }
        
        return (weather, location)
    }
    
    // MARK: - Helper Methods
    func reset() {
        shouldThrowError = false
        errorToThrow = NetworkError.cityNotFound
        mockWeatherResponse = nil
        mockGeocodingResult = nil
        fetchWeatherCallCount = 0
        lastSearchedCity = nil
    }
    
    func setupSuccessResponse() {
        mockWeatherResponse = TestDataFactory.createMockWeatherResponse()
        mockGeocodingResult = TestDataFactory.createMockGeocodingResult()
    }
}

// MARK: - Test Data Factory
struct TestDataFactory {
    static func createMockWeatherResponse() -> WeatherResponse {
        return WeatherResponse(
            current: CurrentWeather(
                time: "2024-01-01T12:00",
                temperature2m: 22.5,
                relativeHumidity2m: 65,
                apparentTemperature: 24.0,
                windSpeed10m: 10.5,
                windDirection10m: 180.0,
                weatherCode: 0
            ),
            daily: DailyWeather(
                time: ["2024-01-01"],
                temperature2mMax: [25.0],
                temperature2mMin: [18.0]
            ),
            hourly: HourlyWeather(
                time: ["2024-01-01T12:00"],
                temperature2m: [22.5]
            )
        )
    }
    
    static func createMockGeocodingResult() -> GeocodingResult {
        return GeocodingResult(
            name: "London",
            latitude: 51.5074,
            longitude: -0.1278,
            country: "United Kingdom",
            countryCode: "GB"
        )
    }
    
    static func createRainyWeatherResponse() -> WeatherResponse {
        return WeatherResponse(
            current: CurrentWeather(
                time: "2024-01-01T12:00",
                temperature2m: 15.0,
                relativeHumidity2m: 85,
                apparentTemperature: 13.0,
                windSpeed10m: 15.0,
                windDirection10m: 270.0,
                weatherCode: 61 // Rain
            ),
            daily: DailyWeather(
                time: ["2024-01-01"],
                temperature2mMax: [18.0],
                temperature2mMin: [12.0]
            ),
            hourly: HourlyWeather(
                time: ["2024-01-01T12:00"],
                temperature2m: [15.0]
            )
        )
    }
}