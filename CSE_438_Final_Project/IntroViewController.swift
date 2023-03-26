//
//  IntroViewController.swift
//  CSE_438_Final_Project
//
//  Created by 이찬 on 12/1/22.
//

import UIKit

class IntroViewController: UIViewController {
    
    @IBOutlet weak var toIntroBtn: CustomButtons!
    @IBOutlet weak var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let hover = UIHoverGestureRecognizer(target: self, action: #selector(hovering(_:)))
        toIntroBtn.addGestureRecognizer(hover)
    }
    
    @objc func hovering(_ recognizer: UIHoverGestureRecognizer) {
           switch recognizer.state {
           case .began, .changed:
               print("asfasf")
               toIntroBtn.titleLabel?.textColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
           case .ended:
               print("slkajk")
               toIntroBtn.titleLabel?.textColor = UIColor.link
           default:
               break
           }
       }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.titleLabel.font = UIFont(name: "GillSans-Italic", size: 50)
        self.toIntroBtn.titleLabel?.font =  UIFont(name: "GillSans-Italic", size: 50)
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        self.view.backgroundColor = UIColor.tintColor
    }
    
    
    @IBAction func playBtn(_ sender: Any) {
        let loginScreen = self.storyboard?.instantiateViewController(withIdentifier: "loginScreen") as? LoginViewController
        
        self.navigationController!.pushViewController(loginScreen!, animated: true)
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
