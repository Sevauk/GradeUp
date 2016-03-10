//
//  Category.swift
//  GradeUp
//
//  Created by Adrien morel on 2/9/16.
//  Copyright © 2016 Adrien morel. All rights reserved.
//

import UIKit
import Foundation

class Category: NSObject, NSCoding {
    
    static let archiveURL: NSURL = {
        let documentsDirectories =
            NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory = documentsDirectories.first!
        return documentDirectory.URLByAppendingPathComponent("categories.archive")
    }()
    
    var name: String
    var sessionSuccessRate: Float
    var bestSuccessRate: Float
    var iconName: String!
    
    static var images = ["animal",
        "apple",
        "basketball",
        "book",
        "boy-face",
        "chemistry",
        "code",
        "earth",
        "graphic",
        "music",
        "painting",
        "plant",
        "rocket",
        "scale",
        "search",
        "student",
        "syringe",
        "telescope",
        "wallclock"]
    
    
    static var categories: [Category] =
    {
        if let object = NSKeyedUnarchiver.unarchiveObjectWithFile(Category.archiveURL.path!) as? [Category] {
            return object
        }
        
        return []
    }() {
        didSet {
            saveCategories()
        }
    }
    
    class QA: NSObject, NSCoding {
        
        let identifier: Int
        var time_success = 0
        var time_failure = 0

        init(identifier: Int) {
            self.identifier = identifier
        }
        
        required convenience init?(coder aDecoder: NSCoder) {
            self.init(identifier: aDecoder.decodeObjectForKey("identifier") as! Int)
            
            self.time_success = aDecoder.decodeObjectForKey("time_success") as! Int
            self.time_failure = aDecoder.decodeObjectForKey("time_failure") as! Int
        }
        
        func encodeWithCoder(aCoder: NSCoder) {
            
            aCoder.encodeObject(identifier, forKey: "identifier")
            aCoder.encodeObject(time_success, forKey: "time_success")
            aCoder.encodeObject(time_failure, forKey: "time_failure")
        }
        
        func getSuccessRate() -> Float {
            let total = time_success + time_failure
            
            return total == 0 ? 0 : Float(time_success) / Float(total)
        }
        
        func getSuccessRatePercent() -> Int {
            return Int(getSuccessRate() * 100)
        }
    }
    
    // A list of Question and Answers identifiers
    var qas: Array<QA>! = [] {
         didSet {
            Category.saveCategories()
        }
    }
    
    init(name: String) {
        self.name = name
        self.sessionSuccessRate = 0
        self.bestSuccessRate = 0
        self.iconName = Category.images[0]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(qas, forKey: "qas")
        aCoder.encodeObject(sessionSuccessRate, forKey: "sessionSuccessRate")
        aCoder.encodeObject(bestSuccessRate, forKey: "bestSuccessRate")
        aCoder.encodeObject(iconName, forKey: "iconName")

    }
    
    required convenience init?(coder aDecoder: NSCoder) {

        let name = aDecoder.decodeObjectForKey("name") as! String

        self.init(name: name)
        
        self.qas = aDecoder.decodeObjectForKey("qas") as! Array<QA>
        
        self.sessionSuccessRate = aDecoder.decodeObjectForKey("sessionSuccessRate") as! Float
        self.bestSuccessRate = aDecoder.decodeObjectForKey("bestSuccessRate") as! Float
        self.iconName = aDecoder.decodeObjectForKey("iconName") as? String
        if self.iconName == nil {
            self.iconName = "earth"
        }


    }

    static func saveCategories() -> Bool {
        return NSKeyedArchiver.archiveRootObject(Category.categories, toFile: archiveURL.path!)
    }
    
    func deleteRecordFileBy(identifier id: Int) throws {
        let QURL = Recorder.recordingURL(.Question, name: name, identifier: id)
        let AURL = Recorder.recordingURL(.Answer, name: name, identifier: id)
        
        let fileManager = NSFileManager.defaultManager()
        
        try fileManager.removeItemAtURL(QURL)
        try fileManager.removeItemAtURL(AURL)
    }
}
