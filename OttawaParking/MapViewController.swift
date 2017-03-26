//
//  MapViewController.swift
//  OttawaParking
//
//  Created by 赵嘉伟 on 16/7/11.
//  Copyright © 2016年 赵嘉伟. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController,GMSMapViewDelegate,UISearchBarDelegate, NSURLConnectionDataDelegate{
    //Atrributes
 
    @IBOutlet var searchBar:UISearchBar!
    
    @IBOutlet var toolBar:UIToolbar!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var activityIndicatorForPlace: UIActivityIndicatorView!
    
    var placesClient: GMSPlacesClient? = GMSPlacesClient()
    
    var mapView:GMSMapView!
    
    var semaphore:dispatch_semaphore_t = dispatch_semaphore_create(1)
    
    var starMarker:GMSMarker? = nil
    
    var urlData:NSMutableData!// = NSMutableData()
    
    var retrievedParkingInfo:[ParkingInfo] = []
    
    var globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    //var myLocation:CLLocation?
    
    //Methods
    
    //Outlet actions
    @IBAction func locating(){
        //Check if my loacation is available
        var myLocation:CLLocation? = self.mapView.myLocation

        if(myLocation == nil){
            
                let noMyLocationAlert = UIAlertView(title: "Current Location not Available", message: "Your current location can not be determined at this time", delegate: nil, cancelButtonTitle: "OK")
                noMyLocationAlert.show()
            
            return
        }
        
        //self.mapView.clear()
        
        //add a mark at that loacation
        self.starMarker?.map = nil
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(self.mapView.myLocation!.coordinate.latitude, self.mapView.myLocation!.coordinate.longitude)
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.icon = UIImage(named: "star")
        marker.map = self.mapView
        
        self.starMarker = marker
        self.starMarker?.zIndex = Int32.max
        //map moves to that location
        self.mapView.animateToLocation(marker.position)
        
    }
    @IBAction func listing(){
        print(self.retrievedParkingInfo.count)
        var listViewController = ListViewController(nibName: "ListViewController", bundle: NSBundle.mainBundle())
        listViewController.retrievedParkingInfo = self.retrievedParkingInfo
        listViewController.myLocation = self.mapView.myLocation
        
        let navigationCtl = UINavigationController(rootViewController: listViewController)
        self.presentViewController(navigationCtl, animated: true, completion: nil)
    }
    @IBAction func explainLegends(){
        var legendInfoViewController = LegendInfoViewController(nibName: "LegendInfoViewController", bundle: NSBundle.mainBundle())
        
        let navigationCtl = UINavigationController(rootViewController: legendInfoViewController)
        self.presentViewController(navigationCtl, animated: true, completion: nil)

    }
    @IBAction func settings(){
        var settingViewController = SettingViewController(nibName: "SettingViewController", bundle: NSBundle.mainBundle())
        
        let navigationCtl = UINavigationController(rootViewController: settingViewController)
        self.presentViewController(navigationCtl, animated: true, completion: nil)
    }
    
    //Selectors
    func cancelClicked(notification:NSNotification){
        var msg = notification.object as? String
        self.searchBar.text = msg
    }
    
    func placeSelected(notification:NSNotification){
        var selectedPlace = notification.object as! AutocompletePrediction
        //set the content of the search bar
        self.searchBar.text = selectedPlace.attributedFullText.string
        
        //check the network availability
        var networkRechability = Reachability()
        
        if(!networkRechability.isConnectedToNetwork()){
           UIAlertView(title: "Alert", message: "No network connection", delegate: nil, cancelButtonTitle: "OK").show()
           return
        }
        //retrieve the place coordinate
        self.activityIndicatorForPlace.startAnimating()
        placesClient?.lookUpPlaceID(selectedPlace.placeID, callback: { (place: GMSPlace?, error: NSError?) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                
                //add a mark at that loacation
                self.starMarker?.map = nil
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
                marker.appearAnimation = kGMSMarkerAnimationPop
                marker.icon = UIImage(named: "star")
                marker.map = self.mapView
                self.starMarker = marker
                self.starMarker?.zIndex = Int32.max
                //map moves to that location
            self.mapView.animateToLocation(marker.position)
                
                
                
                //let circ = GMSCircle(position: place.coordinate, radius: 300)
                //circ.map = self.mapView;
                
            
            } else {
                print("Cannot find the that place's coordinate")
            }
            self.activityIndicatorForPlace.stopAnimating()
        })

        
        
    }
    
    /*func changeZoom(){
        var distance = NSUserDefaults.standardUserDefaults().integerForKey("distance")
        
        //15 600
        //16 300
        //17 150
    }*/
    //
    override func viewDidLoad() {
        
        super.viewDidLoad()

        print(kGMSAutocompleteMatchAttribute)
        // Do any additional setup after loading the view.
        
        //Create and setup the mapview
        let camera = GMSCameraPosition.cameraWithLatitude(45.421336,longitude: -75.699837, zoom: 16)
        self.mapView = GMSMapView.mapWithFrame(UIScreen.mainScreen().bounds, camera: camera)
        
        self.mapView.delegate = self
        self.mapView.myLocationEnabled = true
        //mapView.accessibilityElementsHidden = false

        self.mapView.settings.compassButton = true
        self.mapView.setMinZoom(15, maxZoom: self.mapView.maxZoom)
        let mapInsets = UIEdgeInsetsMake(self.searchBar.frame.height+18, 0.0, self.toolBar.frame.height, 0.0)
        self.mapView.padding = mapInsets
        self.mapView.settings.compassButton = true
        self.view.insertSubview(mapView, atIndex: 0)

        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(45.421336, -75.699837)
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.icon = UIImage(named: "star")
        marker.map = self.mapView
        self.starMarker = marker
        self.starMarker?.zIndex = Int32.max
        
        self.searchBar.delegate = self
        
        //Register for notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.cancelClicked), name: "cancelClicked", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.placeSelected), name: "placeSelected", object: nil)
        
        /*NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.changeZoom), name: "changeZoom", object: nil)*/
        
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

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        print("切换界面")
        //resignFirstResponder
        //self.searchBar.resignFirstResponder()????????
        
        //Change to Search View to search 
        var searchViewController = SearchViewController(nibName: "SearchViewController", bundle: NSBundle.mainBundle())
        searchViewController.text = searchBar.text

        self.presentViewController(searchViewController, animated: true, completion: nil)

    }
    
    func mapView(mapView: GMSMapView, willMove gesture: Bool) {
        
    }
    
    func mapView(mapView: GMSMapView, idleAtCameraPosition position: GMSCameraPosition) {
        print("idleAtCameraPosition")
        dispatch_async(globalQueue){
        print(dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER))
            dispatch_async(dispatch_get_main_queue()){
        self.activityIndicator.startAnimating()
        //check the network avalability
        if( !(Reachability().isConnectedToNetwork()) ){
            self.activityIndicator.stopAnimating()
            UIAlertView(title: "Alert", message: "No network connection", delegate: nil, cancelButtonTitle: "OK").show()
            dispatch_semaphore_signal(self.semaphore)
            return
        }
        
        //Retriving data:
        
        //distance
        let distance = NSUserDefaults.standardUserDefaults().integerForKey("distance")
        //coordinate
        let latitude = position.target.latitude
        
        let longitude = position.target.longitude
        
        //make the url
        var urlString = "https://ottawaparkingbackend.appspot.com/parkinglocation?distance=";
        urlString+="\(distance)";
        urlString+="&latitude=";
        urlString+="\(latitude)";
        urlString+="&longitude=";
        urlString+="\(longitude)";
        urlString+="&starMarkerlatitude=";
        urlString+="\(self.starMarker!.position.latitude)";
        urlString+="&starMarkerlongitude=";
        urlString+="\(self.starMarker!.position.longitude)";
        
        print(urlString)
        var url:NSURL! = NSURL(string: urlString)
        
        var urlRequest = NSURLRequest(URL: url, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 30)
        
        var conn = NSURLConnection(request: urlRequest, delegate: self)
        
        conn?.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        self.urlData = NSMutableData();
        self.retrievedParkingInfo = [];
        conn?.start()
            }
        }
    }
  
    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        
        let parkingInfo = marker.userData as! ParkingInfo
        if(parkingInfo.parkingType == ParkingType.parkingLot){
        
            var parkingLotDetailViewController = ParkingLotDetailViewController(nibName: "ParkingLotDetailViewController", bundle: NSBundle.mainBundle())
            parkingLotDetailViewController.parkingInfo = parkingInfo
            parkingLotDetailViewController.myLocation = self.mapView.myLocation
        
            let navigationCtl = UINavigationController(rootViewController: parkingLotDetailViewController)
            self.presentViewController(navigationCtl, animated: true, completion: nil)
        }else{
            var onStreetParkingDetailViewController = OnStreetParkingDetailViewController(nibName: "OnStreetParkingDetailViewController", bundle: NSBundle.mainBundle())
            onStreetParkingDetailViewController.parkingInfo = parkingInfo
            onStreetParkingDetailViewController.myLocation = self.mapView.myLocation
            
            let navigationCtl = UINavigationController(rootViewController: onStreetParkingDetailViewController)
            self.presentViewController(navigationCtl, animated: true, completion: nil)
        }

    }
    func mapView(mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        if(!marker.isEqual(self.starMarker)){
        
        var textView = UIView();
        var btnView = UIView();
        var view = UIView();
        let oneParkingInfo = marker.userData as! ParkingInfo
        var title = marker.title
        var newTitle = ""
        if(oneParkingInfo.canParkNow){
           newTitle = title! + " (You can park here now)"
            
        }else{
           newTitle = title! + " (You cannot park here now)"
        }

        var titleLable = UILabel();
            
        var nsTitleLabelText = newTitle as NSString
            
        var titleSize = nsTitleLabelText.sizeWithAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(12)])
        titleLable.frame = CGRectMake(0,0,titleSize.width,titleSize.height)
        var attributedTitle = NSMutableAttributedString(string: newTitle)
        attributedTitle.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(12), range: NSMakeRange(0, nsTitleLabelText.length));
        attributedTitle.addAttribute(NSForegroundColorAttributeName, value: (oneParkingInfo.canParkNow ? UIColor.greenColor() : UIColor.redColor()), range: NSMakeRange( (title! as NSString).length, nsTitleLabelText.length - (title! as NSString).length) );
        titleLable.attributedText = attributedTitle
        ///////
        var desLableText = marker.snippet;
        var desLable = UILabel();
        desLable.font = UIFont.systemFontOfSize(10);
        var nsDesLableText = NSString(string: desLableText!)
        var desSize = nsDesLableText.sizeWithAttributes([NSFontAttributeName: desLable.font])
        desLable.frame = CGRectMake(0, titleLable.frame.height+1,desSize.width,desSize.height)
        desLable.text = desLableText;
        
        textView.addSubview(titleLable)
        textView.addSubview(desLable)
        textView.frame = CGRectMake(0,0,(titleLable.frame.width > desLable.frame.width ? titleLable.frame.width:desLable.frame.width),titleLable.frame.height+desLable.frame.height+1)
        
        print(textView.frame)
        
        var button = UIButton(type: .DetailDisclosure);
        
        //button.addTarget(self, action: #selector(ViewController.didTapInfoButton), forControlEvents: .TouchUpInside)
        button.frame = CGRectMake(0,0,textView.frame.height/2.0,textView.frame.height/2.0)
        print(button.frame)
        btnView.addSubview(button)
        btnView.frame = CGRectMake(textView.frame.width+8,(textView.frame.height - button.frame.height)/2.0,button.frame.width,button.frame.height)
        view.addSubview(textView)
        view.addSubview(btnView)
        view.frame = CGRectMake(0,0,textView.frame.width+btnView.frame.width+8,textView.frame.height)
        print(textView.frame)
        print(button.frame)
        return view;
        }else{
            return nil;
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
    func connectionDidFinishLoading(connection: NSURLConnection){
        print("完成加载")
        do{
            let json = try NSJSONSerialization.JSONObjectWithData(self.urlData, options: .AllowFragments)
            let jsonDic = json as? NSDictionary
            
            let onStreetParkings = jsonDic?.objectForKey("onstreetparking") as? NSArray
            let parkingLots = jsonDic?.objectForKey("parkinglot") as? NSArray
            for item in onStreetParkings!{//refine??????????
                let oneOnStreetParking = item as? NSDictionary
                let oneParkingInfo = ParkingInfo(parkingType: ParkingType.onStreetParking, latitude: oneOnStreetParking?.objectForKey("latitude") as! String, longitude: oneOnStreetParking?.objectForKey("longitude") as! String, forCharge: oneOnStreetParking?.objectForKey("forcharge") as! Bool, address: oneOnStreetParking?.objectForKey("address") as! String, distance:  oneOnStreetParking?.objectForKey("distance") as! Int, canParkNow: oneOnStreetParking?.objectForKey("canParkNow") as! Bool)
                oneParkingInfo.id = (oneOnStreetParking?.objectForKey("id") as! NSString).integerValue
                self.retrievedParkingInfo.append(oneParkingInfo)
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2DMake((oneParkingInfo.latitude as NSString).doubleValue, (oneParkingInfo.longitude as NSString).doubleValue)
                marker.appearAnimation = kGMSMarkerAnimationPop
                if(oneParkingInfo.forCharge){
                    marker.icon = UIImage(named: "onstreetparking_forcharge")
                }else{
                    marker.icon = UIImage(named: "onstreetparking_free")
                }
                marker.title = "On-Street Parking"
                marker.snippet = "Near " + oneParkingInfo.address
                marker.userData = oneParkingInfo
                marker.map = self.mapView

                print(oneParkingInfo.id)
            }
            for item in parkingLots!{//refine??????????
                let oneParkingLot = item as? NSDictionary
                let oneParkingInfo = ParkingInfo(parkingType: ParkingType.parkingLot, latitude: oneParkingLot?.objectForKey("latitude") as! String, longitude: oneParkingLot?.objectForKey("longitude") as! String, forCharge: oneParkingLot?.objectForKey("forcharge") as! Bool, address: oneParkingLot?.objectForKey("address") as! String, distance:  oneParkingLot?.objectForKey("distance") as! Int, canParkNow: oneParkingLot?.objectForKey("canParkNow") as! Bool)
                oneParkingInfo.lic = (oneParkingLot?.objectForKey("lic") as? NSString)?.integerValue
                oneParkingInfo.company = oneParkingLot?.objectForKey("company") as? String
                oneParkingInfo.name = oneParkingLot?.objectForKey("name") as? String
                oneParkingInfo.paymentOption = oneParkingLot?.objectForKey("paymentoption") as? String
                oneParkingInfo.rules = oneParkingLot?.objectForKey("rules") as? String
                oneParkingInfo.type = oneParkingLot?.objectForKey("type") as? String
                oneParkingInfo.openTime = oneParkingLot?.objectForKey("openTime") as? String
                oneParkingInfo.hasPhoto = oneParkingLot?.objectForKey("hasphoto") as? Bool
                self.retrievedParkingInfo.append(oneParkingInfo)
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2DMake((oneParkingInfo.latitude as NSString).doubleValue, (oneParkingInfo.longitude as NSString).doubleValue)
                marker.appearAnimation = kGMSMarkerAnimationPop
                if(oneParkingInfo.forCharge){
                    marker.icon = UIImage(named: "parkinglot_forcharge")
                }else{
                    marker.icon = UIImage(named: "parkinglot_free")
                }
                //如果company不为空，那就前面加一个空格
                if(oneParkingInfo.company! != ""){
                    marker.title = " " + oneParkingInfo.company! + " " + oneParkingInfo.name!
                }else{
                    marker.title = " " + oneParkingInfo.name!
                }
                marker.snippet = " Near " + oneParkingInfo.address
                marker.userData = oneParkingInfo
                marker.map = self.mapView

                
            }
            
        }catch var error as NSError{
            print(error.description)
            print("----------%%%%%%%%%%%%--")
            
        }
        print("-------------")
        print(self.retrievedParkingInfo.count)
        print("-------------")
        self.activityIndicator.stopAnimating()
        
        dispatch_semaphore_signal(self.semaphore)
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        print("加载失败")
         self.activityIndicator.stopAnimating()
         dispatch_semaphore_signal(self.semaphore)
    }

}
