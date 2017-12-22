//
//  OnTheMapControllerViewController.swift
//  On The Map
//
//  Created by Jamie Nguyen on 12/5/17.
//  Copyright © 2017 Jamie Nguyen. All rights reserved.
//

import UIKit

class OnTheMapListViewController: UIViewController , UITableViewDataSource{
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var studentLocationsTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadData()
        
    }
    
    @IBAction func logOutClicked(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func loadData() {
        LoaderController.sharedInstance.showLoader(tableView)
        self.navigationController?.navigationBar.isHidden = true
        let _ = OTMClient.sharedInstance.getStudentLocations { (locations, error) in
            if let locations = locations {
                Students.sharedInstance = locations
                performUIUpdatesOnMain {
                    self.studentLocationsTableView.reloadData()
                    LoaderController.sharedInstance.removeLoader()
                }
            } else {
                LoaderController.sharedInstance.removeLoader()
                OTMClient.sharedInstance.showAlertMessage(title: "", message: "No student found", viewController: self, shouldPop: false)
            }
        }
    }
    
    @IBAction func refreshClicked(_ sender: Any) {
        self.loadData()
    }
    
    @IBAction func pinLocationClicked(_ sender: Any) {
        // TODO: check if a pin already existed
        let _ = OTMClient.sharedInstance.getAStudentLocation { (success, errorString) in
            if success {
                if errorString == nil {
                    let alert = UIAlertController(title: "", message: "You have already posted a student location. Would you like to overWrite your current position?", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Overwrite", comment: "Default action"), style: .`default`, handler: { _ in
                        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "NewPinViewController")
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }))
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .cancel, handler: {(alertAction: UIAlertAction!) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    print(errorString!)
                    performUIUpdatesOnMain {
                        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "NewPinViewController")
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }
                }
            }
            else {
                // IF NOT SUCCESS
                OTMClient.sharedInstance.showAlertMessage(title: "", message: errorString!, viewController: self, shouldPop: false)
                print(errorString!)
                return
            }
        }
        
    }
    
}

extension OnTheMapListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /* Get cell type */
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath) as! NameViewCell
        let studentInformation = Students.sharedInstance[(indexPath as NSIndexPath).row]
        /* Set cell defaults */
        cell.nameLabel.text = (studentInformation.firstName ?? "No") + " " + (studentInformation.lastName ?? "Name")!
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Students.sharedInstance.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let app = UIApplication.shared
        let toOpen = Students.sharedInstance[(indexPath as NSIndexPath).row].mediaURL
        app.open(URL(string: toOpen!)!, options: [:], completionHandler: { (success) in
            if success == false {
                return
            }
        })
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    } 
}

