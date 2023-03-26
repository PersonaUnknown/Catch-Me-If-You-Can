//
//  AddFriendViewController.swift
//  CSE_438_Final_Project
//
//  Created by Daniel Ryu on 11/12/22.
//

import UIKit
import FirebaseDatabase

class AddFriendViewController: UIViewController, UISearchBarDelegate,  UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        newFriendArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel!.text = newFriend
        button.frame = CGRect(x: 250, y: 10, width: 70, height: 20)
        button.backgroundColor = .blue
        button.setTitle("Invite", for: .normal)
        button.addTarget(self, action: #selector(inviteFriend), for: .touchUpInside)
        addFriendTableView.addSubview(button)
        return cell
    }
    
    @objc func inviteFriend() {
        let ref = Database.database().reference()
        
        // Check if you already have that person friended, else alert them the mistake
        if let currUsername = UserDefaults.standard.value(forKey: "username")
        {
            // Check if you already sent an invite to that person, else alert them the mistake
            ref.child("users").child(newFriend).child("friendRequests").observeSingleEvent(of: .value, with: {[self](snapshot) in
                if let friendRequests = snapshot.value as? [String: Any]
                {
                    // Check friend request list if you already sent them one
                    for (request, _) in friendRequests
                    {
                        if request == currUsername as! String
                        {
                            let alertController = UIAlertController(title: "Invite Fail", message:
                                "Already sent an invite", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
                else
                {
                    // No request made so continue onward
                }
            })
            
            ref.child("users").child(currUsername as! String).child("friends").observeSingleEvent(of: .value, with: { [self](snapshot) in
                if let friendsList = snapshot.value as? [String: [String:Any]]
                {
                    var friendExists = false
                    for (key, _) in friendsList
                    {
                        // User already has this person friended
                        if key == newFriend
                        {
                            friendExists = true
                            let alertController = UIAlertController(title: "Invite Fail", message:
                                "Already friends with this user", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                            self.present(alertController, animated: true, completion: nil)
                            break
                        }
                    }
                    
                    if !friendExists
                    {
                        let alertController = UIAlertController(title: "Invite Successful", message:
                            "Invite sent to \(newFriend)", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                        self.present(alertController, animated: true, completion: nil)
                        
                        ref.child("users").child(newFriend).child("friendRequests").setValue([currentUser:""])
                    }
                }
                else
                {
                    // No friends
                    let alertController = UIAlertController(title: "Invite Successful", message:
                        "Invite sent to \(newFriend)", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                    self.present(alertController, animated: true, completion: nil)
                    
                    ref.child("users").child(newFriend).child("friendRequests").setValue([currentUser:""])
                }
            })
        }
    }
    
    var newFriendArray:[String] = []
    var newFriend:String = ""
    var currentUser:String = UserDefaults.standard.value(forKey: "username") as! String
    var button:UIButton = UIButton()
    
    @IBOutlet weak var addFriendTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

        
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        setUpTableView()
        // Do any additional setup after loading the view.
    }
    
    func setUpTableView() {
        addFriendTableView.dataSource = self
        addFriendTableView.delegate = self
        addFriendTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let searchedWord:String = searchBar.text ?? ""
        
        let ref = Database.database().reference()
        ref.child("users").child(searchedWord).observe(.value, with: {
            snapshot in
            if(snapshot.exists()){
                self.newFriendArray = []
                print(searchedWord)
                self.newFriend = searchedWord
                self.newFriendArray.append(searchedWord)
                self.addFriendTableView.reloadData()
            }
            else{
                let alert = UIAlertController(title: "alert", message: "We couldn't find such username. Please try again.", preferredStyle: .alert)
                
                // Create OK button with action handler
                let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                    print("Ok button tapped")
                 })
                
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
