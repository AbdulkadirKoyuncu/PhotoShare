//
//  GeoLocationExtensions.swift
//  PhotoShare
//
//  Created by Abdulkadir Koyuncu on 16.05.2024.
//
import Foundation
import MapKit
import Contacts

extension CLPlacemark {
    var streetName: String? { thoroughfare }
    var streetNumber: String? { subThoroughfare }
    var city: String? { locality }
    var neighborhood: String? { subLocality }
    var state: String? { administrativeArea }
    var county: String? { subAdministrativeArea }
    var zipCode: String? { postalCode }
    @available(iOS 11.0, *)
    var postalAddressFormatted: String? {
        guard let postalAddress = postalAddress else { return nil }
        return CNPostalAddressFormatter().string(from: postalAddress)
    }
}

extension CLLocation {
    func placemark(completion: @escaping (_ placemark: CLPlacemark?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first, $1) }
    }
}
