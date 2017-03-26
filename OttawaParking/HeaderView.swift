//
//  HeaderView.swift
//  OttawaParking
//
//  Created by 赵嘉伟 on 16/8/6.
//  Copyright © 2016年 赵嘉伟. All rights reserved.
//

import UIKit

class HeaderView: UIView {


    override func drawRect(rect: CGRect) {
        let context:CGContextRef! =  UIGraphicsGetCurrentContext();//获取画笔上下文
        
        CGContextSetAllowsAntialiasing(context, true) //抗锯齿设置
        
        //画直线
        CGContextSetLineWidth(context, 1)
        CGContextSetRGBStrokeColor(context,  1, 1, 1, 1.0)
        CGContextMoveToPoint(context, 3*rect.width/4, 0);
        CGContextAddLineToPoint(context, 3*rect.width/4, rect.height);
        CGContextStrokePath(context)
    }

}
