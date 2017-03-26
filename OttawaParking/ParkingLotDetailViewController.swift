//
//  ParkingLotDetailViewController.swift
//  OttawaParking
//
//  Created by 赵嘉伟 on 16/8/7.
//  Copyright © 2016年 赵嘉伟. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit
class ParkingLotDetailViewController: UIViewController, NSURLConnectionDataDelegate, UIActionSheetDelegate {
    
    //Attributes
    @IBOutlet var addressLabel:UILabel!
    
    @IBOutlet var openTimeLabel:UILabel!
    
    @IBOutlet var capacityLabel:UILabel!
    
    @IBOutlet var typeLabel:UILabel!
    
    @IBOutlet var paymentOptionLabel:UILabel!
    
    @IBOutlet var phoneNumBtn:UIButton!
    
    @IBOutlet var loadDataIndicator:UIActivityIndicatorView!
    
    @IBOutlet var dataView:UIView!
    
    @IBOutlet var segment:UISegmentedControl!
    
    @IBOutlet var weekdaySegment:UISegmentedControl!
    
    @IBOutlet var ratesView:UIView!
    
    @IBOutlet var rateScrollView:UIScrollView!
    
    @IBOutlet var imageView:UIImageView!
    
    var parkingInfo:ParkingInfo!
    
    var urlData:NSMutableData = NSMutableData()
    
    var rateListViews:[rateListView] = []
    
    var currentRateListView:rateListView!
    
    var myLocation:CLLocation?
    //override var navigationItem:UINavigationItem?
    //Methods
    //Outlet Actions
    @IBAction func call(){
        
        //call the phone number
        if(phoneNumBtn.titleLabel?.text != nil){
        var phoneNum:String = (self.phoneNumBtn.titleLabel?.text)!
        
        phoneNum = phoneNum.componentsSeparatedByString("-").joinWithSeparator("")
        
        UIApplication.sharedApplication().openURL( NSURL(string:"tel://\(phoneNum)")!);
        print(phoneNum)
        }
        
    }
    
    @IBAction func segmentChange(){
        switch self.segment.selectedSegmentIndex{
        case 0 :
            //Hiding image view
            self.imageView.hidden = true
            //Showing ratesVeiw
            self.ratesView.hidden = false
        case 1 :
            //Hiding ratesVeiw
            self.ratesView.hidden = true
            //Showing image view
            self.imageView.hidden = false
        default:
            return
        }
    }
    
    @IBAction func weekdaySegmentChange(){
        switch self.weekdaySegment.selectedSegmentIndex{
        case 0 :
            //remove the current rate list view
            self.currentRateListView.removeFromSuperview()
            //set current rate list view
            self.currentRateListView = self.rateListViews[1]
            //set the content size of the scroll view
            self.rateScrollView.contentSize = CGSizeMake(self.rateScrollView.frame.width, self.currentRateListView.frame.height + 20)
            //add the rate list view
            self.rateScrollView.addSubview(self.currentRateListView)
        case 1 :
            //remove the current rate list view
            self.currentRateListView.removeFromSuperview()
            //set current rate list view
            self.currentRateListView = self.rateListViews[2]
            //set the content size of the scroll view
            self.rateScrollView.contentSize = CGSizeMake(self.rateScrollView.frame.width, self.currentRateListView.frame.height + 20)
            //add the rate list view
            self.rateScrollView.addSubview(self.currentRateListView)
        case 2 :
            //remove the current rate list view
            self.currentRateListView.removeFromSuperview()
            //set current rate list view
            self.currentRateListView = self.rateListViews[3]
            //set the content size of the scroll view
            self.rateScrollView.contentSize = CGSizeMake(self.rateScrollView.frame.width, self.currentRateListView.frame.height + 20)
            //add the rate list view
            self.rateScrollView.addSubview(self.currentRateListView)
        case 3 :
            //remove the current rate list view
            self.currentRateListView.removeFromSuperview()
            //set current rate list view
            self.currentRateListView = self.rateListViews[4]
            //set the content size of the scroll view
            self.rateScrollView.contentSize = CGSizeMake(self.rateScrollView.frame.width, self.currentRateListView.frame.height + 20)
            //add the rate list view
            self.rateScrollView.addSubview(self.currentRateListView)
        case 4 :
            //remove the current rate list view
            self.currentRateListView.removeFromSuperview()
            //set current rate list view
            self.currentRateListView = self.rateListViews[5]
            //set the content size of the scroll view
            self.rateScrollView.contentSize = CGSizeMake(self.rateScrollView.frame.width, self.currentRateListView.frame.height + 20)
            //add the rate list view
            self.rateScrollView.addSubview(self.currentRateListView)
        case 5 :
            //remove the current rate list view
            self.currentRateListView.removeFromSuperview()
            //set current rate list view
            self.currentRateListView = self.rateListViews[6]
            //set the content size of the scroll view
            self.rateScrollView.contentSize = CGSizeMake(self.rateScrollView.frame.width, self.currentRateListView.frame.height + 20)
            //add the rate list view
            self.rateScrollView.addSubview(self.currentRateListView)
        case 6 :
            //remove the current rate list view
            self.currentRateListView.removeFromSuperview()
            //set current rate list view
            self.currentRateListView = self.rateListViews[0]
            //set the content size of the scroll view
            self.rateScrollView.contentSize = CGSizeMake(self.rateScrollView.frame.width, self.currentRateListView.frame.height + 20)
            //add the rate list view
            self.rateScrollView.addSubview(self.currentRateListView)
                default:
            return
        }
    }

    //Selectors
    
    func back(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func navigation(){
        var navigationAppActionSheet = UIActionSheet(title: "How do you want to navigate", delegate: self, cancelButtonTitle: "OK", destructiveButtonTitle: nil,otherButtonTitles: "Via Google Maps", "Via Apple Maps")
        navigationAppActionSheet.showInView(self.view)
        
        
    }
    
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .Plain, target: self, action: #selector(ParkingLotDetailViewController.back))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "navigationArrow"), style: .Plain, target: self, action: #selector(ParkingLotDetailViewController.navigation))
        
        
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.blackColor()
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.blackColor()
        
        if( (UIDevice.currentDevice().systemVersion as NSString).doubleValue >= 7.0 ){
            
            self.edgesForExtendedLayout = UIRectEdge.None
            
        }
        if(self.parkingInfo.company! == ""){
            self.title = self.parkingInfo.name!
        }else{
            self.title = self.parkingInfo.company! + " " + self.parkingInfo.name!
        }
        
        self.addressLabel.text = self.parkingInfo.address
        self.openTimeLabel.text = "Open: " + self.parkingInfo.openTime!
        self.capacityLabel.text = "Capacity: "
        if(self.parkingInfo.type == "Outdoor Lot"){
            self.typeLabel.text = self.parkingInfo.type
        }else{
            let attributedType = NSMutableAttributedString(string:self.parkingInfo.type! + " - " + self.parkingInfo.rules!)
            attributedType.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(11), range: NSMakeRange( 16, attributedType.length - 16));
            
            self.typeLabel.attributedText = attributedType
        }
        self.paymentOptionLabel.text = self.parkingInfo.paymentOption
        
        self.dataView.hidden = true;
        self.segment.selectedSegmentIndex = 0;
        self.imageView.hidden = true
        
        
        self.loadDataIndicator.startAnimating()
        //check the network avalability
        if( !(Reachability().isConnectedToNetwork()) ){
            
            UIAlertView(title: "Alert", message: "No network connection", delegate: nil, cancelButtonTitle: "OK").show()
           self.loadDataIndicator.stopAnimating()
            return
        }
        

        
        //make the url
        var urlString = "https://ottawaparkingbackend.appspot.com/parkinglotdetails?lic=";
        urlString+="\(self.parkingInfo.lic!)";

        var url:NSURL! = NSURL(string: urlString)
        
        var urlRequest = NSURLRequest(URL: url, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 30)
        
        var conn = NSURLConnection(request: urlRequest, delegate: self)
        
        conn?.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        
        conn?.start()
        //print(self.rateScrollView.frame)
        
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
    func createRateListViews(allRates:NSArray){
        //print(self.rateScrollView.frame)
        
        for item in allRates{
            var rateListViewHeight:Int = 0
            let oneRateListView = rateListView()
            var rateForPeriods = item as! NSArray
            for onePeriod in rateForPeriods{
                var rateForOnePeriod = onePeriod as! NSDictionary
                oneRateListView.subHeadings.append(rateForOnePeriod.objectForKey("SUBHEADING") as! String)
                rateListViewHeight += 15
                var rates = rateForOnePeriod.objectForKey("DATA") as! NSArray
                rateListViewHeight += 15 * (rates.count + 1)
                rateListViewHeight += 10
                oneRateListView.ratesDataSource.append(rates)
            }
            oneRateListView.frame = CGRectMake(10, 20, self.rateScrollView.frame.width-20,CGFloat(rateListViewHeight) )
            oneRateListView.backgroundColor = UIColor.whiteColor()
            self.rateListViews.append(oneRateListView)
        }
    }
    
    func connection(connention: NSURLConnection, willSendRequest request:NSURLRequest, redirectResponse response:NSURLResponse?)->NSURLRequest?{
        //将要发送请求
        print("将要发送请求")
        return request;
        
    }
    func connection(connention: NSURLConnection, didReceiveResponse response:NSURLResponse){
        //接收响应
        
        print("接收响应")
        
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        //接收数据
        self.urlData.appendData(data)
        print("接收数据")
    }
    func connection(connection: NSURLConnection, needNewBodyStream request:NSURLRequest)->NSInputStream?{
        print("需要新的内容流")
        return request.HTTPBodyStream
        
    }
    
    func connection(connection: NSURLConnection, willCacheResponse cachedResponse: NSCachedURLResponse) -> NSCachedURLResponse? {
        print("缓存响应")
        return cachedResponse
        
    }
    func connection(connection: NSURLConnection, didSendBodyData bytesWritten: Int, totalBytesWritten: Int, totalBytesExpectedToWrite: Int) {
        print("发送数据请求")
    }
    
    //Dealing with the presentation of the parking image
    func setImage(lic:Int, imgUrlString:String ){
        
        //Set default image
        
        let defaultPicPath = NSBundle.mainBundle().pathForResource("default", ofType: "jpg")
        if(defaultPicPath != nil){
            var image = UIImage(contentsOfFile: defaultPicPath!)
            self.imageView.image  = image
        }
        
        //
        let parkingLotImgCachesPathForTheLic = NSHomeDirectory() + "/Library/Caches/img/parkinglot" + "/\(lic).jpg"
        
        let fileManager = NSFileManager();
        
        //Check if there is a saved image
        if(fileManager.fileExistsAtPath(parkingLotImgCachesPathForTheLic)){
            //print(parkingLotImgCachesPathForTheLic)
            //If yes, show the saved image
            var image = UIImage(contentsOfFile: parkingLotImgCachesPathForTheLic)
            self.imageView.image  = image
            
        }else{
        //If no, load the image from imgUrl
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            () -> Void in
            
            let imgUrl = NSURL(string: imgUrlString)
            
            let data = NSData(contentsOfURL: imgUrl!)
            
            var isLoadImgSucceed = false
            
            var image:UIImage?
            
            if(data != nil){
                
               isLoadImgSucceed = true
                
               image = UIImage(data: data!)
               //Save the downloaded image
               print(data!.writeToFile(parkingLotImgCachesPathForTheLic, atomically: true))
            }
            
            //Show the image
            dispatch_async(dispatch_get_main_queue(), {
                () -> Void in
                
                if(isLoadImgSucceed){
                    self.imageView.image = image
                }else{
                    /////////////////Show error image
                    print("Failing to load parking lot img")
                }
            })
            
        })
            
        }
        
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection){
        print("完成加载")
        do{
            
            let json = try NSJSONSerialization.JSONObjectWithData(self.urlData, options: .AllowFragments)
            let jsonDic = json as? NSDictionary
            self.capacityLabel.text = jsonDic?.objectForKey("capacity") as? String
            self.phoneNumBtn.setTitle(jsonDic?.objectForKey("phoneNum") as? String, forState: .Normal )
            
            self.setImage(self.parkingInfo.lic!, imgUrlString: jsonDic!.objectForKey("img") as! String )
            
            //create rate list view
            self.createRateListViews(jsonDic!.objectForKey("allRates") as! NSArray)
            print(self.rateScrollView.frame)
            //set current rate list view
            self.currentRateListView = self.rateListViews[1]
            //Set the content size of scroll view
            self.rateScrollView.contentSize = CGSizeMake(self.rateScrollView.frame.width, self.currentRateListView.frame.height + 20)
            
            self.rateScrollView.addSubview(self.currentRateListView)
            
            let hourlyParkingLabel:UILabel = UILabel(frame: CGRectMake(0,0,self.rateScrollView.frame.width,15))
            
            
            hourlyParkingLabel.font = UIFont.systemFontOfSize(12)
            hourlyParkingLabel.textAlignment = .Center
            hourlyParkingLabel.text = "Hourly Parking"
            
            self.rateScrollView.addSubview(hourlyParkingLabel)

            self.dataView.hidden = false;
            
            
        }catch var error as NSError{
            print(error.description)
        }
            self.loadDataIndicator.stopAnimating()
        
        
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        print("加载失败")
        self.loadDataIndicator.stopAnimating()
    }
    
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
