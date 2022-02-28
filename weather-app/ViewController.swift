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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        table.register(HourlyTableViewCell.nib(), forCellReuseIdentifier: HourlyTableViewCell.identifier)
        table.register(WeatherTableViewCell.nib(), forCellReuseIdentifier: WeatherTableViewCell.identifier)
        
        table.delegate = self
        table.dataSource = self
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupLocationManager()
        
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier,for: indexPath) as! WeatherTableViewCell
        cell.configure(with: models[indexPath.row])
        return cell
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
            
            //Update user interface
            
            DispatchQueue.main.async {
                self.table.reloadData()
            }
            
            
        }).resume()
        
    }
}


