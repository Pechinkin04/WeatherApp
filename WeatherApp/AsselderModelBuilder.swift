//
//  AsselderModelBuilder.swift
//  WeatherApp
//
//  Created by Александр Печинкин on 07.05.2024.
//

import UIKit

protocol AsselderBuilderProtocol {
    func createWeatherCity(city: String, router: RouterProtocol) -> UIViewController
    func createCities(router: RouterProtocol) -> UIViewController
    func createCityPick(router: RouterProtocol) -> UIViewController
}

class AsselderModelBuilder: AsselderBuilderProtocol {
    
    func createWeatherCity(city: String, router: RouterProtocol) -> UIViewController {
        let view = WeatherViewController()
        let presenter = WeatherPresenter(city: city, view: view, router: router)
        
        view.presenter = presenter
        
        return view
    }
    
    func createCities(router: RouterProtocol) -> UIViewController {
        let view = CitiesTableViewController()
        let presenter = CitiesPresenter(view: view, router: router)
        
        view.presenter = presenter
        
        return view
    }
    
    func createCityPick(router: RouterProtocol) -> UIViewController {
        let view = CityPickViewController()
        let presenter = CityPickPresenter(view: view, router: router)
        
        view.presenter = presenter
        
        return view
    }
    
}
