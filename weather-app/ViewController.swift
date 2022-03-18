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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        table.register(HourlyTableViewCell.nib(), forCellReuseIdentifier: HourlyTableViewCell.identifier)
        table.register(WeatherTableViewCell.nib(), forCellReuseIdentifier: WeatherTableViewCell.identifier)
        
        table.backgroundColor = getBackgroundColor()
        view.backgroundColor = getBackgroundColor()
        
        table.delegate = self
        table.dataSource = self
        
        
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
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier,for: indexPath) as! WeatherTableViewCell
        cell.configure(with: models[indexPath.row])
        cell.backgroundColor = getBackgroundColor()
        return cell
    }
    
    func getBackgroundColor() -> UIColor {
        
        return UIColor(red: 102/255.0, green: 166/255.0, blue: 204/255.0, alpha: 1)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
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
        let headerView = UIView(frame: CGRect(x: 0, y:0, width: view.frame.size.width, height: view.frame.size.width))
        
        headerView.backgroundColor = getBackgroundColor()
        
        
        let locationLabel = UILabel(frame: CGRect(x: 10, y: 10, width: view.frame.size.width-20, height: headerView.frame.size.height/5))
        
        let summaryLabel = UILabel(frame: CGRect(x: 10, y: 20+locationLabel.frame.size.height, width: view.frame.size.width-20, height: headerView.frame.size.height/5))
        
        let tempLabel = UILabel(frame: CGRect(x: 10, y: 20+locationLabel.frame.size.height+summaryLabel.frame.size.height, width: view.frame.size.width-20, height: headerView.frame.size.height/3))
        
        tempLabel.text = "\(Int(self.currentWeather!.temp))°"
        tempLabel.textAlignment = .center
        tempLabel.font = UIFont(name: "Helvetica", size: 60)
        
        locationLabel.text = "Current Location"
        locationLabel.textAlignment = .center
        
        
        summaryLabel.text = currentWeather?.weather.first?.description
        summaryLabel.textAlignment = .center
        
        
       
        
        
        
        headerView.addSubview(locationLabel)
        headerView.addSubview(summaryLabel)
        headerView.addSubview(tempLabel)
        
        
        
        return headerView
    }
}


