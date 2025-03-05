//
//  SearchService.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 04/02/2025.
//

import SwiftUI
import CoreLocation

protocol SearchAble {
    var name: String {get}
    var companyName: String {get}
    var phone: String {get}
    var latitude: Double? {get}
    var longitude: Double? {get}
    
}

struct SearchService {
    
    static func filterModels<T: SearchAble>(
        models: [T],
        searchText: String,
        userLocation: CLLocation?,
        radius: CLLocationDistance
    ) -> [T] {
        let maxRadius: CLLocationDistance = 10000
        let adjustedRadius = min(radius, maxRadius)

        return models.filter { model in
            let matchesName = searchText.isEmpty ||
                model.name.localizedCaseInsensitiveContains(searchText) ||
                model.phone.localizedCaseInsensitiveContains(searchText) ||
                model.companyName.localizedCaseInsensitiveContains(searchText)

            guard let userLocation = userLocation,
                  let distance = calculateDistance(from: userLocation, to: model) else {
                return false
            }

            let isNearby = distance <= adjustedRadius
            return matchesName && isNearby
        }
    }
    
    static func calculateDistance<T: SearchAble>(from userLocation: CLLocation, to company: T) -> CLLocationDistance? {
        guard let latitude = company.latitude, let longitude = company.longitude else { return nil }
        let companyLocation = CLLocation(latitude: latitude, longitude: longitude)
        return userLocation.distance(from: companyLocation)
    }
}
