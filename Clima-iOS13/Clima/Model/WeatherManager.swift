//
//  WeatherManager.swift
//  Clima
//
//  Created by Elyasaf Klein on 14/11/2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

//my private key = "3e9a24d0c529b8f12a71f862416cdd52"

import Foundation
import CoreLocation


protocol WeatherManagerDelegate{
    func didUpdateWeather(_ weathermanager:WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}



struct WeatherManager{
    var delegate: WeatherManagerDelegate?
    
    //let weatherLL = "api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API key}"
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=3e9a24d0c529b8f12a71f862416cdd52&units=metric"

    
    func fetchWeather(cityName: String) {
        let fullURL =  weatherURL+"&q=\(cityName)"
        performRequest(with: fullURL)
       }
    
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let fullURL = weatherURL+"&lon=\(longitude)&lat=\(latitude)"
        performRequest(with: fullURL)
        
       }
    
    
    func performRequest(with urlString:String){
        //create URL
        if let url = URL(string: urlString){
            //Create URLSeasion
            let seasion = URLSession(configuration: .default)
            //Give the seasion a task
            let task = seasion.dataTask(with: url) { data, response, error in
                if error != nil{
                    delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data{
                    if let weather =  self.parseJSON(weatherData: safeData){
                        delegate?.didUpdateWeather(self, weather:weather)
                    }
                   
                }
            }
            //Start the task
            task.resume()
        }
    }
    
    
    func parseJSON(weatherData: Data)->WeatherModel?{
         let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
    
    
    
}
