//
//  CreateGameViewController.swift
//  CSE_438_Final_Project
//
//  Created by 이찬 on 11/26/22.
//

import UIKit
import FirebaseDatabase
extension UserDefaults {
    @objc dynamic var seeker: String {
        return string(forKey: "seeker") ?? ""
    }
}

class CreateGameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var current:String!
    var numFriends:Int!
    var friendsArray:[User] = []
    var friendsNameArray:[String] = []
    var requestBtn:UIButton = UIButton()
    let cellSpacingHeight: CGFloat = 5.0
    var friendName:String = ""
    let ref = Database.database().reference()
    var timer = Timer()
    let timePicker = UIDatePicker()

    var udObservation: NSKeyValueObservation?
    var seekerNamePrint = ""
    
    @IBOutlet weak var allFriendsTableView: UITableView!
    @IBOutlet weak var seekerName: UILabel!

    @IBOutlet weak var gameTime: UITextField!
    @IBOutlet weak var numObstacles: UITextField!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        friendName = friendsNameArray[indexPath.row]
        let requestCell = allFriendsTableView.dequeueReusableCell(withIdentifier: "GameRequestCell") as! GameRequestCell
        requestCell.usernameLabel.text = friendName

        requestCell.requestBtn.tag = indexPath.row
        requestCell.backgroundColor = UIColor.blue.withAlphaComponent(0.7)
        requestCell.layer.borderWidth = 2.0
        requestCell.layer.borderColor = UIColor.white.cgColor
        requestCell.layer.cornerRadius = 20
        return requestCell
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFriends()
            }

    override func viewDidAppear(_ animated: Bool) {
//        seeker = UserDefaults.standard.value(forKey: "seeker") as? String ?? ""
//        seekerName.text = "Seeker: " + seeker
        allFriendsTableView.reloadData()
        self.allFriendsTableView.rowHeight = 50
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

        timeSelector(timePicker: timePicker)
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [weak self] _ in
            self?.datePickerValueChanged(self?.timePicker)
                })
        
        allFriendsTableView.delegate = self
        allFriendsTableView.dataSource = self
        let ref = Database.database().reference()
        ref.observe(.childChanged, with:{
            (snapshot) in self.allFriendsTableView.reloadData()
        })
        
        udObservation = UserDefaults.standard.observe(\.seeker, options: [.initial, .new])
        { (defaults, change) in
            self.seekerNamePrint = UserDefaults.standard.value(forKey: "seeker") as? String ?? ""
            self.seekerName.text = "Seeker: " + self.seekerNamePrint
        }
    }
    
    
    
    func getFriends() {
        let ref = Database.database().reference()
        ref.child("users").child(current!).child("friends").observe(.value, with: { snapshot in
            
            if let friendsList = snapshot.value as? [String: [String:Any]]
            {
                self.friendsArray = []
                self.numFriends = friendsList.count
                for (key, value) in friendsList {
                    let tempUser = User(username: key, loggedIn: value["loggedIn"] as? Bool, inGame: value["inGame"] as? Bool)
                    self.friendsArray.append(tempUser)
                    self.friendsNameArray.append(key)
                }
            } else {
                self.friendsArray = []
                self.numFriends = 0
            }
        })
        
        allFriendsTableView.reloadData()
        
    }
    
    @IBAction func showGame(_ sender: Any) {
        let gameScreen = self.storyboard?.instantiateViewController(withIdentifier: "gameScreen") as? GameViewController
        
        // check user inputs for game time and number of obstacles
        if let numObsPass = Int(numObstacles.text!) {
            if numObsPass > 10
            {
                let alertController = UIAlertController(title: "Too Many Obstacles", message:
                    "Please select up to 10 Obstacles", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                self.present(alertController, animated: true, completion: nil)
            }
            else if gameTime.text == "00:00" {
                let alertController = UIAlertController(title: "Time input empty", message:
                    "Please select game length", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                self.present(alertController, animated: true, completion: nil)
            }
            else {
                if seekerNamePrint == ""
                {
                    // Can't start game
                    let alertController = UIAlertController(title: "No Seeker", message:
                        "Select a seeker or get friends", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                    self.present(alertController, animated: true, completion: nil)
                }
                else
                {
                    // Send invite and start game
                   
                    ref.child("users").child(seekerNamePrint).child("gameRequests").setValue([current:false])
                    ref.child("users").child(current).child("gameRequests").setValue([seekerNamePrint:false])

                    gameScreen?.numObstacles = numObsPass
                    gameScreen?.gameTime = gameTime.text
                    gameScreen?.current = UserDefaults.standard.value(forKey: "username") as? String
                    ref.child("games").child(current!).setValue(-1) //create game
                    self.navigationController!.pushViewController(gameScreen!, animated: true)
                }
            }
        }
        else {
            let alertController = UIAlertController(title: "Wrong obstacle type", message:
                "Please provide valid number of obstacles", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // prompt users to select time limit for the game
    func timeSelector (timePicker: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_FR")
        formatter.dateFormat = "HH:mm"
        gameTime.text = "00:00"
//        gameTime.textColor = .link
        
        timePicker.datePickerMode = .countDownTimer
        timePicker.addTarget(self, action: #selector(timePickerValueChanged(sender:)), for: .valueChanged)
        timePicker.frame.size = CGSize(width: 0, height: 250)
        gameTime.inputView = timePicker
        gameTime.inputAccessoryView = createToolbar(timePicker: timePicker)
    }
    
    func createToolbar(timePicker: UIDatePicker) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: true)
        
        return toolbar
    }
    
    @objc func timePickerValueChanged(sender: UIDatePicker){
        
        let seconds = sender.countDownDuration
        print(seconds)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_gb")
        formatter.dateFormat = "HH:mm"
        gameTime.text = formatter.string(from: sender.date)
        ref.child("users").child(current!).child("gameTime").setValue(gameTime.text!)
    }
    
    @objc func donePressed(){
        self.view.endEditing(true)
    }
    
    func datePickerValueChanged(_ sender: UIDatePicker?) {
        let selectedValue: TimeInterval
//        print("sender: \(String(describing: sender))")
//        if let sender = sender {
//            // Called by UIKit, UIDatePicker works, we no longer need the timer
//            timer.invalidate()
//            selectedValue = sender.countDownDuration
//       } else {
//           // Called by the timer, read the current value of the datePicker, because it's accurate, only the `.valueChanged` event is not fired
//           selectedValue = timePicker.countDownDuration
//       }
        selectedValue = timePicker.countDownDuration
        var hour = ""
        var min = ""
        let h = Int(selectedValue) / 3600
        let m = (Int(selectedValue) % 3600) / 60
        
        if h < 10 {
            hour = "0\(h)"
        }
        else {
            hour = "\(h)"
        }
        if m < 10 {
            min = "0\(m)"
        }
        else {
            min = "\(m)"
        }
        
        let timeString = hour + ":" + min
        print("Selected value \(timeString)")
        gameTime.text = timeString
    }

    
    
    @IBAction func requestGame(_ sender: UIButton) {
        let sentFriend = friendsNameArray[sender.tag]
                
                self.ref.child("users").child(sentFriend).child("gameRequests").setValue([self.current:false])
                UserDefaults.standard.set(sentFriend, forKey: "seeker")
                
                self.ref.child("users").child(self.current!).child("gameRequests").setValue([sentFriend:false])
                
                let alertController = UIAlertController(title: "Request Successful", message:
                                                            "Request sent to " + (sentFriend), preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(alertController, animated: true, completion: nil)
        }

}
