//
//  PhotoCreateViewController.swift
//  PhotoShare
//
//  Created by Abdulkadir Koyuncu on 13.05.2024.
//

import UIKit
import Photos
import CoreData

class PhotoCreateViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var image : UIImage!
    var currentTextView : DraggableAndScalableTextView?
    var date : Date!
    var userLocation : CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(disableFocus))
        imageView.addGestureRecognizer(tapGesture)
        navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Kaydet", style: .plain, target: self, action: #selector(savePhoto)), UIBarButtonItem(title: "Yazı Ekle", style: .plain, target: self, action: #selector(addTextField))]
    }
    
    @objc func disableFocus() {
        currentTextView?.endEditing(true)
    }
    
    @objc func addTextField() {
        let textView = DraggableAndScalableTextView(frame: CGRect(x: UIScreen.main.bounds.size.width / 2 - 40, y: imageView.bounds.size.height / 2 - 17.5, width: 80, height: 35.33), image: imageView, viewController: self, textContainer: nil)
        textView.font = UIFont.systemFont(ofSize: 16.0)
        textView.textColor = .white
        textView.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5)
        textView.textAlignment = .center
        textView.layer.cornerRadius = 10
        currentTextView = textView
        imageView.addSubview(textView)
    }
    
    @objc func savePhoto() {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                UIGraphicsBeginImageContextWithOptions(self.imageView.bounds.size, false, UIScreen.main.scale)
                let context = UIGraphicsGetCurrentContext()
                self.imageView.layer.render(in: context!)
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                let photoData = NSEntityDescription.insertNewObject(forEntityName: "PhotoData", into: self.getCoreDataViewContext())
                photoData.setValue(UUID(), forKey: "id")
                photoData.setValue(self.date, forKey: "creation_date")
                photoData.setValue(image?.jpegData(compressionQuality: 1), forKey: "image_data")
                photoData.setValue("\(self.userLocation?.coordinate.latitude ?? Double.nan) \( self.userLocation?.coordinate.longitude ?? Double.nan)", forKey: "geo")
                do{
                    try self.getCoreDataViewContext().save()
                } catch {
                    NSLog("fotoğraf uygulama veritabanına kaydedilirken hata alındı: \(error)")
                }
                if status.rawValue != 3 {
                    self.makeAlert(title: "Galeri İzni Verin", message: "Kaydetmek için galeri iznine ihtiyacımız var") { action in
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }else {
                    self.addAsset(image: image!, location: self.userLocation)
                    self.makeAlert(title: "Fotoğraf Kaydedildi", message: "") { action in
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
                PhotoDataEntity.buildObjectWithCoreData(object: photoData, completion: { entity in
                    let entityDict: [String: PhotoDataEntity] = ["entity": entity]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "photoSave"), object: nil, userInfo: entityDict)
                })
            }
        }
    }
    
    func addAsset(image: UIImage, location: CLLocation? = nil) {
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            if let location = location {
                creationRequest.location = location
                creationRequest.creationDate = self.date
            }
        }, completionHandler: { success, error in
            if !success {
                DispatchQueue.main.async {
                    self.makeAlert(title: "Hata", message: "Fotoğraf kaydedilirken hata meydana geldi.")
                }
                NSLog("fotoğraf oluşturulurken hata alındı: \(error!)")
            }
        })
    }
}
