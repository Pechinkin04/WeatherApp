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
    
    func getWeatherList() -> WeatherList
    func getFilteredWeatherList() -> [Weather]
    func getDayWeatherList() -> [(date: Date, temperature: Double, weatherDet: WeatherDetail)]
    func formatForCollectionView(dat: String) -> String
}

class WeatherPresenter: WeatherPresenterProtocol {
    
    weak var view: WeatherViewProtocol?
    let weatherService = WeatherService()
    var router: RouterProtocol?
    
    let city: String
    var weatherList = WeatherList(list: [])
    var filteredWeatherList = [Weather]()
    let currentDate = Date()
    var dateFormatter = DateFormatter()
    var dayWeatherList: [(date: Date, temperature: Double, weatherDet: WeatherDetail)] = []

    
    required init(city: String, view: any WeatherViewProtocol, router: RouterProtocol) {
        self.city = city
        self.view = view
        self.router = router
        
        loadTemp()
    
    }
    
    public func getWeatherList() -> WeatherList {
        return weatherList
    }
    
    public func getFilteredWeatherList() -> [Weather] {
        return filteredWeatherList
    }
    
    public func getDayWeatherList() -> [(date: Date, temperature: Double, weatherDet: WeatherDetail)] {
        return dayWeatherList
    }
    
    public func formatForCollectionView(dat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        if let date = dateFormatter.date(from: dat) {
            // Устанавливаем формат даты и времени
            dateFormatter.dateFormat = "dd.MM \n HH:mm"
            let formattedDate = dateFormatter.string(from: date)
            return formattedDate
        } else {
            return dat
        }
    }
    
    private func loadTemp() {
        weatherService.load(city: city) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let weather):
                    
                    guard let weather = weather,let firstWeather = weather.list.first else {  self?.view?.failure(error: nil)
                        return
                    }
                    
                    self?.weatherList = weather // Сохранение прогноза погоды
                    
                    
                    let calendar = Calendar.current
                    let dateFormater = DateFormatter()
                    dateFormater.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    if let nextDay = calendar.date(byAdding: .hour, value: 24, to: self!.currentDate) {
                        // Отфильтруем массив данных о погоде, оставив только данные за следующие 24 часа
                        self!.filteredWeatherList = self!.weatherList.list.filter {
                            let datFormat = dateFormater.date(from: $0.dt_txt)
                            return datFormat! < nextDay }
                    }
                    
                    // Проходимся по всем элементам в списке погоды и формируем список дневных данных о погоде
                    for weath in weather.list {
                        // Проверяем, является ли время в 15:00
                        if let weatherDate = dateFormater.date(from: weath.dt_txt),
                           Calendar.current.component(.hour, from: weatherDate) == 15 {
                            // Если это время в 15:00, добавляем данные в наш список дневной погоды
                            self!.dayWeatherList.append((date: weatherDate, temperature: weath.main.temp, weatherDet: weath.weather.first!))
                        }
                    }
                    
                    self?.view?.successNow(city: self?.city ?? "-", temp: "\(Int(firstWeather.main.temp))º", weatherList: weather)
                    
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
