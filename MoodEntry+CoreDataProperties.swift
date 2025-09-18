//
//  MoodEntry+CoreDataProperties.swift
//  FinalProject
//
//  Created by Vanessa Wartemberg on 3/6/25.
//
//

import Foundation
import CoreData


extension MoodEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MoodEntry> {
        return NSFetchRequest<MoodEntry>(entityName: "MoodEntry")
    }

    @NSManaged public var intensity: Float
    @NSManaged public var mood: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var notes: String?
    @NSManaged public var moodDescription: String?

}

extension MoodEntry : Identifiable {

}
