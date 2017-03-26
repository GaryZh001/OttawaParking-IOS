//
//  DistanceSlider.swift
//  OttawaParking
//
//  Created by 赵嘉伟 on 9/26/16.
//  Copyright © 2016 赵嘉伟. All rights reserved.
//

import UIKit

class DistanceSlider: UISlider {

    
    override func drawRect(rect: CGRect) {
        // Drawing code
        var context:CGContextRef! =  UIGraphicsGetCurrentContext();//获取画笔上下文
        
        CGContextSetAllowsAntialiasing(context, true) //抗锯齿设置
        
        //画直线
        CGContextSetLineWidth(context, 3.5)
        CGContextSetRGBStrokeColor(context,  0.5, 0.5, 0.5, 1.0)
        
        CGContextMoveToPoint(context, 0, 0);
        CGContextAddLineToPoint(context, rect.width, 0);
        
        
        CGContextMoveToPoint(context, rect.width, 0);
        CGContextAddLineToPoint(context, rect.width
            , rect.height);
        
        CGContextMoveToPoint(context, rect.width
            , rect.height);
        CGContextAddLineToPoint(context, 0
            , rect.height);
        
        CGContextMoveToPoint(context, 0
            , rect.height);
        CGContextAddLineToPoint(context, 0
            , 0);
        
        CGContextStrokePath(context)
        print("prin frame")

    }
    

}
