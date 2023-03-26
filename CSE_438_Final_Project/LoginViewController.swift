//
//  LoginViewController.swift
//  CSE_438_Final_Project
//
//  Created by Eric Tabuchi on 11/6/22.
//
import UIKit
import FirebaseDatabase

// This view controller helps users log in
class LoginViewController: UIViewController {

    // Outlets
    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    //This is Debug function to help with adding friends to game
//    @IBAction func queryfriends(_ sender: Any) {
//        print("hello")
//        let debugName = "newuser"
//        let ref = Database.database().reference()
//        ref.child("users").child(debugName).child("friends").observe(.value, with: { snapshot in
//            if let x = snapshot.value as? Dictionary<String,Bool>
//            {
//                for (key,value) in x {
//                    print(key)
//                }
//            }
//            else {
//                // No friends in database so add friend instead
//                let friend: [String:Bool] = [
//                    "gary":false
//                ]
//
//                ref.child("users").child(debugName).child("friends").setValue(friend)
//                print("you're ")
//            }
//        })
//
//    }
    
    // Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        usernameInput.text! = ""
        passwordInput.text! = ""
        
        // Check if user is already logged in
        if let loggedIn = UserDefaults.standard.value(forKey: "loggedIn"), let username = UserDefaults.standard.value(forKey: "username")
        {
            if loggedIn as! Bool
            {
                // User appears to be logged in so check if username still exists in database
                
                // Debug Message
//                print(String(describing: username))
                
                let ref = Database.database().reference()
                ref.child("users").child(String(describing: username)).observeSingleEvent(of: .value, with: {(snapshot) in
                    
                    if snapshot.value is [String: Any]
                    {
                        // User exists and you are logged in
                        let welcomeScreen = self.storyboard?.instantiateViewController(withIdentifier: "welcomeScreen") as? WelcomeViewController
                        
                        self.navigationController!.pushViewController(welcomeScreen!, animated: false)
                    }
                    else
                    {
                        // Else user does not exist anymore so force sign out
                        self.forceSignOut()
                    }
                })
            }
            else
            {
                
            }
        }
        
        // Else user is not logged in so you stay on this view controller
    }
    
    func forceSignOut()
    {
        let defaults = UserDefaults.standard
        defaults.set(nil, forKey: "loggedIn")
        defaults.set(nil, forKey: "username")
    }
    
    // Attempts to login user
    @IBAction func loginAttempt(_ sender: Any) {
        // Check username field
        if let username = usernameInput.text
        {
            if username.isEmpty
            {
                let alertController = UIAlertController(title: "Login Failed", message:
                    "Username Cannot Be Empty", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            else if username.contains(" ")
            {
                let alertController = UIAlertController(title: "Login Failed", message:
                    "Username Cannot Have Spaces", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
        }
        else
        {
            print("Username Input Field Does Not Exist")
            return
        }
        
        // Check password field
        if let password = passwordInput.text
        {
            if password.isEmpty
            {
                let alertController = UIAlertController(title: "Login Failed", message:
                    "Password Cannot Be Empty", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            else if password.contains(" ")
            {
                let alertController = UIAlertController(title: "Login Failed", message:
                    "Password Cannot Have Spaces", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
        }
        else
        {
            print("Password Input Field Does Not Exist")
            return
        }
        
        // If username and password are valid inputs, check database
        let ref = Database.database().reference()
        ref.child("users").child(usernameInput.text!).observeSingleEvent(of: .value, with: { [self](snapshot) in
            
            if let dictionary = snapshot.value as? [String: Any]
            {
                // Check if user is already logged in
                let loggedInStatus = dictionary["loggedIn"] as! Bool
                if loggedInStatus || self.passwordInput.text == "" || self.usernameInput.text == ""
                {
                    // Reject login attempt
                    let alertController = UIAlertController(title: "Login Failed", message:
                        "User Already Logged In Elsewhere", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                else
                {
                    let password = dictionary["pass"] as! String
                    if self.passwordInput.text! != password
                    {
                        let alertController = UIAlertController(title: "Login Failed", message:
                            "Invalid Username or Password", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                        self.present(alertController, animated: true, completion: nil)
                        return
                    }
                    else
                    {
                        UserDefaults.standard.set(true, forKey: "loggedIn")
                        UserDefaults.standard.set(self.usernameInput.text!, forKey: "username")
                        // Tell users friends that they are logging in
                        if let username = UserDefaults.standard.value(forKey: "username") as? String
                        {
                            ref.child("users").child(username).child("friends").observeSingleEvent(of: .value, with: {(snapshot) in
                                
                                if let friendsList = snapshot.value as? [String: [String:Any]]
                                {
                                    for (key, _) in friendsList
                                    {
//                                        print(self.usernameInput.text!)
                                        // Signing out = user logged out and no-longer in game
                                        ref.child("users").child(key).child("friends").child(username).child("loggedIn").setValue(false)
                                        ref.child("users").child(key).child("friends").child(username).child("inGame").setValue(false)
                                    }
                                }
                                else
                                {
                                    // No friends so nothing happens
                                }
                            })
                        }
                        // Send user to welcome screen
                        ref.child("users").child(self.usernameInput.text!).updateChildValues(["loggedIn": true])
                        ref.child("users").child(self.usernameInput.text!).updateChildValues(["inGame": false])
                        
                        self.usernameInput.text! = ""
                        self.passwordInput.text! = ""
                        
                        let welcomeScreen = self.storyboard?.instantiateViewController(withIdentifier: "welcomeScreen") as? WelcomeViewController
                        
                        self.navigationController!.pushViewController(welcomeScreen!, animated: true)
                    }
                }
            }
            else
            {
                let alertController = UIAlertController(title: "Login Failed", message:
                    "Invalid Username or Password", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                self.present(alertController, animated: true, completion: nil)
            }
        })
    }
}
