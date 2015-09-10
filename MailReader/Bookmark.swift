//
//  Bookmark.swift
//  MailApp
//
//  Created by ShimmenNobuyoshi on 2015/09/05.
//  Copyright (c) 2015年 Shimmen Nobuyoshi. All rights reserved.
//

import Foundation
import CoreData

@objc(Bookmark)

class Bookmark: NSManagedObject {

    @NSManaged var html: String
    @NSManaged var date: NSDate
    @NSManaged var title: String

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(dict: [String: AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Bookmark", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        self.html = dict["html"] as! String
        self.date = dict["date"] as! NSDate
        self.title = dict["title"] as! String
    }
    
}
