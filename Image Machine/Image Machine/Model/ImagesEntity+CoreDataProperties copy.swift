//
//  ImagesEntity+CoreDataProperties.swift
//  
//
//  Created by Ridoan Wibisono on 25/07/21.
//
//

import Foundation
import CoreData


extension ImagesEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImagesEntity> {
        return NSFetchRequest<ImagesEntity>(entityName: "ImagesEntity")
    }

    @NSManaged public var image: Data
    @NSManaged public var machine_id: UUID

}
