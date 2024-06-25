//
//  DraggableTextView.swift
//  PhotoShare
//
//  Created by Abdulkadir Koyuncu on 13.05.2024.
//

import UIKit

class DraggableAndScalableTextView: UITextView, UITextViewDelegate {
    
    var lastLocation = CGPoint(x: 0, y: 0)
    var imageView : UIImageView!
    var viewController: PhotoCreateViewController!
    let maximumWidth: CGFloat = 200
    let minWidth: CGFloat = 80
    
    init(frame: CGRect, image: UIImageView, viewController: PhotoCreateViewController, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.viewController = viewController
        self.imageView = image
        self.isUserInteractionEnabled = true
        self.isScrollEnabled = false
        self.delegate = self
        self.text = "Yazınız"
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.addGestureRecognizer(panGesture)
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        self.addGestureRecognizer(pinchGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.superview)
        
        if sender.state == .began {
            self.lastLocation = self.center
        }
        
        self.center = CGPoint(x: lastLocation.x + translation.x, y: lastLocation.y + translation.y)
    }
    
    @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
        sender.view?.transform = (sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale))!
        sender.scale = 1.0
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        viewController.currentTextView = self
        if textView.text == "Yazınız" {
            textView.text = ""
        }
        updateHeight(textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Yazınız"
        }
        updateHeight(textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateHeight(textView)
    }
    
    func updateHeight(_ textView: UITextView) {
        let newSize = textView.sizeThatFits(CGSize(width: maximumWidth, height: CGFloat.greatestFiniteMagnitude))
        textView.frame.size = CGSize(width: max(newSize.width, minWidth), height: newSize.height)
    }
    
}
