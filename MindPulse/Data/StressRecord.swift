//
//  StressRecord.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/14/25.
//

import Foundation
import CoreData

@objc(StressRecord)
public class StressRecord: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<StressRecord> {
        return NSFetchRequest<StressRecord>(entityName: "StressRecord")
    }

    @NSManaged public var date: Date
    @NSManaged public var score: Int32
}

