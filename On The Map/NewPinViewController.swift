//
//  NewPinViewController.swift
//  On The Map
//
//  Created by Jamie Nguyen on 12/6/17.
//  Copyright © 2017 Jamie Nguyen. All rights reserved.
//

import UIKit

class NewPinViewController: UIViewController {
    
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        locationTextField.text = nil
        websiteTextField.text = nil
    }

    func goBack()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func findOnTheMapClicked(_ sender: Any) {
        //if location text field empty
        guard locationTextField.text != nil else {
            OTMClient.sharedInstance().showAlertMessage(title: "Location Not Found", message: "Must Enter a Location", viewController: self, shouldPop: false)
            return
        }
        guard websiteTextField.text != nil else {
            OTMClient.sharedInstance().showAlertMessage(title: "Location Not Found", message: "Must Enter a Website", viewController: self, shouldPop: false)
            return
        }
        guard websiteTextField.text!.lowercased().hasPrefix("https://") || websiteTextField.text!.lowercased().hasPrefix("http://") else {
            OTMClient.sharedInstance().showAlertMessage(title: "Location Not Found", message: "Invalid Link. Include HTTP(S)://", viewController: self, shouldPop: false)
            return
        }
        let viewController = storyboard!.instantiateViewController(withIdentifier: "SubmitPinViewController") as! SubmitPinViewController
        viewController.newlocation = locationTextField.text
        viewController.newmediaurl = websiteTextField.text
        navigationController?.pushViewController(viewController, animated: true)
    }
    

}
