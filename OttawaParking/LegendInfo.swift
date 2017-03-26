//
//  LegendInfo.swift
//  OttawaParking
//
//  Created by 赵嘉伟 on 16/7/20.
//  Copyright © 2016年 赵嘉伟. All rights reserved.
//

import UIKit
enum LegendType{
    case onStreetParkingLegend
    case parkingLotLegend
    
}
class LegendInfo{
    
    let legendType:LegendType
    let legendImage:UIImage
    let legendDescription:String
    
    init(legendType:LegendType, legendImage:UIImage, legendDescription:String){
        self.legendType = legendType
        self.legendImage = legendImage
        self.legendDescription = legendDescription
    }
    
}
