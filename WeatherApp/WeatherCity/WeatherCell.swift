//
//  WeatherCell.swift
//  WeatherApp
//
//  Created by Александр Печинкин on 07.05.2024.
//

import UIKit

class WeatherCell: UICollectionViewCell {
    
    // UI элементы для отображения времени, изображения и температуры
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    let weatherImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let temperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Добавляем UI элементы на ячейку
        addSubview(timeLabel)
        addSubview(weatherImageView)
        addSubview(temperatureLabel)
        
        // Устанавливаем ограничения для UI элементов
        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            
            weatherImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            weatherImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            weatherImageView.widthAnchor.constraint(equalToConstant: 50),
            weatherImageView.heightAnchor.constraint(equalToConstant: 50),
            
            temperatureLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            temperatureLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
