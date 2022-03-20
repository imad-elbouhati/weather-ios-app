//
//  ViewController.swift
//  weather-app
//
//  Created by User on 25.02.2022.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate {
    
    
    
    @IBOutlet var table: UITableView!
    
    var models = [Daily]()
    
    let locationManager = CLLocationManager()
    
    var currentLocation  : CLLocation?
    
    var currentWeather: Current?
    
    var hourlyModels = [Current]()
    
    var weatherResponse:WeatherResponse?
    
    lazy var geocoder = CLGeocoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        table.register(HourlyTableViewCell.nib(), forCellReuseIdentifier: HourlyTableViewCell.identifier)
        table.register(WeatherTableViewCell.nib(), forCellReuseIdentifier: WeatherTableViewCell.identifier)
        
        table.backgroundColor = getBackgroundColor()
        view.backgroundColor = getBackgroundColor()
        
        table.delegate = self
        table.dataSource = self
        table.separatorColor = .white
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupLocationManager()
        
        
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }
        
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: HourlyTableViewCell.identifier,for: indexPath) as! HourlyTableViewCell
            cell.configure(with: self.hourlyModels)
            cell.backgroundColor = getBackgroundColor()
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: .greatestFiniteMagnitude)
            cell.directionalLayoutMargins = .zero
            
            
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier,for: indexPath) as! WeatherTableViewCell
        cell.configure(with: models[indexPath.row])
        cell.backgroundColor = getBackgroundColor()
        return cell
    }
    
    func getBackgroundColor() -> UIColor {
        
        return UIColor(red: 158/255.0, green: 203/255.0, blue: 230/255.0, alpha: 1)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 0) {
            return 100
        }
        return 70
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil {
            currentLocation = locations.first
            locationManager.stopUpdatingLocation()
            
            requestWeatherForLocation()
        }
    }
    
    func requestWeatherForLocation() {
        guard let currentLocation = currentLocation else {
            return
        }
        
        
        let long = currentLocation.coordinate.longitude
        let lat = currentLocation.coordinate.latitude
        
        
        let url = "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(long)&exclude=minutely&units=metric&appid=f901a2900e9526f5e4843c3751f96710"
        
        print(url)
        
        URLSession.shared.dataTask(with: URL(string:url)!, completionHandler: {data , response, error in
            //Validation
            guard let data = data, error == nil else {
                print("Something went wrong")
                return
            }
            
            //Convert data to models
            
            var json : WeatherResponse?
            do {
                json = try JSONDecoder().decode(WeatherResponse.self, from: data)
            }catch {
                print("Error occured \(error)")
            }
            
            guard let result = json else {
                return
            }
            
            
            
            
            let entries = result.daily
            
            self.weatherResponse = result
            
            self.models.append(contentsOf: entries)
            
            let current = result.current
            self.currentWeather  = current
            
            let hourly = result.hourly
            
           
            
            self.hourlyModels = hourly
            
            //Update user interface
            
            
    
            
            
            DispatchQueue.main.async {
                self.table.reloadData()
                self.table.tableHeaderView = self.createTableHeader()
            }
            
            
        }).resume()
        
    }

    
    func createTableHeader() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y:0, width: view.frame.size.width, height: view.frame.size.height/4+100))
        
       
        
        headerView.backgroundColor = getBackgroundColor()
        
      
        
        
        let locationLabel = UILabel(frame: CGRect(x: 10, y: 10, width: view.frame.size.width-20, height: headerView.frame.size.height/4))
        
        
        
        let tempLabel = UILabel(frame: CGRect(x: 10, y: locationLabel.frame.size.height+20, width: view.frame.size.width-20, height: headerView.frame.size.height/4))

        
    
        
        let summaryLabel = UILabel(frame: CGRect(x: 10, y: tempLabel.frame.origin.y+tempLabel.frame.size.height, width: view.frame.size.width-20, height: headerView.frame.size.height/8))

        
        let maxMinLabel = UILabel(frame: CGRect(x: 10, y: summaryLabel.frame.origin.y+summaryLabel.frame.size.height, width: view.frame.size.width-20, height: headerView.frame.size.height/8-25))
        
        
        
    
        
        tempLabel.text = "\(Int(self.currentWeather!.temp))°"
        tempLabel.textAlignment = .center
        tempLabel.font = getFont(70)
        tempLabel.textColor = getColor(255, 255, 255)
        tempLabel.drawShadow(offset: CGSize(width: 1 ,height: 2), opacity: 0.2, color: .black, radius: 2.0)
        
        
        
        let location = currentLocation!

           // Geocode Location
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
               // Process Response
               
            if let error = error {
                print("Unable to Reverse Geocode Location (\(error))")
                locationLabel.text = "Unable to Find Address for Location"

            } else {
                if let placemarks = placemarks, let placemark = placemarks.first {
                    locationLabel.text = placemark.compactAddress
                } else {
                    locationLabel.text = "No Matching Addresses Found"
                }
            }
           }
        
        locationLabel.text = "Current Location"
        locationLabel.textAlignment = .center
        locationLabel.font = getFont(30)
        locationLabel.textColor = getColor(255, 255, 255)
        locationLabel.drawShadow(offset: CGSize(width: 1 ,height: 2), opacity: 0.2, color: .black, radius: 2.0)
        
        
        summaryLabel.text = currentWeather?.weather.first?.description
        summaryLabel.textAlignment = .center
        summaryLabel.font = getFont()
        summaryLabel.textColor = getColor(255, 255, 255)
        summaryLabel.drawShadow(offset: CGSize(width: 1 ,height: 2), opacity: 0.2, color: .black, radius: 2.0)

        
        
        let min = Int((weatherResponse?.daily.first?.temp.min)!)
        let max:Int = Int((weatherResponse?.daily.first?.temp.max)!)
        
        maxMinLabel.text = "Max. \(max)° Min. \(min)°"
        maxMinLabel.textAlignment = .center
        maxMinLabel.font = getFont()
        maxMinLabel.textColor = getColor(255, 255, 255)
        maxMinLabel.drawShadow(offset: CGSize(width: 1 ,height: 2), opacity: 0.2, color: .black, radius: 2.0)

        
        
        
       
        
        
        
        headerView.addSubview(locationLabel)
        headerView.addSubview(summaryLabel)
        headerView.addSubview(tempLabel)
        headerView.addSubview(maxMinLabel)
        
        
        
        return headerView
    }
    
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {

    }
    
    
    func getFont(_ size:CGFloat = 20) -> UIFont? {
        return UIFont(name:"AppleSDGothicNeo-Light",size: size)
    }
    
    func getColor(_ red:Int,_ green:Int, _ blue:Int) -> UIColor {
        
        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: 1)
    }
    
   
}


extension  UIView {
    func drawShadow(offset:CGSize,opacity:Float = 0.25,color:UIColor = .black,radius:CGFloat = 1) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
    }
}


extension CLPlacemark {

    var compactAddress: String? {
        if let name = name {
            var result = name

            /*if let street = thoroughfare {
                result += ", \(street)"
            }*/

            /*if let city = locality {
                result += ", \(city)"
            }*/

            if let locality = locality {
                result += "\(locality)"
            }

            return locality
        }

        return nil
    }

}

