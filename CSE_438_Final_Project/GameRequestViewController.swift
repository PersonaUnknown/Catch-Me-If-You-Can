//
//  GameRequestViewController.swift
//  CSE_438_Final_Project
//
//  Created by 이찬 on 11/27/22.
//

import UIKit
import FirebaseDatabase
class GameRequestViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var allRequestsTableView: UITableView!
    var current:String!
    var numRequests:Int!
    var requestsArray:[String] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requestsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let friendName = requestsArray[indexPath.row]
        let requestCell = allRequestsTableView.dequeueReusableCell(withIdentifier: "GameAcceptCell") as! GameAcceptCell
        
        requestCell.usernameLabel.text = friendName
        requestCell.contentView.backgroundColor = UIColor.blue.withAlphaComponent(0.7)
        requestCell.layer.borderWidth = 2.0
        requestCell.layer.borderColor = UIColor.white.cgColor
        requestCell.layer.cornerRadius = 20
        
        return requestCell
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.allRequestsTableView.rowHeight = 50
        allRequestsTableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        current = UserDefaults.standard.value(forKey: "username") as? String
        getAllGameRequests()
    }
    
    func getAllGameRequests() {
        requestsArray = []
        let ref = Database.database().reference()
        ref.child("users").child(current!).child("gameRequests").observe(.value, with: { snapshot in
            if let requestList = snapshot.value as? Dictionary<String,Bool>
            {
                self.numRequests = requestList.count
                self.requestsArray = []
                for (key,value) in requestList {
                    print("key" , key)
                    print("value", value)
                    if(value == false){
                        self.requestsArray.append(key)
                    }
                }
            } else {
                self.requestsArray = []
                self.numRequests = 0
            }
        })

        allRequestsTableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        allRequestsTableView.delegate = self
        allRequestsTableView.dataSource = self
        let ref = Database.database().reference()
        ref.observe(.childChanged, with:{
            (snapshot) in self.allRequestsTableView.reloadData()
        })
        // Do any additional setup after loading the view.
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
