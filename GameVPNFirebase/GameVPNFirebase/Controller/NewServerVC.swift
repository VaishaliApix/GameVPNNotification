//
//  NewServerVC.swift
//  GameVPNFirebase
//
//  Created by Aip-59 Vaishali on 13/06/24.
//

import UIKit
import SVProgressHUD

class NewServerVC: UIViewController {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var txtContry: UITextField!
    @IBOutlet weak var txtContrycode: UITextField!
    @IBOutlet weak var txtState: UITextField!
    @IBOutlet weak var txtUser: UITextField!
    @IBOutlet weak var txtDomain: UITextField!
    @IBOutlet weak var txtIPAddress: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnsubmit: UIButton!
    
    //MARK: - Variable
    let firebaseConnect = FirebaseConnect()
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
}

//MARK: - Button Action
extension NewServerVC{
    func setup(){
        self.btnsubmit.layer.cornerRadius = self.btnsubmit.frame.height / 2
    }
}

//MARK: - Button Action
extension NewServerVC{
    @IBAction func btnSubmitAction(_ sender: UIButton) {
        if txtUser.text == "" && txtUser.text?.count ?? 0 <= 0{
            showAlert(title: "GameVPN", message: "Please enter username")
        }else if txtContry.text == "" {
            showAlert(title: "GameVPN", message: "Please enter country")
        }else if txtContrycode.text == "" {
            showAlert(title: "GameVPN", message: "Please enter country code")
        }else if txtState.text == "" {
            showAlert(title: "GameVPN", message: "Please enter state")
        } else if txtIPAddress.text == "" {
            showAlert(title: "GameVPN", message: "Please enter IPAddress")
        } else if txtDomain.text == "" {
            showAlert(title: "GameVPN", message: "Please enter domain")
        } else if txtPassword.text == "" {
            showAlert(title: "GameVPN", message: "Please enter password")
        } else {
            SVProgressHUD.show()
            firebaseConnect.encryptPassword(password: txtPassword.text ?? "", vc: self) { encryptedPassword in
                guard let encryptedPassword = encryptedPassword else {
                    print("Encryption failed.")
                    self.showAlert(title: "GameVPN", message: "Encryption failed.")
                    return
                }
                self.firebaseConnect.SetNewServerDataToFirebase(country: self.txtContry.text ?? "", countryCode: self.txtContrycode.text ?? "", domain: self.txtDomain.text ?? "", ip: self.txtIPAddress.text ?? "", password: encryptedPassword, state: self.txtState.text ?? "", username: self.txtUser.text ?? "",  vc: self)
            }
        }
        }
    }
