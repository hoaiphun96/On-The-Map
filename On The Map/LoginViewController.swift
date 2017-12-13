//
//  ViewController.swift
//  On The Map
//
//  Created by Jamie Nguyen on 12/5/17.
//  Copyright © 2017 Jamie Nguyen. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    var session: URLSession!
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    
    @IBAction func login(_ sender: Any) {
        let parameters = ["username": emailTextField.text,
                          "password": passwordTextField.text] as [String: AnyObject]
        OTMClient.sharedInstance().username = emailTextField.text
        OTMClient.sharedInstance().password = passwordTextField.text
        let _ = OTMClient.sharedInstance().authenticateWithViewController(self,parameters) { (success, errorString) in
            performUIUpdatesOnMain {
                if success {
                    self.completeLogin()
                } else {
                    OTMClient.sharedInstance().showAlertMessage(title: "Login Failed", message: errorString!, viewController: self, shouldPop: false)
                    self.passwordTextField.text = nil
                    self.emailTextField.text = nil
                }
            }
        }
        
    }
    
    // MARK: Login
    
    private func completeLogin() {
        let _ = OTMClient.sharedInstance().getPublicUserData { (success, errorString) in
            if success {
                performUIUpdatesOnMain {
                    let viewController = self.storyboard!.instantiateViewController(withIdentifier: "OnTheMapViewController")
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            }
            else {
                OTMClient.sharedInstance().showAlertMessage(title: "Error", message: "Cannot retrieve your account information", viewController: self, shouldPop: false)
            }
        }
        
    }
}


private extension LoginViewController {
    
    func setUIEnabled(_ enabled: Bool) {
        loginButton.isEnabled = enabled
        
        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }
    
    
}


