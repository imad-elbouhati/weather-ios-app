//
//  WeatherTableViewCell.swift
//  weather-app
//
//  Created by User on 25.02.2022.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {
    
    @IBOutlet var dayLabel : UILabel!
    @IBOutlet var highTempLabel : UILabel!
    @IBOutlet var lowTempLabel : UILabel!
    @IBOutlet var iconImageView : UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    static let identifier = "WeatherTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "WeatherTableViewCell", bundle: nil)
    }
    
    
    func configure(with model : Daily) {
        self.lowTempLabel.textAlignment = .center
        self.highTempLabel.textAlignment = .center
        
        self.lowTempLabel.text = "\(Int((model.temp.min)))°"
        self.highTempLabel.text = "\(Int((model.temp.max)))°"
        self.dayLabel.text = getDayForDate(Date(timeIntervalSince1970: Double(model.dt)))
        
        
        
        let icon = model.weather.first?.icon
        let imageUrl =  "http://openweathermap.org/img/wn/\(icon!)@2x.png"
        
        self.iconImageView.downloaded(from: imageUrl)

    
        
    }
    
    func getDayForDate(_ date:Date?) -> String {
        guard let inputDate = date else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: inputDate)
    }
    
    
   
}



extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

