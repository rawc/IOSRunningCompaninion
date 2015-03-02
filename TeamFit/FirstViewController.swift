//
//  FirstViewController.swift
//  TeamFit
//
//  Created by Louis Chatta
//  Copyright (c) 2015 TeamFit. All rights reserved.
//
import UIKit
import CoreLocation
import MapKit
import CoreMotion

class FirstViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var runSwitch: UISwitch!
    
    @IBOutlet weak var distanceTraveledLabel: UILabel!
    @IBOutlet weak var topSpeedLabel: UILabel!
    @IBOutlet weak var lapNuberLabel: UILabel!
    @IBOutlet weak var mphLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var previousDistance: UILabel!
    @IBOutlet weak var totalDistanceLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    
    var  calibrationCompleted = false
    var locationManager: CLLocationManager?

    var  locationStack: [String] = []
    var  startTime = NSTimeInterval()
    var  firstLocation = CLLocation()
    var  speedStack = NSMutableArray()
    var  latitude = ""
    var  longitude = ""
    var  time = 0
    var  distanceTraveled = 0
    var  calibration = false
    var  doOnce = false
    var  once = false
    var  cameToaStop = false
    var  previousRun = 0.0
    var  totalDistance = 0.0
    
    func getVelocity(start: Bool){
        if start == false{
            locationManager?.stopUpdatingLocation();
            print("location is fin\n")
        }
        else{
            locationManager?.startUpdatingLocation()
        }
    }
    
    func result() {
       self.time++
       print(time)
    }
    
    func switchIsChanged(mySwitch: UISwitch) {
        if mySwitch.on {
          speedStack.removeAllObjects()
          getVelocity(true)
            var alert = UIAlertController(title: "Wait", message: "Allow about 15 seconds for your device to calbrate, to zero out", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Wait", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
          

        } else {
          print("turned off")
          getVelocity(false)
            speedLabel.text = (NSString(format: "You are moving at %.2f m/s \n", 0))
            mphLabel.text = (NSString(format: "You are moving at %.2f mph \n", 0))
            let stats = Statistics()
            var avg = stats.average(speedStack)
            print(avg)
            averageSpeedLabel.text =
                (NSString(format: "You're average speed was %.2f mph \n", avg))
            topSpeedLabel.text =
                (NSString(format: "You're top speed was %.2f mph \n", stats.topSpeed))

        }
    }
    
    func locationManager(manager: CLLocationManager!,
        didUpdateToLocation newLocation: CLLocation!,
        fromLocation oldLocation: CLLocation!){
            if (oldLocation != nil) {
                calibration = false
                print("boool is " + doOnce.description)
                var gpsSpeed = newLocation.speed
                var distanceChange = newLocation.distanceFromLocation(oldLocation)
                var sinceLastUpdate = newLocation.timestamp.timeIntervalSinceDate(oldLocation.timestamp)
                var calculatedSpeed = distanceChange / sinceLastUpdate
                var mphSpeed = calculatedSpeed * 2.2369
                var distanceTraveled =
                    newLocation.distanceFromLocation(firstLocation)
                if mphSpeed == 0  && calibrationCompleted == false{
                    print("wewrwe")
                    if calibration == false{
                        calibration = true
                    }
                    if calibration == true  {
                        speedStack.removeAllObjects()
                        calibrationCompleted = true
                        
                    }
                    
                }
                print(firstLocation.description)
                print(NSString(format:"you are moving at %.2f m/s \n",calculatedSpeed))
                speedLabel.text = (NSString(format: "You are moving at %.2f m/s \n", calculatedSpeed))
                mphLabel.text = (NSString(format: "You are moving at %.2f mph \n", mphSpeed))
                distanceTraveledLabel.text =
                   (NSString(format: "You have traveled %.2f meters\n", distanceTraveled))
                if(mphSpeed < 100){
                  speedStack.addObject(mphSpeed)
                }
            }
            else if (oldLocation == nil){
                firstLocation = newLocation
            }
            latitude = "\(newLocation.coordinate.latitude)"
            longitude = "\(newLocation.coordinate.longitude)"
            var locationPair = [latitude,longitude];
            locationStack += locationPair
            println("Latitude = \(newLocation.coordinate.latitude)")
            println("Longitude = \(newLocation.coordinate.longitude)")
            
    }
    func accelData(){
        let motionManager: CMMotionManager = CMMotionManager()
        if (motionManager.accelerometerAvailable) {
        
        
        }

    }
    
    func locationManager(manager: CLLocationManager!,
        didFailWithError error: NSError!){
            println("Location manager failed with error = \(error)")
    }
    
    func locationManager(manager: CLLocationManager!,
        didChangeAuthorizationStatus status: CLAuthorizationStatus){
            
            print("The authorization status of location services is changed to: ")
            
            switch CLLocationManager.authorizationStatus(){
            case .Authorized:
                println("Authorized")
            case .AuthorizedWhenInUse:
                println("Authorized when in use")
            case .Denied:
                println("Denied")
            case .NotDetermined:
                println("Not determined")
            case .Restricted:
                println("Restricted")
            default:
                println("Unhandled")
            }
            
    }
    
    func displayAlertWithTitle(title: String, message: String){
        let controller = UIAlertController(title: title,
            message: message,
            preferredStyle: .Alert)
        
        controller.addAction(UIAlertAction(title: "OK",
            style: .Default,
            handler: nil))
        
        presentViewController(controller, animated: true, completion: nil)
        
    }
    
    func createLocationManager(#startImmediately: Bool){
        locationManager = CLLocationManager()
        if let manager = locationManager{
            println("Successfully created the location manager")
            manager.delegate = self
           
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.getVelocity(false);
        runSwitch.on = false
        runSwitch.addTarget(self, action: Selector("switchIsChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        /* Are location services available on this device? */
        if CLLocationManager.locationServicesEnabled(){
            
            /* Do we have authorization to access location services? */
            switch CLLocationManager.authorizationStatus(){
            case .Authorized:
                /* Yes, always */
                createLocationManager(startImmediately: true)
            case .AuthorizedWhenInUse:
                /* Yes, only when our app is in use */
                createLocationManager(startImmediately: true)
            case .Denied:
                /* No */
                displayAlertWithTitle("Not Determined",
                    message: "Location services are not allowed for this app")
            case .NotDetermined:
                /* We don't know yet, we have to ask */
                createLocationManager(startImmediately: false)
                if let manager = self.locationManager{
                    manager.requestWhenInUseAuthorization()
                }
            case .Restricted:
                /* Restrictions have been applied, we have no access
                to location services */
                displayAlertWithTitle("Restricted",
                    message: "Location services are not allowed for this app")
            }
            
            
        } else {
            /* Location services are not enabled.
            Take appropriate action: for instance, prompt the
            user to enable the location services */
            println("Location services are not enabled")
        }
    }
    
}

