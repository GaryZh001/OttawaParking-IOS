//
//  LegendInfoViewController.swift
//  OttawaParking
//
//  Created by 赵嘉伟 on 16/7/20.
//  Copyright © 2016年 赵嘉伟. All rights reserved.
//

import UIKit

class LegendInfoViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    //Attributes
    @IBOutlet var legendInfoTableView:UITableView!
    
    var legendsofOnStreetParking:[LegendInfo] = []
    
    var legendsofParkingLot:[LegendInfo] = []
    
    var legends:[[LegendInfo]] = []
    //Methods
    
    //Selector
    func back(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .Plain, target: self, action: #selector(LegendInfoViewController.back))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.blackColor()
        self.title = "Legends"
        if( (UIDevice.currentDevice().systemVersion as NSString).doubleValue >= 7.0 ){
            
            self.edgesForExtendedLayout = UIRectEdge.None
            
        }
        
        //Set the two [LegendInfo] arrays
        //First: OnStreetParking
        let onStreetParkingForFree = LegendInfo(legendType: LegendType.onStreetParkingLegend, legendImage: UIImage(named: "legend_onstreetparking_forfree")!, legendDescription: "Free on-street parking")
        
        let onStreetParkingForCharge = LegendInfo(legendType: LegendType.onStreetParkingLegend, legendImage: UIImage(named: "legend_onstreetparking_forcharge")!, legendDescription: "On-street parking for charge")
        
        //Second: Parking lot
        let parkingLotForFree = LegendInfo(legendType: LegendType.parkingLotLegend, legendImage: UIImage(named: "legend_parkinglot_forfree")!, legendDescription: "A free parking lot")
        
        let parkingLotForCharge = LegendInfo(legendType: LegendType.parkingLotLegend, legendImage: UIImage(named: "legend_parkinglot_forcharge")!, legendDescription: "A parking lot for charge")
        //Then, Set values
        self.legendsofOnStreetParking.append(onStreetParkingForFree)
        self.legendsofOnStreetParking.append(onStreetParkingForCharge)
        
        self.legendsofParkingLot.append(parkingLotForFree)
        self.legendsofParkingLot.append(parkingLotForCharge)
        
        self.legends.append(self.legendsofOnStreetParking)
        self.legends.append(self.legendsofParkingLot)
        print(legends)
        self.legendInfoTableView.delegate = self
        self.legendInfoTableView.dataSource = self
        
        var headerView = UIView(frame: CGRectMake(0,0,1,15))
        
        
        self.legendInfoTableView.tableHeaderView = headerView
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 2
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
   
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var headerView = UIView(frame: CGRectMake(0,0,tableView.frame.width,35))
        //headerView.backgroundColor = UIColor.blueColor()
        var title:UILabel = UILabel(frame: CGRectMake(10,10,tableView.frame.width-10,20))
        title.font = UIFont.boldSystemFontOfSize(12)
        title.textColor = UIColor.blackColor()
        if(section == 0){
            
            title.text = "On-street Parking legends"
            
        }else{
            
            title.text = "Parking lot legends"
            
        }
        //title.backgroundColor = UIColor.whiteColor()
        
        headerView.addSubview(title)
        
        
        return headerView
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.legends[section].count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let identifier:String = "legendCell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier)
        if(cell == nil){
            cell = UITableViewCell(style: .Value1, reuseIdentifier: identifier)
        }
        
        cell!.accessoryType = .None
        cell!.detailTextLabel?.numberOfLines = 0
        cell!.detailTextLabel?.font = UIFont.systemFontOfSize(12.0)
        cell!.detailTextLabel?.textColor = UIColor.blackColor()
        cell!.detailTextLabel?.text = (self.legends[indexPath.section][indexPath.row]).legendDescription
        
        cell!.imageView?.image = (self.legends[indexPath.section][indexPath.row]).legendImage
        print(indexPath.section)
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        
    }
    

}
