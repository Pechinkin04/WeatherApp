//
//  ViewController.swift
//  WeatherApp
//
//  Created by Александр Печинкин on 06.05.2024.
//

import UIKit

class CityPickViewController: UIViewController {
    
    let textField: UITextField = {
            let textField = UITextField()
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.placeholder = "Enter city"
            textField.borderStyle = .roundedRect
            return textField
        }()
        
        let button: UIButton = {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("Pick City", for: .normal)
            return button
        }()
    
    var presenter: CityPickPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(textField)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            textField.widthAnchor.constraint(equalToConstant: 300),
            textField.heightAnchor.constraint(equalToConstant: 60),
            
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 50),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
    }

    @objc private func buttonTapped() {
        let cityName = self.textField.text?.lowercased().capitalized
        presenter.checkCity(city: cityName ?? "")
    }

    private func alertError(mes: String?) {
        let message = mes == nil ? "Data is empty": mes
        let alert = UIAlertController(title: "Error",
                                      message: message,
                                      preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default)
        
        alert.addAction(alertAction)
        present(alert, animated: true)
    }

}

extension CityPickViewController: CityPickViewProtocol {
    func success(city: String) {
        UserDefaults.standard.set([city], forKey: "SavedCities")
        presenter.pickCity(city: city)
    }
    
    func failure(alert: String) {
        alertError(mes: alert)
    }
    
    
}
