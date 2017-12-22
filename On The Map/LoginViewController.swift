//
//  ViewController.swift
//  On The Map
//
//  Created by Jamie Nguyen on 12/5/17.
//  Copyright © 2017 Jamie Nguyen. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    
    var session: URLSession!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.passwordTextField.text = nil
        self.emailTextField.text = nil
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func login(_ sender: Any) {
        LoaderController.sharedInstance.showLoader(view)
        if OTMClient.sharedInstance.isInternetAvailable() == true {
            let parameters = ["username": emailTextField.text,
                              "password": passwordTextField.text] as [String: AnyObject]
            OTMClient.sharedInstance.username = emailTextField.text
            OTMClient.sharedInstance.password = passwordTextField.text
            let _ = OTMClient.sharedInstance.authenticateWithViewController(self,parameters) { (success, errorString) in
                performUIUpdatesOnMain {
                    if success {
                        self.completeLogin()
                    } else {
                        LoaderController.sharedInstance.removeLoader()
                        OTMClient.sharedInstance.showAlertMessage(title: "", message: errorString!, viewController: self, shouldPop: false)
                        self.passwordTextField.text = nil
                        self.emailTextField.text = nil
                    }
                }
            }
        }
            
        else {
            LoaderController.sharedInstance.removeLoader()
            OTMClient.sharedInstance.showAlertMessage(title: "", message: "The internet connection appears to be offline", viewController: self, shouldPop: false)
        }
    }
    // MARK: Sign up
    
    @IBAction func signUp(_ sender: Any) {
        let app = UIApplication.shared
        let toOpen = "https://www.udacity.com/account/auth#!/signup"
        app.open(URL(string: toOpen)!, options: [:], completionHandler: { (success) in
            if success == false {
                print("FAIL TO OPEN URL")
                return
            }})
    }
    
    // MARK: Login
    
    private func completeLogin() {
        let _ = OTMClient.sharedInstance.getPublicUserData { (success, errorString) in
            if success {
                performUIUpdatesOnMain {
                    LoaderController.sharedInstance.removeLoader()
                    let viewController = self.storyboard!.instantiateViewController(withIdentifier: "OnTheMapViewController")
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            }
            else {
                LoaderController.sharedInstance.removeLoader()
                OTMClient.sharedInstance.showAlertMessage(title: "", message: "Cannot retrieve your account information", viewController: self, shouldPop: false)
            }
        }
    }
}

extension LoginViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}





