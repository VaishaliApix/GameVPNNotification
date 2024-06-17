//
//  FirebaseConnect.swift
//  GameVPNFirebase
//
//  Created by Aip-59 Vaishali on 13/06/24.
//

import Foundation
import FirebaseCore
import FirebaseDatabase
import CommonCrypto
import SVProgressHUD
import UIKit

class FirebaseConnect : ObservableObject {
    static private var key: String = "0-qh#@,c^._PNmX5!]gpM_vHJfCP2POs"
    var ref: DatabaseReference!
    
    init() {
        self.ref = Database.database().reference()
    }
    
    public func encryptPassword(password: String,vc: UIViewController, completion: @escaping (String?) -> Void) {
        
        guard let keyData = FirebaseConnect.key.data(using: .utf8), let passwordData = password.data(using: .utf8) else {
            completion(nil)
            return
        }
        
        let cryptLength = size_t(passwordData.count + kCCBlockSizeAES128)
        var cryptData = Data(count: cryptLength)
        
        let keyLength = size_t(kCCKeySizeAES128)
        let options = CCOptions(kCCOptionPKCS7Padding)
        
        var numBytesEncrypted: size_t = 0
        
        let cryptStatus = cryptData.withUnsafeMutableBytes { cryptBytes in
            passwordData.withUnsafeBytes { dataBytes in
                keyData.withUnsafeBytes { keyBytes in
                    CCCrypt(
                        CCOperation(kCCEncrypt),
                        CCAlgorithm(kCCAlgorithmAES),
                        options,
                        keyBytes.baseAddress, keyLength,
                        nil,
                        dataBytes.baseAddress, passwordData.count,
                        cryptBytes.baseAddress, cryptLength,
                        &numBytesEncrypted)
                }
            }
        }
        
        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            cryptData.count = numBytesEncrypted
            let encryptedString = cryptData.base64EncodedString()
            completion(encryptedString)
        } else {
            completion(nil)
            SVProgressHUD.dismiss()
        }
    }
    
    
    public func updateUserIPAddressOnPasswordChange(iPAddress: String,  password: String,vc: UIViewController) {
        
        let child = ref.child("serverDetails").child("payload").child("rows")
        
        // Query Firebase to find the server with the specified IP address
        child.queryOrdered(byChild: "ip").queryEqual(toValue: iPAddress).observeSingleEvent(of: .value, with: { snapshot in
            guard let serverSnapshot = snapshot.children.allObjects.first as? DataSnapshot else {
                vc.showAlert(title: "GameVPN", message: "Server with IP address \(iPAddress) not found")
                print("Server with IP address \(iPAddress) not found")
                SVProgressHUD.dismiss()
                return
            }
            
            // Update password in the server object
            if var serverData = serverSnapshot.value as? [String: Any] {
                serverData["password"] = password
                
                // Update the password field in Firebase
                serverSnapshot.ref.updateChildValues(["password": password]) { error, _ in
                    if let error = error {
                        print("Error updating password: \(error.localizedDescription)")
                        vc.showAlert(title: "GameVPN", message: "Error updating password: \(error.localizedDescription)")
                        SVProgressHUD.dismiss()
                    } else {
                        print("Password updated successfully for server with IP \(iPAddress)")
                        vc.showAlert(title: "GameVPN", message: "Password updated successfully for server with IP \(iPAddress)")
                        SVProgressHUD.dismiss()
                    }
                }
            }
        })
    }
    
    func checkAppStatus(completion: @escaping ((Bool,String)->())) {
        ref.child("appInfo").getData(completion: { error, snapshot in
            guard error == nil else {
                print(error!.localizedDescription)
                completion(false, "")
                return;
            }
            
            if snapshot?.exists() ?? false {
                if let value = snapshot?.value as? [String : Any] {
                    if let update = value["inMaintenance"] as? Bool, update{
                        completion(true, "App in maintenace mode")
                    } else if let version = value["appVersion"] as? String{
                        if version >= Constants.AppInfo.currentVersion{
                            completion(true, "Please update the app")
                        } else {
                            completion(false, "")
                        }
                    }else {
                        completion(false, "")
                    }
                }
            } else {
                completion(false, "")
            }
        })
    }
    
    
    func SetNewServerDataToFirebase(country: String,countryCode: String, domain: String,ip: String, password: String, state: String, username: String, vc: UIViewController) {
        
        let rowsRef = ref.child("serverDetails/payload/rows")
        var nextId: Int = 1 // Default starting ID
        // Example: Find the highest ID and increment it
        rowsRef.observeSingleEvent(of: .value) { snapshot in
            if let children = snapshot.children.allObjects as? [DataSnapshot] {
                for child in children {
                    if let id = Int(child.key), id >= nextId {
                        nextId = id + 1
                    }
                }
            }
            
            // Prepare new data with the dynamically calculated ID
            let newData: [String: Any] = [
                "country": country,
                "countryCode": countryCode,
                "createdAt": "\(Date())",
                "deletedAt": "",
                "domain": domain,
                "id": nextId,
                "ip": ip,
                "isAndroid": 1,
                "isIos": 1,
                "isPremium": 1,
                "password": password,
                "state": state,
                "status": 0,
                "type": 0,
                "updatedAt": "\(Date())",
                "username": username
            ]
            
            // Add the new data to Firebase
            let newChildRef = rowsRef.child(String(nextId))
            newChildRef.setValue(newData) { (error, ref) in
                if let error = error {
                    print("Error adding new data: \(error.localizedDescription)")
                    vc.showAlert(title: "GameVPN", message: "\(error.localizedDescription)")
                    SVProgressHUD.dismiss()
                } else {
                    print("New data added successfully!")
                    vc.showAlert(title: "GameVPN", message: "New data added successfully!")
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
}
