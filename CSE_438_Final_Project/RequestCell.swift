//
//  RequestCell.swift
//  CSE_438_Final_Project
//
//  Created by Daniel Ryu on 11/12/22.
//
import UIKit
import FirebaseDatabase

class RequestCell : UITableViewCell{
    let current = UserDefaults.standard.value(forKey: "username") as? String
    let ref = Database.database().reference()
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBAction func acceptFriend(_ sender: Any) {
        print("accept")
        addToFriend(friend: usernameLabel.text!)
        deleteFromFriendRequest(friend: usernameLabel.text!)
        
    }
    
    @IBAction func declineFriend(_ sender: Any) {
        print("decline")
        deleteFromFriendRequest(friend: usernameLabel.text!)
    }
    
    func deleteFromFriendRequest(friend:String){
        ref.child("users").child(current!).child("friendRequests").observe(.value, with: {(snapshot) in
            /**checks for username in friend request dictionary**/
            if let requestList = snapshot.value as? Dictionary<String,String>{
                for (key,_) in requestList {
                    if key == friend {
                        self.ref.child("users").child(self.current!).child("friendRequests").child(key).removeValue()
                    }
                }
            }
        })
    }
    
    func addToFriend(friend:String){
        ref.child("users").child(current!).child("friends").observe(.value, with: { [self](snapshot) in
            // Check if user has a friends list entry in database or if it non-existent
            if snapshot.value is [String:[String:Any]]
            {
                ref.child("users").child(friend).observe(.value, with: {(secondSnapshot) in
                    if let otherUser = secondSnapshot.value as? [String: Any]
                    {
                        let tempInGame = otherUser["inGame"]
                        let tempLoggedIn = otherUser["loggedIn"]
                        
                        // Add to the existing friends list
                        let newFriend: [String:Any] = [
                            "inGame": tempInGame as! Bool,
                            "loggedIn": tempLoggedIn as! Bool,
                        ]
                        self.ref.child("users").child(self.current!).child("friends").child(friend).setValue(newFriend)
                        self.ref.child("users").child(friend).child("friends").child(self.current!).setValue(newFriend)
                    }
                    else{
                        print("otherUser not found")
                    }
                })
            }
            else
            {
                ref.child("users").child(friend).observe(.value, with: {(secondSnapshot) in
                    if let otherUser = secondSnapshot.value as? [String:Any]
                    {
                        let tempInGame = otherUser["inGame"]
                        let tempLoggedIn = otherUser["loggedIn"]
                        
                        let newFriendsList : [String:[String:Bool]] = [
                            friend : [
                                "inGame": tempInGame as! Bool,
                                "loggedIn": tempLoggedIn as! Bool
                            ]
                        ]
                        self.ref.child("users").child(self.current!).child("friends").setValue(newFriendsList)
                    }
                    else{
                        print("otherUser not found")
                    }
                        
                })
                
            }
            
        })
    }
                                                
                                                    
        
}
