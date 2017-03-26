//
//  SettingViewController.swift
//  OttawaParking
//
//  Created by 赵嘉伟 on 9/13/16.
//  Copyright © 2016 赵嘉伟. All rights reserved.
//

import UIKit
import MessageUI
class SettingViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,MFMailComposeViewControllerDelegate {
    
    //Attributes
    @IBOutlet var settingTableView:UITableView!
    
    
    var items:[[String]] = [["Distance"],["Manage recorded places"],["Contact us via email", "About this app"]]
    
    //Methods
    
    //Selectors
    
    func back(){
        //post a notification
        NSNotificationCenter.defaultCenter().postNotificationName("changeZoom", object: nil)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func distanceChanged(){
        self.settingTableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .Plain, target: self, action: #selector(SettingViewController.back))
        
        
        
        
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.blackColor()

        
        if( (UIDevice.currentDevice().systemVersion as NSString).doubleValue >= 7.0 ){
            
            self.edgesForExtendedLayout = UIRectEdge.None
            
        }
        
        self.title = "Settings"
        
        self.settingTableView.delegate = self
        self.settingTableView.dataSource = self
        

        
        //Register for notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingViewController.distanceChanged), name: "distanceChanged", object: nil)

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
        return 3
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
   
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.items[section].count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let identifier:String = "legendCell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier)
        if(cell == nil){
            cell = UITableViewCell(style: .Value1, reuseIdentifier: identifier)
        }
        cell?.accessoryType = .DisclosureIndicator
        cell!.textLabel?.font = UIFont.systemFontOfSize(18.0)
        //cell!.detailTextLabel?.text = self.items[indexPath.section][indexPath.row]
        
        cell!.textLabel?.text = self.items[indexPath.section][indexPath.row]
        if(indexPath.section == 0){
           cell!.detailTextLabel?.text = "\(NSUserDefaults.standardUserDefaults().integerForKey("distance"))"
           cell!.detailTextLabel?.font = UIFont.systemFontOfSize(15.0)
        }
        print(indexPath.section)
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.section {
        case 0:
            var setDistanceViewController = SetDistanceViewController(nibName: "SetDistanceViewController", bundle: NSBundle.mainBundle())
            self.navigationController?.pushViewController(setDistanceViewController, animated: true)
        case 1:
             var manageRecPlacesViewController = ManageRecPlacesViewController(nibName: "ManageRecPlacesViewController", bundle: NSBundle.mainBundle())
            self.navigationController?.pushViewController(manageRecPlacesViewController, animated: true)
        case 2:
            if(indexPath.row == 0){
                if(MFMailComposeViewController.canSendMail()){
                    var picker = MFMailComposeViewController()
                    picker.mailComposeDelegate = self
                    
                    //picker.setSubject("")
                    
                    picker.setToRecipients(["zhaojiawei19930101@163.com"])
                    self.presentViewController(picker, animated: true, completion: nil)
                    let alert = UIAlertView(title: "Information", message: "You can report wrong parking data, supply us with new parking information or send anything else you want to say to us!", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    
                }else{
                    let alert = UIAlertView(title: "Error", message: "You are not able to send an Email", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
            }else{
                
            }
        default:
            return
        }
    }
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        switch result.rawValue{
        case MFMailComposeResultSent.rawValue:
            let alert = UIAlertView(title: "Information", message: "Mail has been sent", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        case MFMailComposeResultFailed.rawValue:
            let alert = UIAlertView(title: "Error", message: "Failed to send", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        default:
            return
        }
        
    }

}
