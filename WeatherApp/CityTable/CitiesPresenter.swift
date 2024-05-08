//
//  Cities.swift
//  WeatherApp
//
//  Created by Александр Печинкин on 07.05.2024.
//

import Foundation

protocol CitiesTableViewProtocol: AnyObject {
    func success(city: String)
    func failure(alert: String)
}

protocol CitiesPresenterProtocol: AnyObject {
    init(view: CitiesTableViewProtocol, router: RouterProtocol)
    func checkCity(city: String)
    func pickCity(indexP: Int)
    func getCities() -> [String]
    func setCities(cities: [String])
}

class CitiesPresenter: CitiesPresenterProtocol {
    
    weak var view: CitiesTableViewProtocol?
    var router: RouterProtocol?
    var cities: [String] = []
    let weatherService = WeatherService()
    
    required init(view: CitiesTableViewProtocol, router: RouterProtocol) {
        self.view = view
        self.router = router
        
        cities = UserDefaults.standard.array(forKey: "SavedCities") as? [String] ?? [ "New York", "London", "Paris" ]
    }
    
    public func getCities() -> [String] {
        return cities
    }
    
    public func setCities(cities: [String]) {
        self.cities = cities
        UserDefaults.standard.set(cities, forKey: "SavedCities")
    }
    
    public func checkCity(city: String) {
        weatherService.checkCity(city: city) { [weak self] exists in
            DispatchQueue.main.async {
                if exists {
                    self?.cities.append(city)
                    UserDefaults.standard.set(self?.cities, forKey: "SavedCities")
                    self?.view?.success(city: city)
                } else {
                    self?.view?.failure(alert: "City not Found")
                }
            }
        }
        
    }
    
    public func pickCity(indexP: Int) {
        let movedCity = cities.remove(at: indexP)
        cities.insert(movedCity, at: 0)
        UserDefaults.standard.set(self.cities, forKey: "SavedCities")
        router?.chooseCity(city: cities[0])
    }
    
}
