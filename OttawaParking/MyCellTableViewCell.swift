//
//  MyCellTableViewCell.swift
//  OttawaParking
//
//  Created by 赵嘉伟 on 16/7/20.
//  Copyright © 2016年 赵嘉伟. All rights reserved.
//

import UIKit

class MyCellTableViewCell: UITableViewCell {
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
       
        super.init(style: style, reuseIdentifier: reuseIdentifier)

    }
    override func drawRect(rect: CGRect) {
        print(rect.width)
        var context:CGContextRef! =  UIGraphicsGetCurrentContext();//获取画笔上下文
        
        CGContextSetAllowsAntialiasing(context, true) //抗锯齿设置
        
        //画直线
        CGContextSetLineWidth(context, 1)
        CGContextSetRGBStrokeColor(context,  70.0 / 255.0, 241.0 / 255.0, 241.0 / 255.0, 1.0)
        CGContextMoveToPoint(context, 50, 0);
        CGContextAddLineToPoint(context, 50, rect.height);
        CGContextStrokePath(context)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
