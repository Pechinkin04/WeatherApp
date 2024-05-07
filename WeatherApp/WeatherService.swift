//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Александр Печинкин on 06.05.2024.
//

import Foundation

final class WeatherService {
    private let api = "b6835a1323ecb3f6151d117b34c10ac5"
    private let units = "metric"
    
    func loadNow(city: String,completion: @escaping (Result<Weather?, Error>) -> Void) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&units=\(units)&appid=\(api)") else { return }
        let urlRequest = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error {
                completion(.failure(error))
            } else if let data {
                let weather = try? JSONDecoder().decode(Weather.self, from: data)  
                
                completion(.success(weather))
            }
            
        }.resume()
    }
    
    func load(city: String,completion: @escaping (Result<WeatherList?, Error>) -> Void) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&units=\(units)&appid=\(api)") else { return }
        let urlRequest = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error {
                completion(.failure(error))
            } else if let data {
                let weather = try? JSONDecoder().decode(WeatherList.self, from: data)
                completion(.success(weather))
            }
            
        }.resume()
    }
    
    func checkCity(city: String, completion: @escaping ((Bool) -> Void)) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(api)") else {
            completion(false)
            return
        }
        
        let urlRequest = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print("Ошибка при проверке города: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                // Город существует
                completion(true)
            } else {
                // Город не найден или произошла другая ошибка
                completion(false)
            }
        }.resume()
    }

}
