//
//  showLoader.swift
//  On The Map
//
//  Created by Jamie Nguyen on 12/15/17.
//  Copyright © 2017 Jamie Nguyen. All rights reserved.
//

import Foundation
import UIKit
class LoaderController: NSObject {
    
    static let sharedInstance = LoaderController()
    private let activityIndicator = UIActivityIndicatorView()
    private let blurView = UIView()
    private func setupLoader() {
        removeLoader()
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
    }
    
    //MARK: - Public Methods -
    func showLoader(_ holdingView: UIView) {
        setupLoader()
        
        DispatchQueue.main.async {
            self.blurView.frame = holdingView.bounds
            self.blurView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            
            self.activityIndicator.center = holdingView.center
            self.activityIndicator.startAnimating()
            self.blurView.addSubview(self.activityIndicator)
            holdingView.addSubview(self.blurView)
        }
    }
    
    func removeLoader(){
        DispatchQueue.main.async {
            self.blurView.removeFromSuperview()
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
        }
    }
}
