//
//  WeatherPresenter.swift
//  WeatherApp
//
//  Created by Александр Печинкин on 07.05.2024.
//

import Foundation

protocol WeatherViewProtocol: AnyObject {
    func successNow(city: String,temp: String, weatherList: WeatherList)
    func failure(error: Error?)
}

protocol WeatherPresenterProtocol: AnyObject {
    init(city: String, view: WeatherViewProtocol, router: RouterProtocol)
    func citiesTable()
    func loadIcn(icon: String?, completion: @escaping (Data?) -> Void)
    
}

class WeatherPresenter: WeatherPresenterProtocol {
    weak var view: WeatherViewProtocol?
    let weatherService = WeatherService()
    var router: RouterProtocol?
    let city: String

    
    required init(city: String, view: any WeatherViewProtocol, router: RouterProtocol) {
        self.city = city
        self.view = view
        self.router = router
        
        loadTemp()
    
    }
    
    private func loadTemp() {
        weatherService.load(city: city) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let weather):
                    if let weather = weather {
                        if let firstWeather = weather.list.first {
                            self?.view?.successNow(city: self!.city,temp: "\(Int(firstWeather.main.temp))º", weatherList: weather)
                        } else {
                            self?.view?.failure(error: nil)
                        }
                    } else {
                        self?.view?.failure(error: nil)
                    }
                case .failure(let error):
                    self?.view?.failure(error: error)
                }
            }
        }

    }
    
    public func loadIcn(icon: String?, completion: @escaping (Data?) -> Void) {
        if let url = URL(string: "https://openweathermap.org/img/wn/\(icon ?? "")@2x.png") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Ошибка при загрузке изображения: \(error)")
                    completion(nil)
                    return
                }
                
                guard let data = data else {
                    print("Данные изображения недоступны")
                    completion(nil)
                    return
                }
                completion(data)
            }.resume()
        } else {
            completion(nil)
        }
    }

    

    public func citiesTable() {
        router?.citiesTable()
    }
    
}
