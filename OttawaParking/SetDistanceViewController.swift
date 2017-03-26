//
//  SetDistanceViewController.swift
//  OttawaParking
//
//  Created by 赵嘉伟 on 9/13/16.
//  Copyright © 2016 赵嘉伟. All rights reserved.
//

import UIKit

class SetDistanceViewController: UIViewController {
    //Attributes
    @IBOutlet var distanceSlider:DistanceSlider!
    @IBOutlet var currentDistanceLabel:UILabel!
    @IBOutlet var confirmButton:UIButton!
    
    //Methods
    
    //Selectors
    
    @IBAction func distanceChanged(){
        self.distanceSlider.value = Float(Int(self.distanceSlider.value))
        self.currentDistanceLabel.text = "\(Int(self.distanceSlider.value)) meters"
        
    }
    @IBAction func confirm(){
        NSUserDefaults.standardUserDefaults().setInteger(Int(self.distanceSlider.value), forKey: "distance")
        //post a notification
        NSNotificationCenter.defaultCenter().postNotificationName("distanceChanged", object: nil)
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    func back(){
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .Plain, target: self, action: #selector(SetDistanceViewController.back))

        
        
        
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.blackColor()
        
        
        if( (UIDevice.currentDevice().systemVersion as NSString).doubleValue >= 7.0 ){
            
            self.edgesForExtendedLayout = UIRectEdge.None
            
        }
        
        self.title = "Distance"
        
        self.distanceSlider.minimumValue = 100
        self.distanceSlider.maximumValue = 500
        self.distanceSlider.value = Float(NSUserDefaults.standardUserDefaults().integerForKey("distance"))
        self.currentDistanceLabel.text = "\(NSUserDefaults.standardUserDefaults().integerForKey("distance")) meters"

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

}
