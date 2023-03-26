//
//  GameAcceptCell.swift
//  CSE_438_Final_Project
//
//  Created by 이찬 on 11/27/22.
//

import UIKit
import FirebaseDatabase

class GameAcceptCell: UITableViewCell {
    let current = UserDefaults.standard.value(forKey: "username") as? String
    var ref = Database.database().reference()
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var acceptBtn: UIButton!
    
    @IBOutlet weak var declineBtn: UIButton!
    
    @IBAction func acceptGameRequest(_ sender: Any) {
        print("accepting")
        ref.child("users").child(current!).child("gameRequests").observeSingleEvent(of: .value, with: { [self]snapshot in
        if let requestList = snapshot.value as? Dictionary<String,Bool>
        {
            for (key,value) in requestList {
                if(key == self.usernameLabel.text && value == false){
                    print("succeed")
                    self.ref.child("users").child(self.current!).child("gameRequests").child(key).setValue(true)
                    
                    // Set current user status to in-game
                    self.ref.child("users").child(self.current!).child("inGame").setValue(true)
                    
                    // Set the person who invited them to in-game
                    self.ref.child("users").child(self.usernameLabel.text ?? "").child("inGame").setValue(true)
                    
                    // Set status for current user to in-game for all their friends
                    self.ref.child("users").child(self.current!).child("friends").observe(.value, with: { snapshot in
                        
                        if let friendsList = snapshot.value as? [String: [String:Any]]
                        {
                            for (key, _) in friendsList
                            {
                                // Signing out = user logged out and no-longer in game
                                self.ref.child("users").child(key).child("friends").child(self.current!).updateChildValues(["inGame" : true])
                            }
                        }
                        else
                        {
                            // No friends so nothing happens
                        }
                    })
                    
                    // Set status for person who invited to in-game on their friends lists
                    self.ref.child("users").child(self.usernameLabel.text ?? "").child("friends").observe(.value, with: { snapshot in
                        
                        if let friendsList = snapshot.value as? [String: [String:Any]]
                        {
                            for (key, _) in friendsList
                            {
                                // Signing out = user logged out and no-longer in game
                                self.ref.child("users").child(key).child("friends").child(self.usernameLabel.text ?? "").updateChildValues(["inGame" : true])
                            }
                        }
                        else
                        {
                            // No friends so nothing happens
                        }
                    })
                    
                    //Set status for game
                    self.ref.child("games").child(usernameLabel.text!).setValue(0)
                }
            }
        }
        })
        
        UserDefaults.standard.set(usernameLabel.text, forKey: "runnerName")
    }
    
    @IBAction func declineGameRequest(_ sender: Any) {
            
        self.ref.child("users").child(self.current!).child("gameRequests").observeSingleEvent(of: .value, with: {(snapshot) in
                if let requestList = snapshot.value as? Dictionary<String,Bool>{
                    for (key,_) in requestList {
                        if key == self.usernameLabel.text {
                            self.ref.child("users").child(self.current!).child("gameRequests").child(key).removeValue()
                        }
                }
            }
        })
        
        self.ref.child("games").child(usernameLabel.text!).setValue(-2)
    }

}
