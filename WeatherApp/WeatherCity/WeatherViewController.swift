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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemMint
        view.addSubview(cityLabel)
        view.addSubview(iconNowImage)
        view.addSubview(tempLabel)
        view.addSubview(descLabel)
        view.addSubview(collectionView)
        view.addSubview(tableView)
        
        setupNavigationController()
        
        setConstraints()
        
        
        
    }
    
    
    private func setupNavigationController() {
        navigationItem.title = "Weather"
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
                print("Ошибка загрузки изображения")
                self?.alertError(error: nil)
                completion(nil)
                return
            }
                        
            if let image = UIImage(data: imageData) {
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
        let weatherList = weatherList
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
            self.collectionView.reloadData()
            self.tableView.reloadData()

        }
    }
    
    func failure(error: (any Error)?) {
        alertError(error: error)
    }
    
    
}


extension WeatherViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        // MARK: - UICollectionViewDataSource
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return presenter.getFilteredWeatherList().count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherCell", for: indexPath) as! WeatherCell
            
            let weather = presenter.getFilteredWeatherList()[indexPath.item]
            
            cell.timeLabel.text = presenter.formatForCollectionView(dat: weather.dt_txt)
            
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
            return CGSize(width: 90, height: 150)
        }
}


extension WeatherViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getDayWeatherList().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayWeatherCell", for: indexPath)
        cell.backgroundColor = view.backgroundColor
        
        
        let dayWeather = presenter.getDayWeatherList()[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM"
        
        let dateTempOut = dateFormatter.string(from: dayWeather.date) + " \t\t" +  "\(Int(dayWeather.temperature))°C" + "\t\t" + dayWeather.weatherDet.main
        cell.textLabel?.text = dateTempOut
        cell.textLabel?.font = UIFont.systemFont(ofSize: 24)
        
        loadIcn(icon: dayWeather.weatherDet.icon) { image in
            if let image = image {
                DispatchQueue.main.async {
                    let imageView = UIImageView(image: image)
                    imageView.contentMode = .scaleAspectFit
                    imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
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
