//
//  PhotoDataEntity.swift
//  PhotoShare
//
//  Created by Abdulkadir Koyuncu on 16.05.2024.
//

import Foundation
import UIKit
import CoreData
import MapKit

class PhotoDataEntity {
    var id : UUID!
    var city : String?
    var state : String?
    var date : Date!
    var image : UIImage!
    
    static func buildObjectWithCoreData(object: NSManagedObject, completion: @escaping (PhotoDataEntity) -> Void) -> Void {
        let photoDataEntity = PhotoDataEntity()
        
        if let id = object.value(forKey: "id") as? UUID {
            photoDataEntity.id = id
        }
        if let date = object.value(forKey: "creation_date") as? Date {
            photoDataEntity.date = date
        }
        if let data = object.value(forKey: "image_data") as? Data {
            photoDataEntity.image = UIImage(data: data)
        }
        if let geo = object.value(forKey: "geo") as? String {
            let subsequences = geo.split(separator: " ")
            if subsequences[0] != "nan" && subsequences[1] != "nan" {
                let latitude = Double(subsequences[0])!
                let longitude = Double(subsequences[1])!
                let location = CLLocation(latitude: latitude, longitude: longitude)
                location.placemark { placemark, error in
                    photoDataEntity.city = placemark!.city!
                    photoDataEntity.state = placemark!.state!
                    completion(photoDataEntity)
                }
            }else {
                completion(photoDataEntity)
            }
        }
    }
    
}
