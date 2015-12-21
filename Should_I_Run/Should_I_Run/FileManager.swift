//
//  File.swift
//  Should I Run
//
//  Created by Grimi on 7/24/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//

import Foundation

let SharedFileManager = FileManager()

class FileManager: NSObject {
    
    let fileManager = NSFileManager.defaultManager()
    
    let cachePlistFileName = "cache.plist"
    let destinationsPlistFileName = "destinations.plist"
    
    let cachePlistPath:String?
    let destinationsPlistPath:String?
    
    class var manager: FileManager {
        return SharedFileManager
    }
    
    override init () {
        let directorys = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,NSSearchPathDomainMask.AllDomainsMask, true) as [String]
        
        let directory:NSString = directorys.first! //documents directory
        self.cachePlistPath = directory.stringByAppendingPathComponent(self.cachePlistFileName)
        self.destinationsPlistPath = directory.stringByAppendingPathComponent(self.destinationsPlistFileName)
        
    }
    
    func saveToCache(newData:NSMutableArray) {
        let success = newData.writeToFile(self.cachePlistPath!, atomically: true)
        print(success)
    }
    
    func readFromCache() -> NSMutableArray {
        let resultsArray:NSMutableArray? = NSMutableArray(contentsOfFile: self.cachePlistPath!)
        if let res = resultsArray {
            return res
        } else {
            return []
        }
    }
    
    func clearCache() -> Void {
        NSMutableArray().writeToFile(self.cachePlistPath!, atomically: true)
    }
    
    func saveToDestinationsList(newData:NSMutableArray ) {
        newData.writeToFile(self.destinationsPlistPath!, atomically: false)
    }
    
    func readFromDestinationsList() -> NSMutableArray {
        let resultsArray:NSMutableArray? = NSMutableArray(contentsOfFile: self.destinationsPlistPath!)
        if let res = resultsArray {
            return res
        } else {
            let res:NSMutableArray = []
            return res
        }
    }
}