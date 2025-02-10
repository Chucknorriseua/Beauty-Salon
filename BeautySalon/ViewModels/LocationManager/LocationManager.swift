//
//  LocationManager.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 20/10/2024.
//

import Foundation
import CoreLocation

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    static var shared = LocationManager()
    
     var locationManager = CLLocationManager()
    
    @Published var userLatitude: Double = 0.0
    @Published var userLongitude: Double = 0.0
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var locationError: Error?
    @Published var isUpdateLocation: Bool = false
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    deinit {
        locationManager.delegate = nil
        locationManager.stopUpdatingLocation()
    }
    
    func startUpdate() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdate() {
        locationManager.stopUpdatingLocation()
    }
    
    
    
    func updateLocation(company: Company_Model) async {
        guard userLatitude != 0.0,  userLongitude != 0.0 else { return }
        
        var updateCompany = company
        updateCompany.latitude = userLatitude
        updateCompany.longitude = userLongitude
        await Admin_DataBase.shared.updateLocationCompany(company: updateCompany)
    }
    
    func updateLocationMaster(company: MasterModel) async {
        guard userLatitude != 0.0,  userLongitude != 0.0 else { return }
        
        var updateCompany = company
        updateCompany.latitude = userLatitude
        updateCompany.longitude = userLongitude
        await Master_DataBase.shared.updateLocationCompany(company: updateCompany)
    }
    
    func updateLocationClient(company: Client) async {
        guard userLatitude != 0.0,  userLongitude != 0.0 else { return }
        
        var updateCompany = company
        updateCompany.latitude = userLatitude
        updateCompany.longitude = userLongitude
        await Client_DataBase.shared.updateLocationCompany(company: updateCompany)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.userLatitude = location.coordinate.latitude
                self.userLongitude = location.coordinate.longitude
                Task {
                    if self.isUpdateLocation {
                        await self.updateLocationMaster(company: MasterViewModel.shared.masterModel)
                        await self.updateLocationClient(company: ClientViewModel.shared.clientModel)
                        self.isUpdateLocation = false
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorizationStatus = status
    }
    

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
           self.locationError = error
           print("Failed to find user's location: \(error.localizedDescription)")
    }
   

    func calculateDistance(from userLocation: CLLocation, to company: Company_Model) -> CLLocationDistance? {
        guard let latitude = company.latitude, let longitude = company.longitude else { return nil }
        let companyLocation = CLLocation(latitude: latitude, longitude: longitude)
        return userLocation.distance(from: companyLocation)
    }
    
    func calculateDistanceMaster(from userLocation: CLLocation, to company: MasterModel) -> CLLocationDistance? {
        guard let latitude = company.latitude, let longitude = company.longitude else { return nil }
        let companyLocation = CLLocation(latitude: latitude, longitude: longitude)
        return userLocation.distance(from: companyLocation)
    }
}
