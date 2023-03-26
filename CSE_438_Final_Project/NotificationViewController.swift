//
//  NotificationViewController.swift
//  CSE_438_Final_Project
//
//  Created by Daniel Ryu on 11/12/22.
//
import UIKit
import FirebaseDatabase


class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var requestTableView: UITableView!
    
    var current:String!
    var numRequests:Int!
    var requestsArray:[String] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requestsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let request = requestsArray[indexPath.row]
        let requestCell = requestTableView.dequeueReusableCell(withIdentifier: "friendRequestCell") as! RequestCell
        
        requestCell.usernameLabel.text = request
        requestCell.contentView.backgroundColor = UIColor.blue.withAlphaComponent(0.7)
        requestCell.layer.borderWidth = 2.0
        requestCell.layer.borderColor = UIColor.white.cgColor
        requestCell.layer.cornerRadius = 20
        return requestCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestTableView.delegate = self
        requestTableView.dataSource = self
        
        current = UserDefaults.standard.value(forKey: "username") as? String
        let ref = Database.database().reference()
        let postRef = ref
        
        postRef.observe(.childChanged, with: { (snapshot) in
            self.requestTableView.reloadData()
        })
    }
    override func viewDidAppear(_ animated: Bool) {
        requestTableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        current = UserDefaults.standard.value(forKey: "username") as? String
        queryFriendRequest()
    }
    func queryFriendRequest() {
        requestsArray = []
        let ref = Database.database().reference()
        
        ref.child("users").child(current!).child("friendRequests").observe(.value, with: { snapshot in
            if let requestList = snapshot.value as? Dictionary<String,String>
            {
                self.numRequests = requestList.count
                self.requestsArray = []
                for (key,_) in requestList {
                    let tempUser = key
                    
                    self.requestsArray.append(tempUser)
                }
            } else {
                self.requestsArray = []
                self.numRequests = 0
            }
        })
        
        requestTableView.reloadData()
    }
}
