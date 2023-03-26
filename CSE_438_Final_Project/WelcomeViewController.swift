//
//  WelcomeViewController.swift
//  CSE_438_Final_Project
//
//  Created by Eric Tabuchi on 11/7/22.
//
import UIKit
import FirebaseDatabase

// This view controller is what a logged in user sees by default
class WelcomeViewController: UIViewController {
    // Outlets
    @IBOutlet weak var welcomeMessage: UILabel!
    @IBOutlet weak var joinGameBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.setHidesBackButton(true, animated: false);
        checkInGame()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Check if user is logged in
        if let loggedIn = UserDefaults.standard.value(forKey: "loggedIn"), let username = UserDefaults.standard.value(forKey: "username")
        {
            if loggedIn as! Bool
            {
                // Logged in
                welcomeMessage.text = "Welcome " + String(describing: username) + "!"
            }
        }
        checkInGame()
    }
    
    func checkInGame() {
        let ref = Database.database().reference()
        let username = UserDefaults.standard.value(forKey: "username") as? String ?? ""
        ref.child("users").child(username).observe(.value, with: {
            snapshot in
            if let allValues = snapshot.value as? [String:Any] {
                let inGame = allValues["inGame"] as? Bool
                if(inGame == true){
                    self.joinGameBtn.isHidden = false
                }
                else{
                    self.joinGameBtn.isHidden = true
                }
            }
        })
    }
    
    //join a game if user is in game
    @IBAction func joinCurrentGame(_ sender: Any) {
        let username = UserDefaults.standard.value(forKey: "username") as? String
        let runner = UserDefaults.standard.value(forKey: "runnerName") as? String
        if(username == runner){
            //user is runner
            let runnerScreen = self.storyboard?.instantiateViewController(withIdentifier: "gameScreen") as? GameViewController

            runnerScreen?.current = UserDefaults.standard.value(forKey: "username") as? String

            self.navigationController!.pushViewController(runnerScreen!, animated: true)
        }
        else if(username != runner){
            print("i am seeker")
            //user is seeker
            let seekerScreen = self.storyboard?.instantiateViewController(withIdentifier: "seekerGameScreen") as? SeekerGameViewController

            self.navigationController!.pushViewController(seekerScreen!, animated: true)
        }
    }
    
    // Signs out user
    @IBAction func signOutUser(_ sender: Any) {
        let ref = Database.database().reference()
        let username = UserDefaults.standard.value(forKey: "username")
        ref.child("users").child(username! as! String).updateChildValues(["loggedIn": false])
        let defaults = UserDefaults.standard
        defaults.set(nil, forKey: "loggedIn")
        defaults.set(nil, forKey: "username")
        defaults.set(nil, forKey: "seeker")
        // Check all friends user has and "sign" out of their friends list (change display status to offline)
        ref.child("users").child(username! as! String).child("friends").observe(.value, with: { snapshot in
            
            if let friendsList = snapshot.value as? [String: [String:Any]]
            {
                for (key, _) in friendsList
                {
                    // Signing out = user logged out and no-longer in game
                    ref.child("users").child(key).child("friends").child(username! as! String).updateChildValues(["loggedIn" : false])
                    ref.child("users").child(key).child("friends").child(username! as! String).updateChildValues(["inGame" : false])
                    ref.child("users").child(key).child("gameRequests").child(username! as! String).removeValue()
                }
            }
            else
            {
                // No friends so nothing happens
            }
        })
        
        ref.child("games").child(username! as! String).removeValue()
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func showGameRequests(_ sender: Any) {
        let gameRequestScreen = self.storyboard?.instantiateViewController(withIdentifier: "gameRequestScreen") as? GameRequestViewController
        
        gameRequestScreen?.current = UserDefaults.standard.value(forKey: "username") as? String

        self.navigationController!.pushViewController(gameRequestScreen!, animated: true)
    }
    
    @IBAction func showFriends(_ sender: Any) {
        let friendScreen = self.storyboard?.instantiateViewController(withIdentifier: "friendScreen") as? FriendListViewController
        
        friendScreen?.current = UserDefaults.standard.value(forKey: "username") as? String
        
        self.navigationController!.pushViewController(friendScreen!, animated: true)
    }
    @IBAction func showGame(_ sender: Any) {

        let createGameScreen = self.storyboard?.instantiateViewController(withIdentifier: "createGameScreen") as? CreateGameViewController
        
        createGameScreen?.current = UserDefaults.standard.value(forKey: "username") as? String
        self.navigationController!.pushViewController(createGameScreen!, animated: true)
    }
}
