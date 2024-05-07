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
    func pickCity(city: String)
    
}

class CitiesPresenter: CitiesPresenterProtocol {
    
    weak var view: CitiesTableViewProtocol?
    var router: RouterProtocol?
    var cities: [String] = []
    let weatherService = WeatherService()
    
    required init(view: CitiesTableViewProtocol, router: RouterProtocol) {
        self.view = view
        self.router = router
    }
    
    public func checkCity(city: String) {
        weatherService.checkCity(city: city) { [weak self] exists in
            DispatchQueue.main.async {
                if exists {
                    self?.view?.success(city: city)
                } else {
                    self?.view?.failure(alert: "City not Found")
                }
            }
        }
        
    }
    
    public func pickCity(city: String) {
        router?.chooseCity(city: city)
    }
    
}
