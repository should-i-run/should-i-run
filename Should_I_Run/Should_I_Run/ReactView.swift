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
    
//    let rootView: RCTRootView = RCTRootView(bundleURL: NSBundle.mainBundle().URLForResource("main", withExtension: "jsbundle"),
    let rootView: RCTRootView = RCTRootView(bundleURL: NSURL(string: "http://localhost:8081/index.ios.bundle?platform=ios"),

                                        moduleName: "SimpleApp", initialProperties: nil, launchOptions: nil)

    override func layoutSubviews() {
        super.layoutSubviews()
        loadReact()
    }
    
    func loadReact () {
        addSubview(rootView)
        rootView.frame = self.bounds
        rootView.backgroundColor = globalBackgroundColor
    }

    func updateData(data: JSON) {
        rootView.appProperties = ["data": data.object]
    }
}
