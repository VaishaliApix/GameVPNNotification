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
    public func encryptPassword(password: String, iPAddress: String,vc: ViewController, completion: @escaping (String?) -> Void) {
        
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
    
    
    public func updateUserIPAddressOnPasswordChange(iPAddress: String,  password: String,vc: ViewController) {
        var ref: DatabaseReference!
            ref = Database.database().reference()
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
}
