//
//  CitiesViewController.swift
//  WeatherApp
//
//  Created by Александр Печинкин on 07.05.2024.
//

import UIKit

class CitiesTableViewController: UITableViewController {
    
    var presenter: CitiesPresenterProtocol!
    lazy var addCityTextField: UITextField = {
        let textField = UITextField(frame: CGRect(x: 15, y: 0, width: view.frame.width - 30, height: 44))
        textField.placeholder = "Enter city"
        textField.borderStyle = .roundedRect
        textField.addTarget(self, action: #selector(addButtonTapped), for: .editingDidEndOnExit)
        
        return textField
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = editButtonItem
        view.backgroundColor = .black
        
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        tableView.tableHeaderView = addCityTextField
    }
    
    @objc func addButtonTapped() {
        guard var cityName = addCityTextField.text, !cityName.isEmpty else {
            return 
        }
        
        cityName = cityName.lowercased().capitalized
        
        guard !presenter.getCities().contains(cityName) else { alertError(mes: "City in list")
        return }
        
        presenter.checkCity(city: cityName)
        
        addCityTextField.text = "" // Очищаем поле для ввода
        tableView.reloadData()
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
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getCities().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 1, alpha: 0.5)
        cell.textLabel?.textColor = .white // Цвет текста
        
        let city = presenter.getCities()[indexPath.row]
        cell.textLabel?.text = city
        cell.textLabel?.font = .systemFont(ofSize: 32)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Удаляем город из массива и из UserDefaults
            var cities = presenter.getCities()
            cities.remove(at: indexPath.row)
            presenter.setCities(cities: cities)

            // Удаляем соответствующую строку из таблицы
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Разрешаем удаление ячеек только для индексов больше 0
        return indexPath.row != 0
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.pickCity(indexP: indexPath.row)
    }

}



extension CitiesTableViewController: CitiesTableViewProtocol {
    func success(city: String) {
        DispatchQueue.main.async {
//            self.cities.append(city)
//            UserDefaults.standard.set(self.cities, forKey: "SavedCities")
            self.tableView.reloadData() // Обновляем таблицу
            
        }
    }
    
    func failure(alert: String) {
        alertError(mes: alert)
    }
    
    
}
