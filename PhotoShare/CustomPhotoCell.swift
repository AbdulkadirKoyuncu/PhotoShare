//
//  CustomPhotoCell.swift
//  PhotoShare
//
//  Created by Abdulkadir Koyuncu on 16.05.2024.
//

import UIKit

class CustomPhotoCell: UITableViewCell {
    @IBOutlet weak var geoLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var uiImageView: UIImageView!
    weak var viewController : UIViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func shareButtonClicked(_ sender: Any) {
        let activityViewController = UIActivityViewController(activityItems: [uiImageView.image!], applicationActivities: [])
        /*activityViewController.excludedActivityTypes = [
            .postToTwitter,
            .postToFacebook,
            .saveToCameraRoll
        ]*/
        viewController.present(activityViewController, animated: true)
    }
}
