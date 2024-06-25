//
//  ViewController.swift
//  PhotoShare
//
//  Created by Abdulkadir Koyuncu on 13.05.2024.
//

import UIKit
import Photos
import CoreLocation
import CoreData

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    let dateFormatter : DateFormatter = DateFormatter()
    let locationManager = CLLocationManager()
    var photoDataEntities : [PhotoDataEntity] = []
    var capturedPhoto: UIImage!
    var date: Date!
    var userLocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(photoSaveObserve(_:)), name: NSNotification.Name(rawValue: "photoSave"), object: nil)
        dateFormatter.dateFormat = "dd.MM.y HH:mm"
        locationManager.delegate = self
        self.tableView.delegate = self
        tableView.separatorStyle = .none
        navigationItem.title = "PhotoShare"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(cameraIconTapped))
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PhotoData")
        request.returnsObjectsAsFaults = false
        do {
            let results = try getCoreDataViewContext().fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    PhotoDataEntity.buildObjectWithCoreData(object: result, completion: { photoDataEntity in
                        self.photoDataEntities.append(photoDataEntity)
                        if(self.photoDataEntities.count == results.count) {
                            self.photoDataEntities.sort { e1, e2 in
                                e1.date.compare(e2.date).rawValue == -1 ? false : true
                            }
                            self.tableView.dataSource = self
                            self.tableView.reloadData()
                        }
                    })
                }
            }
        } catch {
            NSLog("coredatadan veriler getirilirken hata oluştu: \(error)")
        }
        /*let ReqVar = NSFetchRequest<NSFetchRequestResult>(entityName: "PhotoData")
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: ReqVar)
        do { try getCoreDataViewContext().execute(DelAllReqVar) }
        catch { print(error) }*/
        
    }
    
    @objc func photoSaveObserve(_ notification: NSNotification) {
        if let entity = notification.userInfo?["entity"] as? PhotoDataEntity {
            photoDataEntities.insert(entity, at: 0)
            self.tableView.dataSource = self
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoDataEntities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = photoDataEntities[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "customPhotoCell", for: indexPath) as! CustomPhotoCell
        cell.viewController = self
        cell.geoLabel.text = entity.city == nil && entity.state == nil ? "Konum Yok" : "\(entity.state!) \(entity.city!)"
        cell.dateLabel.text = dateFormatter.string(from: entity.date)
        cell.uiImageView.image = entity.image
        return cell
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0]
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch locationManager.authorizationStatus {
            case .restricted, .denied:
                makeAlert(title: "Devam Edin", message: "Konum izni verilmediği taktirde fotoğraflarda konum gözükmez.") { action in
                    self.presentImagePicker()
                }
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
                self.presentImagePicker()
            default:
                return
        }
    }
    
    @objc func cameraIconTapped() {
        switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted, .denied:
                makeAlert(title: "Devam Edin", message: "Konum izni verilmediği taktirde fotoğraflarda konum gözükmez.") { action in
                    self.presentImagePicker()
                }
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
                self.presentImagePicker()
            default:
                return
        }
    }
    
    func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraFlashMode = .off
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        locationManager.stopUpdatingLocation()
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }
        guard let metadata = info[.mediaMetadata] as? [String: Any] else { return }
        guard let exifDict = metadata[kCGImagePropertyExifDictionary as String] as? [String: Any] else { return }
        if let dateString = exifDict[kCGImagePropertyExifDateTimeOriginal as String] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
            date = dateFormatter.date(from: dateString)!
        }
        capturedPhoto = image
        performSegue(withIdentifier: "toPhotoCreate", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhotoCreate" {
            if let toPhotoCreateViewController = segue.destination as? PhotoCreateViewController {
                toPhotoCreateViewController.image = capturedPhoto
                toPhotoCreateViewController.date = date
                toPhotoCreateViewController.userLocation = userLocation
            }
        }
    }

}
    
extension UIViewController {
    func makeAlert(title: String, message: String) {
        makeAlert(title: title, message: message) { action in }
    }
    
    func makeAlert(title: String, message: String, handler: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Tamam", style: .cancel, handler: handler)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    func getCoreDataViewContext() -> NSManagedObjectContext {
        let appDelegete = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegete.persistentContainer.viewContext
        return context
    }
    
}
