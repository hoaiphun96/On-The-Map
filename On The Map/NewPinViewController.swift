//
//  NewPinViewController.swift
//  On The Map
//
//  Created by Jamie Nguyen on 12/6/17.
//  Copyright © 2017 Jamie Nguyen. All rights reserved.
//

import UIKit

class NewPinViewController: UIViewController {
    
    @IBOutlet weak var locationTextField: UITextField!
   
    override func viewWillAppear(_ animated: Bool) {
        locationTextField.text = nil
    }

    @IBAction func cancelClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func findOnTheMapClicked(_ sender: Any) {
        let viewController = storyboard!.instantiateViewController(withIdentifier: "SubmitPinViewController") as! SubmitPinViewController
        viewController.newlocation = locationTextField.text
        navigationController?.pushViewController(viewController, animated: true)
    }
    

}
