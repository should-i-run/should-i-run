    //
//  LoadingViewController.swift
//  Should I Run
//
//  Created by Roger Goldfinger on 7/17/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//

import UIKit
import MapKit

enum NetworkStatusStruct: Int {
    case notReachable = 0
    case reachableViaWiFi
    case reachableViaWWAN
}

class LoadingViewController: UIViewController {
    
    var viewHasAlreadyAppeared = false
    var backgroundColor = UIColor()
    @IBOutlet var spinner: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner!.startAnimating()
        self.view.backgroundColor = self.backgroundColor
    }

    override func viewDidDisappear(_ animated: Bool) {
        spinner!.stopAnimating()
        super.viewDidDisappear(animated)
    }
}

