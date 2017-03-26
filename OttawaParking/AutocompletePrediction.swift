//
//  AutocompletePrediction.swift
//  OttawaParking
//
//  Created by 赵嘉伟 on 16/7/15.
//  Copyright © 2016年 赵嘉伟. All rights reserved.
//

import UIKit

class AutocompletePrediction {
    
    let placeID:String
    let attributedFullText:NSAttributedString
    
    init(placeID:String, attributedFullText:NSAttributedString){
        self.placeID = placeID;
        self.attributedFullText = attributedFullText
    }
    
}
