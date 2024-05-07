//
//  CityPickPresenter.swift
//  WeatherApp
//
//  Created by Александр Печинкин on 07.05.2024.
//

import Foundation

protocol CityPickViewProtocol: AnyObject {
    func success(city: String)
    func failure(alert: String)
}

protocol CityPickPresenterProtocol: AnyObject {
    init(view: CityPickViewProtocol, router: RouterProtocol)
    func pickCity(city: String)
    func checkCity(city: String)
}

class CityPickPresenter: CityPickPresenterProtocol {
    
    weak var view: CityPickViewProtocol?
    var router: RouterProtocol?
    let weatherService = WeatherService()
    
    required init(view: CityPickViewProtocol, router: RouterProtocol) {
        self.view = view
        self.router = router
    }
    
    public func pickCity(city: String) {
        router?.chooseCity(city: city)
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
    
}
