//
//  FriendListViewController.swift
//  CSE_438_Final_Project
//
//  Created by Daniel Ryu on 11/12/22.
//
import UIKit
import FirebaseDatabase

class FriendListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var friendsListTable: UITableView!
    
    let cellSpacingHeight: CGFloat = 5
    var current:String!
    var numFriends:Int!
    var friendsArray:[User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendsListTable.delegate = self
        friendsListTable.dataSource = self
        let ref = Database.database().reference()
        ref.observe(.childChanged, with: { (snapshot) in
            self.friendsListTable.reloadData()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.friendsListTable.rowHeight = 50
        queryfriends()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        friendsListTable.reloadData()
    }
    /**
            json structure examplee for writing into database
            { key, value }
             key = username  <-- (string)
             value = {"loggedIn": true, "inGame": true}   <-- (object)
     */
    func queryfriends() {
        let ref = Database.database().reference()
        ref.child("users").child(current!).child("friends").observe(.value, with: { snapshot in
            
            if let friendsList = snapshot.value as? [String: [String:Any]]
            {
                self.friendsArray = []
                self.numFriends = friendsList.count
                for (key, value) in friendsList {
                    let tempUser = User(username: key, loggedIn: value["loggedIn"] as? Bool, inGame: value["inGame"] as? Bool)
                    self.friendsArray.append(tempUser)
                }
            } else {
                self.friendsArray = []
                self.numFriends = 0
            }
        })
        
        friendsListTable.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let friend = friendsArray[indexPath.row]
        let friendCell = friendsListTable.dequeueReusableCell(withIdentifier: "friendCell") as! FriendCell
        friendCell.contentView.backgroundColor = UIColor.blue.withAlphaComponent(0.7)
        friendCell.layer.borderWidth = 2.0
        friendCell.layer.borderColor = UIColor.white.cgColor
        friendCell.layer.cornerRadius = 20
        friendCell.friendUsername.text = friend.username
        if(friend.inGame){
            friendCell.friendInGame.text = "In-Game"
        } else if (friend.loggedIn){
            friendCell.friendInGame.text = "Online"
        } else {
            friendCell.friendInGame.text = "Offline"
        }

        return friendCell
    }
    
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return friendsArray.count
    }
}
