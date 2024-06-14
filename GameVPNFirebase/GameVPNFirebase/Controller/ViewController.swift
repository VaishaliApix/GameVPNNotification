//
//  ViewController.swift
//  GameVPNFirebase
//
//  Created by Aip-59 Vaishali on 13/06/24.
//

import UIKit
import SVProgressHUD

class ViewController: UIViewController {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var txtIPAddress: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnUpdate: UIButton!
    
    //MARK: - Variable
    
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
}

//MARK: - Button Action
extension ViewController{
    func setup(){
        self.btnUpdate.layer.cornerRadius = self.btnUpdate.frame.height / 2
    }
    
}

//MARK: - Button Action
extension ViewController{
    @IBAction func btnUpdateAction(_ sender: UIButton) {
        let firebaseConnect = FirebaseConnect()

        if txtIPAddress.text == "" {
            showAlert(title: "GameVPN", message: "Please enter IPAddress")
        } else if txtPassword.text == "" {
            showAlert(title: "GameVPN", message: "Please enter password")
        } else {
            let password = txtPassword.text ?? ""
            let ipAddress = txtIPAddress.text ?? ""
            SVProgressHUD.show()
            firebaseConnect.encryptPassword(password: password, iPAddress: ipAddress, vc: self) { encryptedPassword in
                guard let encryptedPassword = encryptedPassword else {
                    print("Encryption failed.")
                    self.showAlert(title: "GameVPN", message: "Encryption failed.")
                    return
                }
                
                firebaseConnect.updateUserIPAddressOnPasswordChange(iPAddress: ipAddress, password: encryptedPassword, vc: self)
                self.txtPassword.text = ""
                self.txtIPAddress.text = ""
                
            }
        }
    }
}
