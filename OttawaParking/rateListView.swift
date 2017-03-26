//
//  rateListView.swift
//  OttawaParking
//
//  Created by 赵嘉伟 on 16/8/13.
//  Copyright © 2016年 赵嘉伟. All rights reserved.
//

import UIKit

class rateListView: UIView {
    
    var y:CGFloat = 0.0
    
    var subHeadings:[String] = []
    
    var ratesDataSource:[NSArray] = []

    override func drawRect(rect: CGRect) {
        
        let context:CGContextRef! =  UIGraphicsGetCurrentContext();//获取画笔上下文
        
        CGContextSetAllowsAntialiasing(context, true) //抗锯齿设置
        
    
        CGContextSetLineWidth(context, 1)
        
        CGContextSetStrokeColorWithColor(context, UIColor.lightGrayColor().CGColor)
        CGContextSetRGBFillColor(context, 0.9, 0.9, 0.9, 1);//fill color
        
        for i in 0..<subHeadings.count{
            var subHeadingLabel = UILabel(frame: CGRectMake(0,self.y,rect.width,15))
            subHeadingLabel.font = UIFont.systemFontOfSize(12)
            subHeadingLabel.text = subHeadings[i]
            subHeadingLabel.textAlignment = .Center
            self.addSubview(subHeadingLabel)
            self.y += 15.0
            
            
            
            
            
            // Titles
            CGContextMoveToPoint(context, rect.width/2, y);
            CGContextAddArcToPoint(context, rect.width-10, y, rect.width-10, y + 15, 5);
            CGContextAddLineToPoint(context, rect.width-10, y + 15);
            CGContextAddLineToPoint(context, 10, y + 15);
            
            CGContextAddArcToPoint(context, 10, y, rect.width-10, y, 5);
            CGContextAddLineToPoint(context, rect.width/2, y);
             CGContextDrawPath(context, .FillStroke);
            
            // Middle line
            CGContextMoveToPoint(context, rect.width/2, y);
            CGContextAddLineToPoint( context, rect.width/2, y + CGFloat(15 * (self.ratesDataSource[i].count + 1)) );
            
            
            //Body
            CGContextMoveToPoint(context, rect.width-10, y + 15);
            CGContextAddArcToPoint(context, rect.width-10, y + CGFloat(15 * (self.ratesDataSource[i].count + 1)), 10, y + CGFloat(15 * (self.ratesDataSource[i].count + 1)), 5);
            CGContextAddArcToPoint(context, 10, y + CGFloat(15 * (self.ratesDataSource[i].count + 1)), 10, y, 5);
            CGContextAddLineToPoint(context, 10, y + 15);
       
            
            
            var hoursTitleLabel:UILabel = UILabel(frame: CGRectMake(10,y,(rect.width-20)/2,15))
            //hoursTitleLabel.backgroundColor = UIColor.lightGrayColor()
            hoursTitleLabel.textAlignment = .Center
            hoursTitleLabel.font = UIFont.systemFontOfSize(12)
            hoursTitleLabel.text = "Hours"
            
            var rateTitleLabel:UILabel = UILabel(frame: CGRectMake(10 + (rect.width-20)/2,y,(rect.width-20)/2,15))
            
            //rateTitleLabel.backgroundColor = UIColor.lightGrayColor()
            rateTitleLabel.textAlignment = .Center
            rateTitleLabel.font = UIFont.systemFontOfSize(12)
            rateTitleLabel.text = "Rate"
            
            self.addSubview(hoursTitleLabel)
            self.addSubview(rateTitleLabel)
            y+=15
            var counter:Int = 0;
            for item in self.ratesDataSource[i]{
                counter++;
                let rateByHours = item as! NSDictionary
                let hours = rateByHours.objectForKey("hours") as! String
                let rate = rateByHours.objectForKey("rate") as! String
                
                var hoursLabel:UILabel = UILabel(frame: CGRectMake(10,y,(rect.width-20)/2,15))

                hoursLabel.textAlignment = .Center
                hoursLabel.font = UIFont.systemFontOfSize(12)
                hoursLabel.text = hours
                
                var rateLabel:UILabel = UILabel(frame: CGRectMake(10 + (rect.width-20)/2,y,(rect.width-20)/2,15))
                
                rateLabel.textAlignment = .Center
                rateLabel.font = UIFont.systemFontOfSize(12)
                rateLabel.text = rate
                
                self.addSubview(hoursLabel)
                self.addSubview(rateLabel)
                
                y += 15
                if(counter != self.ratesDataSource[i].count)
                
                {
                CGContextMoveToPoint(context, 10, y);
                CGContextAddLineToPoint(context, rect.width-10, y);
                }
                
                
            }
            CGContextStrokePath(context)
            y += 10
        }
        
        
   
        
        
    }
 

}
