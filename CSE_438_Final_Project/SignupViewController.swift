//
//  SignupViewController.swift
//  CSE_438_Final_Project
//
//  Created by Eric Tabuchi on 11/7/22.
//

import UIKit
import FirebaseDatabase

// This view controller helps users sign up a new account
class SignupViewController: UIViewController {

    // Outlets
    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    // Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

        // Do any additional setup after loading the view.
    }
    
    // Attempt to sign up a new user
    @IBAction func signupAttempt(_ sender: Any) {
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
        }
        
        // Check if user already exists
        let ref = Database.database().reference()
        ref.child("users").child(usernameInput.text!).observe(.value, with: {(snapshot) in
            if snapshot.value is [String: Any]
            {
                // Username already exists
                let alertController = UIAlertController(title: "Login Failed", message:
                    "Username Already Exists", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                self.present(alertController, animated: true, completion: nil)
            }
            else
            {
                // New user format (Example):
                // user: [
                //  "friends": [
                //    "0": friendName
                //  ]
                //  "pass": password,
                //  "loggedIn": false,
                //  "inGame": false
                // ]
                // Each user has a password and a state determining if they are
                // logged in or not to prevent multiple users from logging into
                // the same account, if they are in-game or not
                // Setting "friends" to [] won't make it show up on the database
                // so you can check if a user has no friends like so:
    
                // let dictionary = snapshot.value as? [String: Any]
                // A user will no have friends if dictionary["friends"] is nil
                
                // Create new user otherwise
                let newUser : [String: Any] = [
                    "pass": self.passwordInput.text!,
                    "loggedIn": false,
                    "inGame": false
                ]
                
                ref.child("users").child(self.usernameInput.text!).setValue(newUser)
                
                // Username already exists
                let alertController = UIAlertController(title: "User Created", message: "Welcome \(self.usernameInput.text!)", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                self.present(alertController, animated: true, completion: nil)
                
                // Clear input fields
                self.usernameInput.text! = ""
                self.passwordInput.text! = ""
            }
        })
    }
}
