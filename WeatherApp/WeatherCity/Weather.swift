//
//  Weather.swift
//  WeatherApp
//
//  Created by Александр Печинкин on 07.05.2024.
//

import Foundation

struct WeatherList: Codable {
    let list: [Weather]
}

struct Weather: Codable {
    
    let main: Main
    let weather: [WeatherDetail]
    let dt_txt: String
}

struct Main: Codable {
    let temp: Double
}

struct WeatherDetail: Codable {
    let main: String
    let icon: String
}
