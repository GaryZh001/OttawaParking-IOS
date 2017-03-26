//
//  ParkingInfo.swift
//  OttawaParking
//
//  Created by 赵嘉伟 on 16/8/2.
//  Copyright © 2016年 赵嘉伟. All rights reserved.
//

import UIKit

enum ParkingType{
    case onStreetParking
    case parkingLot
}

class ParkingInfo{
    
    let parkingType:ParkingType
    
    var id:Int?
    
    var lic:Int?
    
    var company:String?
    
    var name:String?
    
    var paymentOption:String?
    
    var rules:String?
    
    var type:String?
    
    var latitude:String
    
    var longitude:String
    
    var openTime:String?
    
    var forCharge:Bool
    
    var hasPhoto:Bool?
    
    var address:String
    
    var distance:Int
    
    var canParkNow:Bool
    
    init(parkingType:ParkingType, latitude:String, longitude:String, forCharge:Bool, address:String, distance:Int, canParkNow:Bool){
        self.parkingType = parkingType;
        self.latitude = latitude;
        self.longitude = longitude;
        self.forCharge = forCharge;
        self.address = address;
        self.distance = distance;
        self.canParkNow = canParkNow;
    }
}

