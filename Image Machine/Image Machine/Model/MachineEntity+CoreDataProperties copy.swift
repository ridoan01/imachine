//
//  MachineEntity+CoreDataProperties.swift
//  
//
//  Created by Ridoan Wibisono on 25/07/21.
//
//

import Foundation
import CoreData


extension MachineEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MachineEntity> {
        return NSFetchRequest<MachineEntity>(entityName: "MachineEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var maintance_date: Date
    @NSManaged public var name: String
    @NSManaged public var qrcode: Int64
    @NSManaged public var type: String

}
