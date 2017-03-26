//
//  OnStreetParkingDetailViewController.swift
//  OttawaParking
//
//  Created by 赵嘉伟 on 16/8/20.
//  Copyright © 2016年 赵嘉伟. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps

class OnStreetParkingDetailViewController: UIViewController,UIActionSheetDelegate {
    
    //Attributes
    @IBOutlet var addressLabel:UILabel!
    
    @IBOutlet var canParkNowDescriptionLabel:UILabel!
    
    @IBOutlet var imageView:UIImageView!
    
    var parkingInfo:ParkingInfo!
    
    var myLocation:CLLocation?
    
    //Methods
    
    //Selectors
    
    func back(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func navigation(){
        var navigationAppActionSheet = UIActionSheet(title: "How do you want to navigate", delegate: self, cancelButtonTitle: "OK", destructiveButtonTitle: nil,otherButtonTitles: "Via Google Maps", "Via Apple Maps")
        navigationAppActionSheet.showInView(self.view)
        
        
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .Plain, target: self, action: #selector(OnStreetParkingDetailViewController.back))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "navigationArrow"), style: .Plain, target: self, action: #selector(OnStreetParkingDetailViewController.navigation))
        
        
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.blackColor()
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.blackColor()
        
        if( (UIDevice.currentDevice().systemVersion as NSString).doubleValue >= 7.0 ){
            
            self.edgesForExtendedLayout = UIRectEdge.None
            
        }
        
        self.title = "On-Street Parking"
        
        self.addressLabel.text = self.parkingInfo.address
        
        if(self.parkingInfo.canParkNow){
            self.canParkNowDescriptionLabel.text = "You Can Park Here Now"
            self.canParkNowDescriptionLabel.textColor = UIColor.greenColor()
        }else{
            self.canParkNowDescriptionLabel.text = "You Can not Park Here Now"
            self.canParkNowDescriptionLabel.textColor = UIColor.redColor()
        }
        
        self.setImage()

    }

    //Dealing with the presentation of the parking image
    func setImage(){
        //Set default image
        
        let defaultPicPath = NSBundle.mainBundle().pathForResource("default", ofType: "jpg")
        if(defaultPicPath != nil){
            var image = UIImage(contentsOfFile: defaultPicPath!)
            self.imageView.image  = image
            self.imageView.contentMode = .ScaleAspectFit
        }
        
        

        //
        
        let onStreetParkingImgCachesPathForTheId = NSHomeDirectory() + "/Library/Caches/img/onstreetparking" + "/\(self.parkingInfo.id!).jpg"
        
        let fileManager = NSFileManager();
        
        //Check if there is a saved image
        if(fileManager.fileExistsAtPath(onStreetParkingImgCachesPathForTheId)){
            //print(parkingLotImgCachesPathForTheLic)
            //If yes, show the saved image
            var image = UIImage(contentsOfFile: onStreetParkingImgCachesPathForTheId)
            self.imageView.image  = image
            self.imageView.contentMode = .ScaleToFill
            
        }else{
            //If no, load the image from imgUrl
            
            //First check the network avalability
            if( !(Reachability().isConnectedToNetwork()) ){
                
                UIAlertView(title: "Alert", message: "No network connection", delegate: nil, cancelButtonTitle: "OK").show()
                
                return
            }
            //
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                () -> Void in
                
                let imgUrl = NSURL(string: "https://storage.googleapis.com/ottawaparkingbackend.appspot.com/\(self.parkingInfo.id!).jpg")
                
                let data = NSData(contentsOfURL: imgUrl!)
                
                var isLoadImgSucceed = false
                
                var image:UIImage?
                
                if(data != nil){
                    
                    isLoadImgSucceed = true
                    
                    image = UIImage(data: data!)
                    //Save the downloaded image
                    print(data!.writeToFile(onStreetParkingImgCachesPathForTheId, atomically: true))
                }
                
                //Show the image
                dispatch_async(dispatch_get_main_queue(), {
                    () -> Void in
                    
                    if(isLoadImgSucceed){
                        self.imageView.image = image
                        self.imageView.contentMode = .ScaleToFill
                    }else{
                        /////////////////Show error image
                        print("Failing to load parking lot img")
                    }
                })
                
            })
            
        }
        
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
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex{
        case 0:
            return
        case 1:
            self.navigateViaGoogleMaps()
        case 2:
            self.navigateViaAppleMaps()
        default:
            return
        }
    }
    
    func navigateViaGoogleMaps(){
        
        if self.myLocation == nil{
            let noMyLocationAlert = UIAlertView(title: "Current Location not Available", message: "Your current location can not be determined at this time", delegate: nil, cancelButtonTitle: "OK")
            noMyLocationAlert.show()
            return
        }
        
        print("Use Google Maps")
        if UIApplication.sharedApplication().canOpenURL(
            NSURL(string: "comgooglemaps://")!){
            UIApplication.sharedApplication().openURL(NSURL(string:
                "comgooglemaps://?daddr=\(self.parkingInfo.latitude),\(self.parkingInfo.longitude)&directionsmode=driving")!)
        }else{
            let noGoogleMapsAppAlert = UIAlertView(title: "", message: "No Google Maps App", delegate: nil, cancelButtonTitle: "OK")
            noGoogleMapsAppAlert.show()
        }
    }
    
    func navigateViaAppleMaps(){
        if self.myLocation == nil{
            let noMyLocationAlert = UIAlertView(title: "Current Location not Available", message: "Your current location can not be determined at this time", delegate: nil, cancelButtonTitle: "OK")
            noMyLocationAlert.show()
            return
            
        }
        
        print("Use Apple Maps")
        let currentLocation = MKMapItem.mapItemForCurrentLocation()
        MKMapItem.mapItemForCurrentLocation()
        
        
        let toLocation = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2DMake( (self.parkingInfo.latitude as NSString).doubleValue, (self.parkingInfo.longitude as NSString).doubleValue ), addressDictionary: nil))
        toLocation.name = self.title
        MKMapItem.openMapsWithItems([currentLocation,toLocation], launchOptions: [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving])
        
    }


}
