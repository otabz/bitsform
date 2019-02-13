//
//  LocationVC.swift
//  bitsform
//
//  Created by Waseel ASP Ltd. on 7/12/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import CoreData

class LocationVC: UIViewController, CLLocationManagerDelegate {
    let locationManger = CLLocationManager()
    var lat: NSNumber! = 0.0000
    var long: NSNumber! = 0.0000
    var draftedFormNumber: String!
    var Context: NSManagedObjectContext!
    /*lazy var Context: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()*/

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var latitude: UITextField!
    @IBOutlet weak var longitude: UITextField!
    @IBOutlet weak var violationSymbol: UIImageView!
    @IBOutlet weak var violationText: UILabel!
    
    override func viewDidLoad() {
        toggleViolation(false, message: "")
        loadData()
    }
    
    func loadData() {
        // load form
        let fetchRequest = NSFetchRequest(entityName: "Form")
        fetchRequest.predicate = NSPredicate(format: "id = %@", self.draftedFormNumber)
        
        do {
            let found = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            if found!.count != 0 {
                let form = found![0] as! Form
                self.lat = form.latitude
                self.latitude.text = "\(self.lat)"
                
                self.long = form.longitude
                self.longitude.text = "\(self.long)"
            }
        } catch {
            print(error)
        }
    }

    @IBAction func close(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func find(sender: UIButton) {
        toggleViolation(false, message: "")
        locationManger.requestWhenInUseAuthorization()
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            locationManger.delegate = self
            locationManger.distanceFilter = kCLDistanceFilterNone
            locationManger.desiredAccuracy = kCLLocationAccuracyBest
            locationManger.startUpdatingLocation()
            mapView.showsUserLocation = true
        } else {
            toggleViolation(true, message: "Please, check location settings.")
        }
    }
    @IBAction func save(sender: UIButton) {
        if !isFilled() {
            toggleViolation(true, message: "Please, fill the form.")
            return
        }
        // update form
        let fetchRequest = NSFetchRequest(entityName: "Form")
        fetchRequest.predicate = NSPredicate(format: "id = %@", self.draftedFormNumber)
        
        do {
            let found = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            if found!.count != 0 {
                let form = found![0] as! Form
                form.updated_at = NSDate()
                form.sent = false
                form.section_location = true
                form.latitude  = self.lat
                form.longitude = self.long
                try Context.save()
            }
        } catch {
            print(error)
        }
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("back", sender: self)
    }
    
    func isFilled() -> Bool {
        if self.lat == 0
            && self.long == 0 {
            return false
        }
        return true
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        mapView.setRegion(region, animated: true)
        latitude.text = "\(location!.coordinate.latitude)"
        longitude.text = "\(location!.coordinate.longitude)"
        self.lat = location!.coordinate.latitude
        self.long = location!.coordinate.longitude
        locationManger.stopUpdatingLocation()
    }

    func toggleViolation(raised: Bool, message: String) {
        if raised {
            self.violationSymbol.hidden = false
            self.violationText.text = message
        } else {
            self.violationSymbol.hidden = true
            self.violationText.text = ""
        }
    }
    
    @IBAction func clear(sender: UIButton) {
        // update form
        let fetchRequest = NSFetchRequest(entityName: "Form")
        fetchRequest.predicate = NSPredicate(format: "id = %@", self.draftedFormNumber)
        do {
            let found = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            if found!.count != 0 {
                let form = found![0] as! Form
                form.updated_at = NSDate()
                form.sent = false
                form.latitude = 0
                form.longitude = 0
                form.section_location = false
                try Context.save()
            }
        } catch{
            print(error)
        }
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("back", sender: self)
    }

}
