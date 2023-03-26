//
//  RequestCell.swift
//  CSE_438_Final_Project
//
//  Created by Daniel Ryu on 11/12/22.
//
import UIKit
import FirebaseDatabase

class GameRequestCell : UITableViewCell{

    @IBOutlet weak var requestBtn: CustomRequestButton!
    @IBOutlet weak var usernameLabel: UILabel!
    
    let current = UserDefaults.standard.value(forKey: "username") as? String
    let ref = Database.database().reference()
    
    @IBAction func requestGame(_ sender: Any) {
//        ref.child("users").child(usernameLabel.text ?? "").child("gameRequests").setValue([current:false])
        UserDefaults.standard.set(usernameLabel.text, forKey: "seeker")
    }

}
