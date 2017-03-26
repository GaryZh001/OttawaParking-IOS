//
//  ParkingInfoCell.swift
//  OttawaParking
//
//  Created by 赵嘉伟 on 16/8/6.
//  Copyright © 2016年 赵嘉伟. All rights reserved.
//

import UIKit

class ParkingInfoCell: UITableViewCell {
    
    var parkingNameLabel:UILabel!
    var parkingAddressLabel:UILabel!
    var parkingDistanceLabel:UILabel!

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
        
        
        self.parkingNameLabel = UILabel(frame:CGRectZero);//UILabel(frame: CGRectMake(5,5,3*self.frame.width/4 - 5,15))
       
        self.addSubview(self.parkingNameLabel)
        
        self.parkingAddressLabel = UILabel(frame:CGRectZero);//UILabel(frame: CGRectMake(5,20,3*self.frame.width/4 - 5,15))
        self.parkingAddressLabel.font = UIFont.systemFontOfSize(10)
        self.parkingAddressLabel.textColor = UIColor.grayColor()
        self.addSubview(self.parkingAddressLabel)
        
        self.parkingDistanceLabel = UILabel(frame:CGRectZero);//UILabel(frame: CGRectMake(3*self.frame.width/4,10,self.frame.width/4,20))
        self.parkingDistanceLabel.font = UIFont.systemFontOfSize(12)
        self.parkingDistanceLabel.textAlignment = .Center
        self.addSubview(self.parkingDistanceLabel)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
         self.parkingNameLabel.frame = CGRectMake(5,5,3*rect.width/4 - 5,15)
         self.parkingAddressLabel.frame = CGRectMake(5,20,3*rect.width/4 - 5,15)
         self.parkingDistanceLabel.frame = CGRectMake(3*rect.width/4,10,self.frame.width/4,20)
        var context:CGContextRef! =  UIGraphicsGetCurrentContext();//获取画笔上下文
        
        CGContextSetAllowsAntialiasing(context, true) //抗锯齿设置
        
        //画直线
        CGContextSetLineWidth(context, 1)
        CGContextMoveToPoint(context, 3*rect.width/4, 0);
        CGContextAddLineToPoint(context, 3*rect.width/4, rect.height);

        CGContextSetRGBStrokeColor(context,  0, 0, 0, 1.0)
        CGContextMoveToPoint(context, 0, rect.height);
        CGContextAddLineToPoint(context, rect.width
            , rect.height);
        
        CGContextMoveToPoint(context, 0, 0);
        CGContextAddLineToPoint(context, rect.width
            , 0);
        
        CGContextStrokePath(context)
    }
    
    func setProperties(parkingInfo:ParkingInfo){
        
        var parkingNameText:String = ""

        var parkingNameLabelText:String = ""
        
        if(parkingInfo.parkingType == ParkingType.onStreetParking){
            parkingNameText = "On Street Parking"
        }else{
            if(parkingInfo.company! != ""){
               parkingNameText = parkingInfo.company! + " " + parkingInfo.name!
            }else{
                parkingNameText = parkingInfo.name!
            }
        }
        if(parkingInfo.canParkNow){
           parkingNameLabelText = parkingNameText + " (√)"
            
        }else{
            parkingNameLabelText = parkingNameText + " (×)"
        }
        
        var attributedParkingNameLabelText = NSMutableAttributedString(string: parkingNameLabelText)
        attributedParkingNameLabelText.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(12), range: NSMakeRange(0, (parkingNameLabelText as NSString).length));
        
         //attributedParkingNameLabelText.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(9), range: NSMakeRange( (parkingNameText as NSString).length, (parkingNameLabelText as NSString).length - (parkingNameText as NSString).length) );
        
        attributedParkingNameLabelText.addAttribute(NSForegroundColorAttributeName, value: (parkingInfo.canParkNow ? UIColor.greenColor() : UIColor.redColor()), range: NSMakeRange( (parkingNameText as NSString).length, (parkingNameLabelText as NSString).length - (parkingNameText as NSString).length) );

        self.parkingNameLabel.attributedText = attributedParkingNameLabelText
        self.parkingNameLabel.lineBreakMode = .ByTruncatingMiddle
        self.parkingAddressLabel.text = parkingInfo.address
        self.parkingDistanceLabel.text = "\(parkingInfo.distance)" + "m"
    }

}
