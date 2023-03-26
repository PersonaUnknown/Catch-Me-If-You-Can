//
//  GameViewController.swift
//  CSE_438_Final_Project
//
//  Created by Daniel Ryu on 11/18/22.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase

class GameViewController: UIViewController,CLLocationManagerDelegate, MKMapViewDelegate,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var gameMap: MKMapView!
    
    let locationManager = CLLocationManager()
    let ref = Database.database().reference()
    var current:String?
    var obstacleIndex: Int = 0
    var userTrace:[CLLocationCoordinate2D] = []
    
    @IBOutlet weak var timerCountLabel: UILabel!
    @IBOutlet weak var obstacleCountLabel: UILabel!
    var gameTime: String?
    var numObstacles: Int?
    var secondLeft: Int?
    var timer = Timer()
    var seeker = UserDefaults.standard.value(forKey: "seeker") as? String
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.blue.withAlphaComponent(0.9)

        self.locationManager.requestWhenInUseAuthorization()
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.setHidesBackButton(true, animated: false);
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
        
        gameMap.delegate = self
        gameMap.mapType = .standard
        gameMap.isZoomEnabled = true
        gameMap.isScrollEnabled = true
        gameMap.showsUserLocation = true
        gameMap.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
        
        //zooms the map to player's current location.
        if let coor = gameMap.userLocation.location?.coordinate{
            gameMap.setCenter(coor, animated: true)
        }
        
        //allows map to recognize obstacles being added by taps
        let gestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(handleTap))
        gestureRecognizer.delegate = self
        gameMap.addGestureRecognizer(gestureRecognizer)
        
        //Print Timer
        let timeArr = gameTime!.components(separatedBy: ":")
        secondLeft = Int(timeArr[0])!*3600 + Int(timeArr[1])! * 60
        timerCountLabel.text = "Time Left: " + String(secondLeft!) + "s"
        obstacleCountLabel.text = "Remaining Obstacles: " + String(numObstacles!)
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in
            self.updateTime()
        })
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = CustomAnnotation(annotation: annotation, reuseIdentifier: "")
        
        switch annotation.title! {
        case "Obstacle":
            annotationView.markerTintColor = UIColor.blue
            annotationView.glyphImage = UIImage(named: "bomb")
        default:
            annotationView.glyphImage = UIImage(named: "you")
            
        }
        return annotationView
    }
    
    func updateTime(){
        
        ref.child("games").observeSingleEvent(of: .value, with: {[self](snapshot) in
            if let dictionary = snapshot.value as? [String:Any]
            {
                let curr = dictionary[current!] as? Int
                switch curr
                {
                case -2:
                    ref.child("games").child(current!).removeValue()
                    UserDefaults.standard.set(nil, forKey: "seeker")
                    let declineMessage = UIAlertController(title: "Declined", message:
                        "The Other Player Declined the Game", preferredStyle: .alert)
                    declineMessage.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (alertOKAction) in
                        if self.navigationController != nil
                        {
                            self.navigationController!.popViewController(animated: true)
                        }}))
                    self.present(declineMessage, animated: true, completion: nil)
                    break
                case -1: //other player
                    break
                case 0: //in game
                    //check if runner wins by time running out
                    if secondLeft! <= 0 {
                        ref.child("games").child(current!).setValue(1)
                    }
                    secondLeft! -= 1
                    timerCountLabel.text = "Time Left: " + String(secondLeft!) + "s"
                    break
                case 1: //runner wins
                    ref.child("games").child(current!).removeValue()
                    timer.invalidate()
                    UserDefaults.standard.set(nil, forKey: "seeker")
                    let winMessage = UIAlertController(title: "You Win", message:
                        "Got Away!", preferredStyle: .alert)
                    winMessage.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (alertOKAction) in
                        if self.navigationController != nil
                        {
                            self.navigationController!.popViewController(animated: true)
                        }}))
                    self.present(winMessage, animated: true, completion: nil)
                    break
                    
                case 2: //runner loses
                    UserDefaults.standard.set(nil, forKey: "seeker")
                    ref.child("games").child(current!).removeValue()
                    timer.invalidate()
                    let loseMessage = UIAlertController(title: "You Lose", message:
                        "Dead", preferredStyle: .alert)
                    loseMessage.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (alertOKAction) in
                        if self.navigationController != nil
                        {
                            self.navigationController!.popViewController(animated: true)
                        }
                    }))
                    self.present(loseMessage, animated: true, completion: nil)
                    break
                default:
                    break
                }
            }
        })
    }
    
    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer){
        let location = gestureRecognizer.location(in: gameMap)
        let coordinate = gameMap.convert(location, toCoordinateFrom: gameMap)
        let count = addObstacle(obstacle: coordinate)
//        print("Count: ", count)
        
        if (count > numObstacles! - 1){
            let alertController = UIAlertController(title: "Too Many Obstacles", message:
                "You can't have more than \(numObstacles!) obstacles!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "Obstacle"
            gameMap.addAnnotation(annotation)
            obstacleCountLabel.text = "Remaining Obstacles: " + String(numObstacles! - count - 1)
        }
    }
    
    func addObstacle(obstacle: CLLocationCoordinate2D) -> Int {
        let latitude = obstacle.latitude
        let longitude = obstacle.longitude
        let coor = [latitude,longitude]
        
        if (obstacleIndex < numObstacles!) {
            ref.child("users").child(current!).child("obstacles").observeSingleEvent(of: .value, with: {[self](snapshot) in
                
                let newCoor: [Double] = coor
                self.ref.child("users").child(self.current!).child("obstacles").child(String(obstacleIndex)).setValue(newCoor)
                obstacleIndex += 1
//                print(obstacleIndex)
            })
        }
        return obstacleIndex
    }
                                                                      
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        userTrace.append(locValue)
//        print("\(locValue.latitude)" + " " + "\(locValue.longitude)")
        gameMap.mapType = MKMapType.standard
        
        ref.child("users").child(current!).child("currentLocation").observeSingleEvent(of: .value, with: {[self](snapshot) in
            let newCurrent : [Double] = [locValue.latitude,locValue.longitude]
            self.ref.child("users").child(self.current!).child("currentLocation").setValue(newCurrent)
        })
        
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: locValue, span: span)
        gameMap.setRegion(region, animated: true)
        
    }
}
