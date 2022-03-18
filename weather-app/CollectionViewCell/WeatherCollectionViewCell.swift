//
//  WeatherCollectionViewCell.swift
//  weather-app
//
//  Created by User on 03.03.2022.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "WeatherCollectionViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "WeatherCollectionViewCell", bundle: nil)
    }
    
    @IBOutlet var iconImageView:UIImageView!
    @IBOutlet var tempLabel:UILabel!
    @IBOutlet var hourLabel:UILabel!
    
    func configure(with model:Current) {
        self.tempLabel.text = "\(Int(model.temp))°"
        hourLabel.text = getHourForDate(Date(timeIntervalSince1970: Double(model.dt)))
        
        let icon = model.weather.first?.icon
        let imageUrl =  "http://openweathermap.org/img/wn/\(icon!)@2x.png"
        
        self.iconImageView.downloaded(from: imageUrl)
    }
    
    
    
    
    func getHourForDate(_ date:Date?) -> String {
        guard let inputDate = date else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "hh a"
        return formatter.string(from: inputDate)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
