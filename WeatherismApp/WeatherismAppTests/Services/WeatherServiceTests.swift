//
//  WeatherServiceTests.swift
//  WeatherismAppTests
//
//  Created by Agustinus Pongoh on 05/08/25.
//

import XCTest
@testable import WeatherismApp

final class WeatherServiceTests: XCTestCase {
    
    // MARK: - Properties
    var weatherService: WeatherService!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        weatherService = WeatherService()
    }
    
    override func tearDown() {
        weatherService = nil
        super.tearDown()
    }
    
    // MARK: - Integration Tests
    // Note: These are integration tests that make real API calls
    // In a production app, you might want to mock URLSession or use a test environment
    
    func testFetchWeatherForValidCity() async {
        // Given
        let city = "London"
        
        do {
            // When
            let (weather, location) = try await weatherService.fetchWeather(for: city)
            
            // Then
            XCTAssertEqual(location.name, "London")
            XCTAssertEqual(location.country, "United Kingdom")
            XCTAssertGreaterThan(location.latitude, 50.0)
            XCTAssertLessThan(location.latitude, 52.0)
            XCTAssertLessThan(location.longitude, 0.0)
            XCTAssertGreaterThan(location.longitude, -1.0)
            
            // Verify weather data structure
            XCTAssertNotNil(weather.current)
            XCTAssertNotNil(weather.daily)
            XCTAssertNotNil(weather.hourly)
            
            // Verify current weather has reasonable values
            XCTAssertGreaterThan(weather.current.temperature2m, -50.0)
            XCTAssertLessThan(weather.current.temperature2m, 60.0)
            XCTAssertGreaterThanOrEqual(weather.current.relativeHumidity2m, 0)
            XCTAssertLessThanOrEqual(weather.current.relativeHumidity2m, 100)
            XCTAssertGreaterThanOrEqual(weather.current.windSpeed10m, 0.0)
            XCTAssertGreaterThanOrEqual(weather.current.weatherCode, 0)
            
            // Verify daily forecast
            XCTAssertFalse(weather.daily.time.isEmpty)
            XCTAssertFalse(weather.daily.temperature2mMax.isEmpty)
            XCTAssertFalse(weather.daily.temperature2mMin.isEmpty)
            XCTAssertEqual(weather.daily.time.count, weather.daily.temperature2mMax.count)
            XCTAssertEqual(weather.daily.time.count, weather.daily.temperature2mMin.count)
            
        } catch {
            XCTFail("Expected successful weather fetch, but got error: \(error)")
        }
    }
    
    func testFetchWeatherForInvalidCity() async {
        // Given
        let invalidCity = "ThisCityDoesNotExistXYZ123"
        
        do {
            // When
            _ = try await weatherService.fetchWeather(for: invalidCity)
            XCTFail("Expected error for invalid city, but got success")
        } catch {
            // Then
            if let networkError = error as? NetworkError {
                XCTAssertEqual(networkError, NetworkError.cityNotFound)
            } else {
                XCTFail("Expected NetworkError.cityNotFound, but got: \(error)")
            }
        }
    }
    
    func testFetchWeatherForMultipleCities() async {
        // Given
        let cities = ["Paris", "Tokyo", "New York"]
        
        for city in cities {
            do {
                // When
                let (weather, location) = try await weatherService.fetchWeather(for: city)
                
                // Then
                XCTAssertTrue(location.name.contains(city) || 
                            location.name.localizedCaseInsensitiveContains(city))
                XCTAssertNotNil(weather.current)
                XCTAssertFalse(weather.daily.time.isEmpty)
                
                // Basic sanity checks for weather data
                XCTAssertGreaterThan(weather.current.temperature2m, -100.0)
                XCTAssertLessThan(weather.current.temperature2m, 100.0)
                
            } catch {
                XCTFail("Failed to fetch weather for \(city): \(error)")
            }
        }
    }
    
    func testFetchWeatherWithSpecialCharacters() async {
        // Given
        let cityWithSpecialChars = "São Paulo"
        
        do {
            // When
            let (weather, location) = try await weatherService.fetchWeather(for: cityWithSpecialChars)
            
            // Then
            XCTAssertTrue(location.name.contains("São Paulo") || 
                        location.name.contains("Sao Paulo"))
            XCTAssertNotNil(weather.current)
            
        } catch {
            XCTFail("Expected successful weather fetch for city with special characters, but got error: \(error)")
        }
    }
    
    // MARK: - Error Handling Tests
    func testNetworkErrorTypes() {
        // Test NetworkError descriptions
        XCTAssertEqual(NetworkError.invalidURL.errorDescription, "Invalid URL")
        XCTAssertEqual(NetworkError.noData.errorDescription, "No data received")
        XCTAssertEqual(NetworkError.cityNotFound.errorDescription, "City not found. Please check the spelling and try again.")
    }
    
    // MARK: - Performance Tests
    func testWeatherFetchPerformance() {
        // This test measures the time it takes to fetch weather data
        measure {
            let expectation = self.expectation(description: "Weather fetch performance")
            
            Task {
                do {
                    _ = try await weatherService.fetchWeather(for: "London")
                    expectation.fulfill()
                } catch {
                    expectation.fulfill()
                }
            }
            
            waitForExpectations(timeout: 10.0)
        }
    }
    
    // MARK: - Data Validation Tests
    func testWeatherDataValidation() async {
        // Given
        let city = "Berlin"
        
        do {
            // When
            let (weather, location) = try await weatherService.fetchWeather(for: city)
            
            // Then - Validate all required fields are present
            XCTAssertFalse(weather.current.time.isEmpty)
            XCTAssertNotNil(weather.current.temperature2m)
            XCTAssertNotNil(weather.current.relativeHumidity2m)
            XCTAssertNotNil(weather.current.apparentTemperature)
            XCTAssertNotNil(weather.current.windSpeed10m)
            XCTAssertNotNil(weather.current.windDirection10m)
            XCTAssertNotNil(weather.current.weatherCode)
            
            // Validate location fields
            XCTAssertFalse(location.name.isEmpty)
            XCTAssertFalse(location.country.isEmpty)
            XCTAssertFalse(location.countryCode.isEmpty)
            XCTAssertNotEqual(location.latitude, 0.0)
            XCTAssertNotEqual(location.longitude, 0.0)
            
            // Validate daily data
            XCTAssertGreaterThan(weather.daily.time.count, 0)
            XCTAssertGreaterThan(weather.daily.temperature2mMax.count, 0)
            XCTAssertGreaterThan(weather.daily.temperature2mMin.count, 0)
            
            // Validate hourly data
            XCTAssertGreaterThan(weather.hourly.time.count, 0)
            XCTAssertGreaterThan(weather.hourly.temperature2m.count, 0)
            
        } catch {
            XCTFail("Data validation test failed: \(error)")
        }
    }
    
    // MARK: - Concurrent Requests Test
    func testConcurrentWeatherRequests() async {
        // Given
        let cities = ["London", "Paris", "Berlin", "Madrid", "Rome"]
        
        // When - Make concurrent requests
        await withTaskGroup(of: Void.self) { group in
            for city in cities {
                group.addTask {
                    do {
                        let (weather, location) = try await self.weatherService.fetchWeather(for: city)
                        XCTAssertNotNil(weather.current)
                        XCTAssertFalse(location.name.isEmpty)
                    } catch {
                        XCTFail("Concurrent request failed for \(city): \(error)")
                    }
                }
            }
        }
    }
}