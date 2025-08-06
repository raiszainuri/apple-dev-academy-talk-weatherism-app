//
//  WeatherView.swift
//  WeatherismApp
//
//  Created by Agustinus Pongoh on 05/08/25.
//

import SwiftUI

// MARK: - Weather View
struct WeatherView: View {
    let weather: WeatherResponse
    let viewModel: WeatherViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Location
            HStack {
                Image(systemName: "location")
                    .foregroundColor(.white)
                Text(viewModel.locationDisplayName)
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            // Weather icon and description
            VStack(spacing: 10) {
                Image(systemName: viewModel.weatherIconName(for: weather.current.weatherCode))
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                Text(viewModel.weatherDescription(for: weather.current.weatherCode))
                    .font(.title3)
                    .foregroundColor(.white)
            }
            
            // Temperature
            VStack(spacing: 5) {
                Text("\(Int(weather.current.temperature2m))°C")
                    .font(.system(size: 72, weight: .thin))
                    .foregroundColor(.white)
                
                Text("Feels like \(Int(weather.current.apparentTemperature))°C")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // ✅ Hourly forecast
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<min(weather.hourly.time.count, 12), id: \.self) { index in
                        VStack {
                            Text(viewModel.hourFromTimeString(weather.hourly.time[index]))
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Image(systemName: viewModel.weatherIconName(for: weather.current.weatherCode))
                                .foregroundColor(.white)
                            
                            Text("\(Int(weather.hourly.temperature2m[index]))°")
                                .font(.caption2)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Weather details
            HStack(spacing: 20) {
                WeatherDetailView(
                    icon: "thermometer.low",
                    title: "Min",
                    value: "\(Int(weather.daily.temperature2mMin.first ?? 0))°C"
                )
                
                WeatherDetailView(
                    icon: "thermometer.high",
                    title: "Max",
                    value: "\(Int(weather.daily.temperature2mMax.first ?? 0))°C"
                )
                
                WeatherDetailView(
                    icon: "humidity",
                    title: "Humidity",
                    value: "\(weather.current.relativeHumidity2m)%"
                )
                
                WeatherDetailView(
                    icon: "wind",
                    title: "Wind",
                    value: "\(String(format: "%.1f", weather.current.windSpeed10m)) km/h"
                )
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(15)
        }
        .padding()
    }
}

// MARK: - Weather Detail View
struct WeatherDetailView: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Preview
#Preview("Sunny Weather") {
    let sunnyWeather = WeatherResponse(
        current: CurrentWeather(
            time: "2024-01-01T12:00",
            temperature2m: 22.5,
            relativeHumidity2m: 65,
            apparentTemperature: 24.0,
            windSpeed10m: 10.5,
            windDirection10m: 180.0,
            weatherCode: 0 // Clear sky
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
    
    let sampleViewModel = WeatherViewModel()
    
    WeatherView(weather: sunnyWeather, viewModel: sampleViewModel)
        .background(WeatherCondition.clear.backgroundGradient)
}

#Preview("Rainy Weather") {
    let rainyWeather = WeatherResponse(
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
    
    let sampleViewModel = WeatherViewModel()
    
    WeatherView(weather: rainyWeather, viewModel: sampleViewModel)
        .background(WeatherCondition.rainy.backgroundGradient)
}

#Preview("Snowy Weather") {
    let snowyWeather = WeatherResponse(
        current: CurrentWeather(
            time: "2024-01-01T12:00",
            temperature2m: -2.0,
            relativeHumidity2m: 90,
            apparentTemperature: -5.0,
            windSpeed10m: 20.0,
            windDirection10m: 90.0,
            weatherCode: 71 // Snow
        ),
        daily: DailyWeather(
            time: ["2024-01-01"],
            temperature2mMax: [1.0],
            temperature2mMin: [-5.0]
        ),
        hourly: HourlyWeather(
            time: ["2024-01-01T12:00"],
            temperature2m: [-2.0]
        )
    )
    
    let sampleViewModel = WeatherViewModel()
    
    WeatherView(weather: snowyWeather, viewModel: sampleViewModel)
        .background(WeatherCondition.snowy.backgroundGradient)
}
