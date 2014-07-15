//
//  AddViewController.swift
//  should I run? draft
//
//  Created by Roger Goldfinger on 7/11/14.
//  Copyright (c) 2014 Roger Goldfinger. All rights reserved.
//

import UIKit

import MapKit

class AddViewController: UIViewController, MKMapViewDelegate {


    @IBOutlet var textField : UITextField


    @IBOutlet var saveBarButton: UIBarButtonItem


    var place:Place? = nil
    
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
    
        if (sender as? UIBarButtonItem != self.saveBarButton) {
            return
        }

        self.place = Place(name: self.textField.text, latitude: 35.0, longitude: -120.0)
        
                        let userDefaults = NSUserDefaults.standardUserDefaults()
                        var number : Int = userDefaults.integerForKey("num")
                        number = number+1
                        println(number)
                        userDefaults.setObject(["name": self.textField.text, "latitude": 35.9, "longitude": 6.40], forKey: String(number))
        
                        userDefaults.setInteger(number,forKey: "num")
                        userDefaults.synchronize()
        
    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//    }
//    

//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
    


}
