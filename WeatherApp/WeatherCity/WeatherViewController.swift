//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Александр Печинкин on 06.05.2024.
//

import UIKit

class WeatherViewController: UIViewController {
    
    private lazy var cityLabel: UILabel = {
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "-"
        label.font = .boldSystemFont(ofSize: 28)
        
        return label
    }()
    
    private lazy var tempLabel: UILabel = {
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 60)
        label.text = "-"
        
        return label
    }()
    
    private lazy var iconNowImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        
        return image
    }()
    
    private lazy var descLabel: UILabel = {
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24)
        label.text = "-"
        
        return label
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(WeatherCell.self, forCellWithReuseIdentifier: "WeatherCell")
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = view.backgroundColor
        tableView.separatorStyle = .none
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DayWeatherCell")
        
        return tableView
    }()
    
    var presenter: WeatherPresenterProtocol!
    let dateFormatter = DateFormatter()
    var weatherList = WeatherList(list: [])
    var filteredWeatherList = [Weather]()
    var dayWeatherList: [(date: Date, temperature: Double, weatherDet: WeatherDetail)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemMint
        view.addSubview(cityLabel)
        view.addSubview(iconNowImage)
        view.addSubview(tempLabel)
        view.addSubview(descLabel)
        view.addSubview(collectionView)
        view.addSubview(tableView)
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        setupNavigationController()
        
        setConstraints()
        
        
        
    }
    
    
    private func setupNavigationController() {
        navigationItem.title = "Погода"
        let buttonR = UIBarButtonItem(barButtonSystemItem: .add,
                                      target: self,
                                      action: #selector(cityTable))
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = buttonR
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
    }
    
    @objc private func cityTable() {
        presenter.citiesTable()
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            cityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cityLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            
            iconNowImage.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 30),
            iconNowImage.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 5),
            
            tempLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tempLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 35),
            
            descLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descLabel.topAnchor.constraint(equalTo: tempLabel.bottomAnchor, constant: 5),
            
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 30),
            collectionView.bottomAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 200),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    
    
    private func alertError(error: Error?) {
        let message = error == nil ? "Data is empty": error?.localizedDescription
        let alert = UIAlertController(title: "Error",
                                      message: message,
                                      preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default)
        
        alert.addAction(alertAction)
        present(alert, animated: true)
    }
    
    private func loadIcn(icon: String, completion: @escaping (UIImage?) -> Void) {
        presenter.loadIcn(icon: icon) { [weak self] imageData in
            guard let imageData = imageData else {
                // Обработка ошибки загрузки изображения
                print("Ошибка загрузки изображения")
                self?.alertError(error: nil)
                completion(nil)
                return
            }
                        
            // Создание объекта UIImage из данных изображения
            if let image = UIImage(data: imageData) {
                // Обновление UI с использованием изображения
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }

    

}

extension WeatherViewController: WeatherViewProtocol {
    func successNow(city: String, temp: String, weatherList: WeatherList) {
        self.cityLabel.text = city
        self.tempLabel.text = temp
        self.weatherList = weatherList
//        print(weatherList)
//        loadIcn(icon: weatherList.list.first?.weather.first?.icon ?? "")
        loadIcn(icon: weatherList.list.first?.weather.first?.icon ?? "") { [weak self] image in
            if let image = image {
                DispatchQueue.main.async {
                    self?.iconNowImage.image = image
                }
            }
        }
        self.descLabel.text = weatherList.list.first?.weather.first?.main
        
//        for tem in weatherList.list {
//            print(tem.dt_txt, tem.main.temp)
//        }
        
        DispatchQueue.main.async {
            // Определяем текущее время
            let currentDate = Date()

            // Формируем дату, которая наступит через 24 часа от текущего времени
            let calendar = Calendar.current
            if let nextDay = calendar.date(byAdding: .hour, value: 24, to: currentDate) {
                // Отфильтруем массив данных о погоде, оставив только данные за следующие 24 часа
                self.filteredWeatherList = weatherList.list.filter { self.dateFormatter.date(from: $0.dt_txt) ?? Date() < nextDay }
                self.collectionView.reloadData()
            }

        }
        
        
                
        // Проходимся по всем элементам в списке погоды и формируем список дневных данных о погоде
        for weather in weatherList.list {
            // Проверяем, является ли время в 15:00
            if let weatherDate = dateFormatter.date(from: weather.dt_txt),
               Calendar.current.component(.hour, from: weatherDate) == 15 {
                // Если это время в 15:00, добавляем данные в наш список дневной погоды
                dayWeatherList.append((date: weatherDate, temperature: weather.main.temp, weatherDet: weather.weather.first!))
            }
        }
        tableView.reloadData()
    }
    
    func failure(error: (any Error)?) {
        alertError(error: error)
    }
    
    
}


extension WeatherViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        // MARK: - UICollectionViewDataSource
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return filteredWeatherList.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherCell", for: indexPath) as! WeatherCell
            
//            let weather = weatherData[indexPath.item]
//            cell.textLabel.text = "\(weather.temperature)°"
//            cell.imageView.image = weather.icon
//            
            
            let weather = filteredWeatherList[indexPath.item]
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

            if let date = dateFormatter.date(from: weather.dt_txt) {
                // Устанавливаем формат даты и времени
                dateFormatter.dateFormat = "dd.MM \n HH:mm"
                let formattedDate = dateFormatter.string(from: date)
                cell.timeLabel.text = formattedDate
            } else {
                cell.timeLabel.text = weather.dt_txt // В случае ошибки парсинга оставляем оригинальный текст
            }

            loadIcn(icon: weather.weather[0].icon) { image in
                if let image = image {
                    DispatchQueue.main.async {
                        cell.weatherImageView.image = image
                    }
                }
            }
            cell.temperatureLabel.text = "\(Int(weather.main.temp))°"
            
            
            return cell
        }
        
        // MARK: - UICollectionViewDelegateFlowLayout
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            // Установите размеры ячейки в вашем collectionView
            return CGSize(width: 90, height: 150)
        }
}


extension WeatherViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dayWeatherList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayWeatherCell", for: indexPath)
        cell.backgroundColor = view.backgroundColor
        
        
        // Получаем данные о погоде для текущего дня
        let dayWeather = dayWeatherList[indexPath.row]
        
        // Настраиваем ячейку с данными о погоде
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM"
        
        let dateTempOut = dateFormatter.string(from: dayWeather.date) + " \t\t" +  "\(Int(dayWeather.temperature))°C" + "\t\t" + dayWeather.weatherDet.main
        cell.textLabel?.text = dateTempOut
        cell.textLabel?.font = UIFont.systemFont(ofSize: 24)
        
        loadIcn(icon: dayWeather.weatherDet.icon) { image in
            if let image = image {
                DispatchQueue.main.async {
                    let imageView = UIImageView(image: image)
                    imageView.contentMode = .scaleAspectFit // Устанавливаем режим масштабирования изображения
                    imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50) // Устанавливаем размеры изображения
                    cell.accessoryView = imageView
                }
            }
        }
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Снимаем выделение с ячейки
        tableView.deselectRow(at: indexPath, animated: true)
        
    }

}
