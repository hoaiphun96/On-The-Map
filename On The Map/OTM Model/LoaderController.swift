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
    private var holdingView = UIView()
    private let blurView = UIView()
    //MARK: - Private Methods -
    private func setupLoader() {
        removeLoader()
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
    }
    
    //MARK: - Public Methods -
    func showLoader() {
        setupLoader()
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        holdingView = appDel.window!.rootViewController!.view!
      
        DispatchQueue.main.async {
            self.blurView.frame = self.holdingView.frame
            self.blurView.center = self.holdingView.center
            self.blurView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            
            self.activityIndicator.center = self.holdingView.center
            self.activityIndicator.startAnimating()
            self.blurView.addSubview(self.activityIndicator)
            self.holdingView.addSubview(self.blurView)
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
    }
    
    func removeLoader(){
        DispatchQueue.main.async {
            self.blurView.removeFromSuperview()
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
}
