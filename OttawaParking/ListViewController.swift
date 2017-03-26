//
//  ListViewController.swift
//  OttawaParking
//
//  Created by 赵嘉伟 on 16/8/5.
//  Copyright © 2016年 赵嘉伟. All rights reserved.
//

import UIKit
import GoogleMaps

class ListViewController: UIViewController, UITableViewDelegate,UITableViewDataSource{
    
    //Attributes
    var headerView:HeaderView!
    
    var name_addressLabel:UILabel!
    
    var distanceLabel:UILabel!
    
    @IBOutlet var listTableView:UITableView!
    
    var retrievedParkingInfo:[ParkingInfo] = []
    
    var myLocation:CLLocation?
    
    //Methods
    
    //Selector
    func back(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //Order the array
        self.retrievedParkingInfo.sortInPlace({
            (parkingInfo1, parkingInfo2) -> Bool in
            if(parkingInfo1.distance <= parkingInfo2.distance){
                return true
            }else{
                return false
            }
        })
        //
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .Plain, target: self, action: #selector(ListViewController.back))
        
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.blackColor()
        if( (UIDevice.currentDevice().systemVersion as NSString).doubleValue >= 7.0 ){
            
            self.edgesForExtendedLayout = UIRectEdge.None
            
        }
    
        self.title = "List"
        self.headerView = HeaderView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.width,25))
        //print(UIScreen.mainScreen().bounds.width)
        //print(self.view.frame)
        self.headerView.backgroundColor = UIColor.blackColor()
        self.view.addSubview(headerView)
        
        self.name_addressLabel = UILabel(frame: CGRectMake(5,5,3*headerView.frame.width/4 - 5,15))
        self.name_addressLabel.text = "Name/Address"
        
        self.name_addressLabel.font = UIFont.systemFontOfSize(12)
        self.name_addressLabel.textColor = UIColor.whiteColor()
        self.headerView.addSubview(name_addressLabel)
        
        self.distanceLabel = UILabel(frame: CGRectMake(3*headerView.frame.width/4 + 5,5,headerView.frame.width/4 - 5,15))
        self.distanceLabel.text = "Distance"
        self.distanceLabel.font = UIFont.systemFontOfSize(12)
        self.distanceLabel.textColor = UIColor.whiteColor()
        self.distanceLabel.textAlignment = .Center
        self.headerView.addSubview(distanceLabel)
        
        self.listTableView.tableFooterView = UIView()
        print(self.retrievedParkingInfo.count)
       // self.headerView.setNeedsDisplay()

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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40.0
    }
    


    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return self.retrievedParkingInfo.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let identifier:String = "parkingInfoCell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? ParkingInfoCell
        if(cell == nil){
            cell = ParkingInfoCell(style: .Default, reuseIdentifier: identifier)
        }
        
        cell!.accessoryType = .None
    cell!.setProperties(self.retrievedParkingInfo[indexPath.row])
        return cell!
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let selectedParkingInfo = self.retrievedParkingInfo[indexPath.row]
        if(selectedParkingInfo.parkingType == ParkingType.parkingLot){
            
            var parkingLotDetailViewController = ParkingLotDetailViewController(nibName: "ParkingLotDetailViewController", bundle: NSBundle.mainBundle())
            parkingLotDetailViewController.parkingInfo = selectedParkingInfo
            parkingLotDetailViewController.myLocation = self.myLocation
            
            let navigationCtl = UINavigationController(rootViewController: parkingLotDetailViewController)
            self.presentViewController(navigationCtl, animated: true, completion: nil)
        }else{
            var onStreetParkingDetailViewController = OnStreetParkingDetailViewController(nibName: "OnStreetParkingDetailViewController", bundle: NSBundle.mainBundle())
            onStreetParkingDetailViewController.parkingInfo = selectedParkingInfo
            onStreetParkingDetailViewController.myLocation = self.myLocation
            
            let navigationCtl = UINavigationController(rootViewController: onStreetParkingDetailViewController)
            self.presentViewController(navigationCtl, animated: true, completion: nil)

        }

    }
    

}
