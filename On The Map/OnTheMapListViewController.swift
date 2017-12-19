//
//  OnTheMapControllerViewController.swift
//  On The Map
//
//  Created by Jamie Nguyen on 12/5/17.
//  Copyright © 2017 Jamie Nguyen. All rights reserved.
//

import UIKit

class OnTheMapListViewController: UIViewController , UITableViewDataSource{
    
    
    @IBOutlet weak var studentLocationsTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadData()
    }
    
    @IBAction func logOutClicked(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func loadData() {
        LoaderController.sharedInstance.showLoader()
        self.navigationController?.navigationBar.isHidden = true
        let _ = OTMClient.sharedInstance().getStudentLocations { (locations, error) in
            if let locations = locations {
                OTMClient.sharedInstance().studentInformationModel = locations
                performUIUpdatesOnMain {
                    self.studentLocationsTableView.reloadData()
                    LoaderController.sharedInstance.removeLoader()
                }
            } else {
                LoaderController.sharedInstance.removeLoader()
                OTMClient.sharedInstance().showAlertMessage(title: "", message: "Failed to download student locations", viewController: self, shouldPop: false)
            }
        }
    }
    
    @IBAction func refreshClicked(_ sender: Any) {
        self.loadData()
    }
    
    @IBAction func pinLocationClicked(_ sender: Any) {
        // TODO: check if a pin already existed
        let _ = OTMClient.sharedInstance().getAStudentLocation { (success, errorString) in
            if success {
                if errorString == nil {
                    // TODO: SHOW ALERT AND ASK IF YOU WANT TO UPDATE (OVERWRITE, CANCEL), IF OVERWRITE CALL POST NEW PIN FUNCTION ELSE DISMISS ALERT
                    let alert = UIAlertController(title: "", message: "You Have Already Posted A Student Location. Would You Like To OverWrite Your Current Position?", preferredStyle: .alert)
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
        let studentInformation = OTMClient.sharedInstance().studentInformationModel[(indexPath as NSIndexPath).row]
        
        /* Set cell defaults */
        cell.nameLabel.text = (studentInformation.firstName ?? "No") + " " + (studentInformation.lastName ?? "Name")!
        return cell
    }
        
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OTMClient.sharedInstance().studentInformationModel.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let app = UIApplication.shared
        let toOpen = OTMClient.sharedInstance().studentInformationModel[(indexPath as NSIndexPath).row].mediaURL
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

