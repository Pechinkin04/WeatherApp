//
//  Router.swift
//  WeatherApp
//
//  Created by Александр Печинкин on 07.05.2024.
//

import UIKit

protocol RouterMain {
    
    var navigationController: UINavigationController? { get set }
    var assemblyBuilder: AsselderBuilderProtocol? { get set }
}

protocol RouterProtocol: RouterMain {
    
    func citiesTable()
    func chooseCity(city: String)
}

class Router: RouterProtocol {
    
    var navigationController: UINavigationController?
    var assemblyBuilder: AsselderBuilderProtocol?
    
    init(navigationController: UINavigationController, assemblyBuilder: AsselderBuilderProtocol) {
        self.navigationController = navigationController
        self.assemblyBuilder = assemblyBuilder
    }
    
    func initialCity() {
        if let navigationController = navigationController {
            guard let cityPickViewController = assemblyBuilder?.createCityPick(router: self) else { return }
            
            navigationController.viewControllers = [cityPickViewController]
        }
    }
    
    func citiesTable() {
        if let navigationController = navigationController {
            guard let citiesTableViewController = assemblyBuilder?.createCities(router: self) else { return }
            
            navigationController.pushViewController(citiesTableViewController, animated: true)
        }
    }
    
    func chooseCity(city: String) {
        if let navigationController = navigationController {
            guard let weatherViewController = assemblyBuilder?.createWeatherCity(city: city, router: self) else { return }
            
            navigationController.viewControllers = [weatherViewController]
        }
    }


    
}
