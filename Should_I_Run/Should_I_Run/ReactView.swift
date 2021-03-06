//
//  ReactView.swift
//  Should_I_Run
//
//  Created by Roger Goldfinger on 4/9/16.
//  Copyright © 2016 Should_I_Run. All rights reserved.
//

import UIKit
import React
import SwiftyJSON

class ReactView: UIView {
    #if DEBUG
    // 192.168.0.101
    let rootView: RCTRootView = RCTRootView(bundleURL: URL(string: "http://localhost:8081/index.ios.bundle?platform=ios"),
                                            moduleName: "SimpleApp", initialProperties: nil, launchOptions: nil)
    #else
    let rootView: RCTRootView = RCTRootView(bundleURL: Bundle.main.url(forResource: "main", withExtension: "jsbundle"),
    moduleName: "SimpleApp", initialProperties: nil, launchOptions: nil)
    #endif

    


    override func layoutSubviews() {
        super.layoutSubviews()
        loadReact()
    }
    
    func loadReact () {
        addSubview(rootView)
        rootView.frame = self.bounds
        rootView.backgroundColor = globalBackgroundColor
    }

    func updateData(_ data: AnyObject, walkingData: AnyObject, location: CLLocationCoordinate2D) {
        rootView.appProperties = ["data": data, "walkingData": walkingData, "location": ["lat": location.latitude, "lng": location.longitude]]
    }
}
