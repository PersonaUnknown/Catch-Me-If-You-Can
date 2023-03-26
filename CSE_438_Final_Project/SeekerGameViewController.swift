//
//  SeekerGameViewController.swift
//  CSE_438_Final_Project
//
//  Created by Daniel Ryu on 11/27/22.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase

class SeekerGameViewController: UIViewController,CLLocationManagerDelegate, MKMapViewDelegate,UIGestureRecognizerDelegate {

    @IBOutlet weak var gameMap: MKMapView!
    @IBOutlet weak var timerValue: UILabel!
    
    @IBOutlet weak var collisionCountLabel: UILabel!
    let locationManager = CLLocationManager()
    let ref = Database.database().reference()
    var current:String?
    var obstacleIndex: Int = 0
    var runner:String? //name of runner
    var timer = Timer()
    var runnerCoor:CLLocationCoordinate2D?
    var currentLoc:CLLocationCoordinate2D?
    var obstacleCollision = [false, false, false, false, false, false, false, false, false, false]
    var collisionCount = 3
    var gameTime:Int?
    var initialTime: Int = 3
    var finished = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = nil; self.navigationItem.setHidesBackButton(true, animated: false);
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
        current = UserDefaults.standard.value(forKey: "username") as? String
        runner = UserDefaults.standard.value(forKey: "runnerName") as? String
        
        gameMap.delegate = self
        gameMap.mapType = .standard
        gameMap.isZoomEnabled = true
        gameMap.isScrollEnabled = true
        gameMap.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
        gameMap.showsUserLocation = true
        gameMap.userLocation.title = "You"
        
        //zooms the map to player's current location.
        if let coor = gameMap.userLocation.location?.coordinate{
            gameMap.setCenter(coor, animated: true)
        }
        
        ref.child("users").child(runner!).observeSingleEvent(of: .value, with: {[self](snapshot) in
            if let dictionary = snapshot.value as? [String:Any]
            {
                let tempGameTime = dictionary["gameTime"] as? String
                let timeArr = tempGameTime!.components(separatedBy: ":")
                gameTime = Int(timeArr[0])!*3600 + Int(timeArr[1])! * 60
                timerValue.text = "Time Left: " + String(gameTime!) + "s"
            }
        })
        
        //timer for revealing enemy location every 5 seconds
        self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: {_ in
            self.updateOpps()
        })
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in
            self.updateTime()
        })
        
        collisionCountLabel.text = "Health Count: 3"
        
        
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "")
        
        switch annotation.title! {
        case "Runner":
            annotationView.markerTintColor = UIColor.blue
            annotationView.glyphImage = UIImage(named: "run")
        default:
            annotationView.glyphImage = UIImage(named: "you")
            
        }
        return annotationView
    }
    func updateOpps(){
       
        //Check for runner location
        ref.child("users").child(runner!).child("currentLocation").observeSingleEvent(of: .value, with: { [self]snapshot in
            var oppLoc = [Double]()
            
            if let locs = snapshot.value as? NSArray{
                for i in 0..<locs.count {
                    oppLoc.append(locs[i] as! Double)
                }
            }
            let allAnnotations = self.gameMap.annotations
            self.gameMap.removeAnnotations(allAnnotations)
            
            //checking if players are in same location from the very beginninig
            if !(oppLoc.count > 0) {
                print("check start1")

                kickPlayers()
                ref.child("games").child(runner!).setValue(2)
                let winMessage1 = UIAlertController(title: "You Win", message:
                    "Mission Complete", preferredStyle: .alert)
                winMessage1.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (alertOKAction) in
                    if self.navigationController != nil {
                        self.navigationController!.popViewController(animated: true)
                    }
                }))
                self.present(winMessage1, animated: true, completion: nil)

                return
            }
            
            
            let coor = CLLocationCoordinate2D(latitude: oppLoc[0] , longitude: oppLoc[1] )
            runnerCoor = coor
            let annotation = MKPointAnnotation() //annotate runner location on map
            annotation.coordinate = coor
            annotation.title = "Runner"
            gameMap.addAnnotation(annotation)
            
            let coor1 = CLLocation(latitude: runnerCoor!.latitude, longitude: runnerCoor!.longitude)
            let coor2 = CLLocation(latitude: currentLoc!.latitude, longitude: currentLoc!.longitude)
            let distance = coor1.distance(from: coor2)
            
            //you catch the runner
            if distance < 5 {
                            
                // check if game has just started
                    print("check start2")
                    kickPlayers()
                    ref.child("games").child(runner!).setValue(2)
                    // send lose game alert message and pop back to welcome vc
                    let winMessage = UIAlertController(title: "You Win", message:
                        "Mission Complete", preferredStyle: .alert)
                    winMessage.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (alertOKAction) in
                        if self.navigationController != nil {
                            self.navigationController!.popViewController(animated: true)
                        }
                    }))
                    self.present(winMessage, animated: true, completion: nil)
                
            }
            
            let midpointX = (coor1.coordinate.latitude + coor2.coordinate.latitude) / 2
            let midpointY = (coor1.coordinate.longitude + coor2.coordinate.longitude) / 2
            let midpoint = CLLocationCoordinate2D(latitude: midpointX, longitude: midpointY)
            let region = MKCoordinateRegion.init(center: midpoint, latitudinalMeters: distance * 2, longitudinalMeters: distance * 2)
            gameMap.setRegion(region, animated: true)
        })
        
        //Check for obstacles
        ref.child("users").child(runner!).child("obstacles").observeSingleEvent(of: .value, with: { [self]snapshot in
            if let locs = snapshot.value as? NSArray{
                let currLoc = CLLocation(latitude: currentLoc!.latitude, longitude: currentLoc!.longitude)
                for i in 0..<locs.count{
                    if obstacleCollision[i] {
                        continue
                    }
                    let temp = locs[i] as! NSArray
                    let tempObstacle = CLLocationCoordinate2D(latitude: temp[0] as! CLLocationDegrees, longitude: temp[1] as! CLLocationDegrees)
                    let tempObstacleLoc = CLLocation(latitude: tempObstacle.latitude, longitude: tempObstacle.longitude)
                    if currLoc.distance(from: tempObstacleLoc) < 10  {
                        obstacleCollision[i] = true //to prevent colliding into same obstacle
                        if collisionCount >= 1
                        {
                            collisionCount -= 1 //keeps track of collisions
                        }
                        collisionCountLabel.text = "Health Count : " + String(collisionCount)
                        if collisionCount <= 0 { //if stepped on more than 3 obstacles
                            
                            kickPlayers()
                            // send lose game alert message and pop back to welcome vc
                            ref.child("games").child(runner!).setValue(1)
                            let loseMessage = UIAlertController(title: "You Lost", message:
                                "Failed to Catch", preferredStyle: .alert)
                            loseMessage.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (alertOKAction) in
                                if self.navigationController != nil {
                                    self.navigationController!.popViewController(animated: true)
                                }
                            }))
                            self.present(loseMessage, animated: true, completion: nil)
                            
                        }
                        else
                        {
                            
                            let alertController = UIAlertController(title: "Boom", message:
                                "Stepped on Obstacle", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                            self.present(alertController, animated: true, completion: nil)
                            
                        }
                    }
                }
            }
        })
    }
    
    func updateTime(){
        if gameTime! <= 0 {
            ref.child("games").child(runner!).setValue(1)
            kickPlayers()
            // send lose game alert message and pop back to welcome vc
            
            let loseMessage = UIAlertController(title: "You Lost", message:
                "Failed to Catch", preferredStyle: .alert)
            loseMessage.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (alertOKAction) in
                if self.navigationController != nil {
                    self.navigationController!.popViewController(animated: true)
                }
            }))
            self.present(loseMessage, animated: true, completion: nil)
            
        }
        else if gameTime! == 1
        {
            gameTime! = 0
        }
        else
        {
            gameTime! -= 1
        }
        timerValue.text = "Time Left: " + String(gameTime!) + "s"
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        currentLoc = locValue
        ref.child("users").child(current!).observeSingleEvent(of: .value, with: {[self](snapshot) in
            if let dictionary = snapshot.value as? [String: Any]
            {
                // Check if user is already logged in
                let inGameStatus = dictionary["inGame"] as! Bool
                if inGameStatus
                {
                    ref.child("users").child(current!).child("currentLocation").observeSingleEvent(of: .value, with: {[self](snapshot) in
                        let newCurrent : [Double] = [locValue.latitude,locValue.longitude]
                        self.ref.child("users").child(self.current!).child("currentLocation").setValue(newCurrent)
                    })
                }
            }
        })
    }
    
    func kickPlayers(){
        ref.child("users").child(current!).updateChildValues(["inGame": false])
        
        // Runner no longer in game
        ref.child("users").child(runner!).updateChildValues(["inGame": false])
        ref.child("users").child(runner!).child("obstacles").removeValue()
        // Tell your friends you no longeer in game
        ref.child("users").child(current!).child("friends").observeSingleEvent(of: .value, with: {[self] (snapshot) in
            if let friendsList = snapshot.value as? [String: [String:Any]]
            {
                for (key, _) in friendsList
                {
                    ref.child("users").child(key).child("friends").child(current!).child("inGame").setValue(false)
                }
            }
        })
        
        // Tell runner's friends they no longer in game
        ref.child("users").child(runner!).child("friends").observeSingleEvent(of: .value, with: {[self] (snapshot) in
            if let friendsList = snapshot.value as? [String: [String:Any]]
            {
                for (key, _) in friendsList
                {
                    ref.child("users").child(key).child("friends").child(runner!).child("inGame").setValue(false)
                }
            }
        })
        
        ref.child("users").child(runner!).child("currentLocation").removeValue()
        ref.child("users").child(current!).child("currentLocation").removeValue()
        
        UserDefaults.standard.set(nil, forKey: "runnerName")//Set runner name to default again.
        timer.invalidate()
    }

}
