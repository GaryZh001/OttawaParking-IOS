//
//  RecordedPlace.swift
//  OttawaParking
//
//  Created by 赵嘉伟 on 16/7/16.
//  Copyright © 2016年 赵嘉伟. All rights reserved.
//

import Foundation
import CoreData


class RecordedPlace: NSManagedObject {

    @NSManaged var stringofAttributedFullText: String
    @NSManaged var placeID: String
}
