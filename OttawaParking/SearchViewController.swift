//
//  SearchViewController.swift
//  OttawaParking
//
//  Created by 赵嘉伟 on 16/7/12.
//  Copyright © 2016年 赵嘉伟. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreData
class SearchViewController: UIViewController,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource {
    //Attributes 
    
    @IBOutlet var searchBar:UISearchBar!
    
    @IBOutlet var resultsTableView:UITableView!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var previousViewedLabel:UILabel!
    var text:String?
    
    var placesClient: GMSPlacesClient? = GMSPlacesClient()
    
    var timer:NSTimer?
    
    var semaphore:dispatch_semaphore_t = dispatch_semaphore_create(1)
    
    var isFoundResultFromInternet:Bool = true
    
    let app = UIApplication.sharedApplication().delegate as!AppDelegate
    
    var context:NSManagedObjectContext!
    
    //Will find the places in this area bounds in priority
    var bounds:GMSCoordinateBounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2DMake(45.431554677260706, -75.70623591542244), coordinate: CLLocationCoordinate2DMake(45.412714960442138, -75.670592039823532))
    //Results which are found
    var resultPlaces:[AutocompletePrediction] = []
    
    //Places which are recorded
    var recordedPlaces:[AutocompletePrediction] = []
    
    //RecordedPlace Objects
    var recordedPlaceObjs:[RecordedPlace] = []
    
    var globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    //Methods
    
    //Selectors
    //Start finding the places
    func startFinding(){
        
         dispatch_async(globalQueue){
        //semaphore is used to synchronize
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER)
            dispatch_async(dispatch_get_main_queue()){
        //self.searchBar.endEditing(true);
        self.resultPlaces = []//the data sourse is refresh
        self.resultsTableView.reloadData()
        self.previousViewedLabel.text = ""
        self.setTableFooterView(false)
        if(self.searchBar.text! != ""){
            self.activityIndicator.startAnimating()
            let filter = GMSAutocompleteFilter()
            filter.type = .NoFilter
            var searchText = self.searchBar.text!
            self.placesClient?.autocompleteQuery(searchText, bounds: self.bounds, filter: filter, callback: { (results, error: NSError?) -> Void in
                print("!!!!!!!!!!!!")
                if let error = error {
                    print("Autocomplete error \(error)")
                }
                
             
                
                //When the Internet is unavailabel, the results is nil.
                if(results != nil && results?.count != 0){                for result in results! {
                    if let result = result as? GMSAutocompletePrediction {
                        self.resultPlaces.append( AutocompletePrediction(placeID: result.placeID!, attributedFullText: result.attributedFullText) )
                    }
                    }
                    self.resultsTableView.reloadData()
                    self.previousViewedLabel.text = "Results:"
                    self.activityIndicator.stopAnimating()
                    self.setTableFooterView(true)
                    
                }else if(results?.count == 0){
                    print("有网，没找到")
                    ///告知未找到，设置只有一条数据源，显示未找到
                    print("null")
                    self.resultPlaces.append(AutocompletePrediction(placeID: "-1", attributedFullText: NSAttributedString(string: "Cannot find any locations")))
                    self.isFoundResultFromInternet = false
                    
                    self.resultsTableView.reloadData()
                    self.previousViewedLabel.text = "Results:"
                    self.activityIndicator.stopAnimating()
                    self.setTableFooterView(false)
                }else{ //results is nil
                    
                    //提示：检查网络连接
                    self.resultPlaces.append(AutocompletePrediction(placeID: "-1", attributedFullText: NSAttributedString(string: "ERROR! Please check your network")))
                    self.isFoundResultFromInternet = false
                    self.resultsTableView.reloadData()
                    self.previousViewedLabel.text = "Results:"
                    self.activityIndicator.stopAnimating()
                    self.setTableFooterView(false)
                }
                dispatch_semaphore_signal(self.semaphore)
            })
            //print("??????????????")
        }else{//If the search text is empty
            //If there are some recorded places
            if(!self.recordedPlaces.isEmpty){
                //set self.resultPlaces
                 self.resultPlaces = self.recordedPlaces
                //reload
                self.isFoundResultFromInternet = false
                self.resultsTableView.reloadData()
                self.previousViewedLabel.text = "Previously Viewed:"
                self.setTableFooterView(false)
            }else{//If there are no recorded places
                self.resultsTableView.reloadData()/////////
                self.previousViewedLabel.text = ""
                self.setTableFooterView(false)
            }
             dispatch_semaphore_signal(self.semaphore)
        }
        }
        }
    }
    //
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.searchBar.delegate = self
        self.resultsTableView.delegate = self
        self.resultsTableView.dataSource = self
        self.resultsTableView.tableHeaderView = UIView(frame:CGRectMake(0,0,100,20));
        //self.previousViewedLabel.hidden = true
        //self.setTableFooterView(false)
        self.searchBar.text = self.text
        self.searchBar.becomeFirstResponder()
        self.searchBar.showsCancelButton = true
        
        // register for TableViewCell
        self.resultsTableView.registerClass(UITableViewCell.self,forCellReuseIdentifier: "ResultCell")
        //self.resultsTableView.layoutMargins = UIEdgeInsetsZero
        //self.resultsTableView.separatorInset = UIEdgeInsetsZero
        //set the footer of the table
        //self.setTableFooterView()
        self.placesClient = GMSPlacesClient()
        //Load the recorded places
        self.context = self.app.managedObjectContext
        var fetchRequest = NSFetchRequest()
        var recordedPlaceEntity =   NSEntityDescription.entityForName("RecordedPlace", inManagedObjectContext: self.context)
        fetchRequest.entity = recordedPlaceEntity
        let predicate = NSPredicate(format: "placeID MATCHES %@", argumentArray: [".*"])
        fetchRequest.predicate = predicate
        do{
            self.recordedPlaceObjs = try self.context.executeFetchRequest(fetchRequest) as! [RecordedPlace]
            for item in self.recordedPlaceObjs.reverse(){
                self.recordedPlaces.append( AutocompletePrediction(placeID: item.placeID, attributedFullText: NSAttributedString(string: item.stringofAttributedFullText)))
            }
        }catch var error as NSError{
            print(error.description)
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
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
        self.resultPlaces = []
        self.setTableFooterView(false)
        
        dispatch_async(globalQueue){
            //semaphore is used to synchronize
            dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER)
            dispatch_async(dispatch_get_main_queue()){
        //If the search text is not empty
        if(searchBar.text! != ""){
        self.activityIndicator.startAnimating()

        let filter = GMSAutocompleteFilter()
        filter.type = .NoFilter
        self.placesClient?.autocompleteQuery(searchBar.text!, bounds: self.bounds, filter: filter, callback: { (results, error: NSError?) -> Void in
            
            //Always execute whether the internet is available or not.
            
            if let error = error {
                print("Autocomplete error \(error)")
            }
            if(results != nil && results?.count != 0){
                for result in results! {
                    if let result = result as? GMSAutocompletePrediction {
                        self.resultPlaces.append(AutocompletePrediction(placeID: result.placeID!, attributedFullText: result.attributedFullText))
                    }
                }
                self.previousViewedLabel.text = "Results:"
                self.resultsTableView.reloadData()
                self.setTableFooterView(true)
            }else if(results?.count == 0){
                ///告知未找到，设置只有一条数据源，显示未找到
                print("未找到")
                self.resultPlaces.append(AutocompletePrediction(placeID: "-1", attributedFullText: NSAttributedString(string: "Cannot find any locations")))
                self.isFoundResultFromInternet = false
                self.previousViewedLabel.text = "Results:"
                self.resultsTableView.reloadData()
                self.setTableFooterView(false)
            }else{//results is nil
                
                //提示：检查网络连接
                self.resultPlaces.append(AutocompletePrediction(placeID: "-1", attributedFullText: NSAttributedString(string: "ERROR! Please check your network")))
                self.isFoundResultFromInternet = false
                self.previousViewedLabel.text = "Results:"
                self.resultsTableView.reloadData()
                self.setTableFooterView(false)
            }
            self.activityIndicator.stopAnimating()
            dispatch_semaphore_signal(self.semaphore)
        })
        }else{//If the search text is empty
            // If there are some recorded places
            if(!self.recordedPlaces.isEmpty){
                //set self.resultPlaces
                self.resultPlaces = self.recordedPlaces
                //reload
                self.isFoundResultFromInternet = false
                self.previousViewedLabel.text = "Previously Viewed:"
                self.resultsTableView.reloadData()
                self.setTableFooterView(false)
            }else{//If there are no recorded places
                self.previousViewedLabel.text = ""
                self.resultsTableView.reloadData()/////////
                self.setTableFooterView(false)
            }
         dispatch_semaphore_signal(self.semaphore)
        }
        }
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if (self.timer != nil)
        {
            if (self.timer!.valid)
            {
            self.timer!.invalidate();
            }
            self.timer = nil;
        }
        
        self.timer = NSTimer(timeInterval: 0.5, target: self, selector: #selector(SearchViewController.startFinding), userInfo: nil, repeats: false)
        NSRunLoop.currentRunLoop().addTimer(self.timer!, forMode: NSDefaultRunLoopMode)
        
               // self.resultsTableView.
    }
    // Click Cancel Button, then the notification "cancelClicked" will be sent
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        var msg = ""
        if searchBar.text != nil{
            msg = searchBar.text!
        }
    NSNotificationCenter.defaultCenter().postNotificationName("cancelClicked", object: msg)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        //Click search button, then the first result is returned
        //Need to check whether there are any results
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resultPlaces.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let identifier:String = "ResultCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier,forIndexPath: indexPath) as UITableViewCell
        
        cell.accessoryType = .None
        cell.textLabel?.numberOfLines = 0
        if(self.isFoundResultFromInternet){
            //for var i=0;i<100;i++ {
                print(self.isFoundResultFromInternet)
            //}
            cell.textLabel?.attributedText = highlightResults(self.resultPlaces[indexPath.row].attributedFullText)
            
        }else{
            //for var i=0;i<100;i++ {
                print(self.isFoundResultFromInternet)
            //}
            cell.textLabel?.text = (self.resultPlaces[indexPath.row].attributedFullText).string
            cell.textLabel?.font = UIFont.systemFontOfSize(14)
            if(indexPath.row == self.resultPlaces.count - 1){
                self.isFoundResultFromInternet = true
            }
        }

        cell.imageView?.image = UIImage(named: "tablecell_search")
        //cell.layoutMargins = UIEdgeInsetsZero
        //cell.backgroundColor = UIColor.orangeColor()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.resultsTableView.deselectRowAtIndexPath(indexPath, animated: true)
        //Select a place, then return to map view
        
        //check if there is no place in the table
        if(self.resultPlaces[indexPath.row].placeID == "-1"){
            return
        }
        
        //record the selected place
        //Check if there is a same place
        var isSelectedPlaceExisting = false
        for item in self.recordedPlaceObjs{
            if( self.resultPlaces[indexPath.row].placeID == item.placeID ){
                isSelectedPlaceExisting = true
                self.context.deleteObject(item)
                var oneRecordedPlace = NSEntityDescription.insertNewObjectForEntityForName("RecordedPlace", inManagedObjectContext: self.context) as!RecordedPlace
                oneRecordedPlace.placeID = item.placeID
                oneRecordedPlace.stringofAttributedFullText = item.stringofAttributedFullText
                do{
                    try self.context.save()
                }
                catch var error as NSError{
                    print(error.description)
                }

                break
            }
            
        }
        //
        if(!isSelectedPlaceExisting){
        var oneRecordedPlace = NSEntityDescription.insertNewObjectForEntityForName("RecordedPlace", inManagedObjectContext: self.context) as!RecordedPlace
        oneRecordedPlace.placeID = self.resultPlaces[indexPath.row].placeID
        oneRecordedPlace.stringofAttributedFullText = (self.resultPlaces[indexPath.row].attributedFullText).string
        do{
            try self.context.save()
        }
        catch var error as NSError{
            print(error.description)
        }
    }
        //post a notification with the selected place info
    NSNotificationCenter.defaultCenter().postNotificationName("placeSelected", object: self.resultPlaces[indexPath.row])
        
        //dismiss
        self.dismissViewControllerAnimated(true, completion: nil)
        
        print(indexPath.row)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 45.0
    }
    func highlightResults(fullText: NSAttributedString) -> NSMutableAttributedString{
        let regularFont = UIFont.systemFontOfSize(14)
        let boldFont = UIFont.boldSystemFontOfSize(14)
        
        //let bolded = fullText.mutableCopy() as! NSMutableAttributedString
        let bolded = NSMutableAttributedString(attributedString: fullText)
        bolded.enumerateAttribute(kGMSAutocompleteMatchAttribute, inRange: NSMakeRange(0, bolded.length), options: NSAttributedStringEnumerationOptions()) { (value, range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            let font = (value == nil) ? regularFont : boldFont
            bolded.addAttribute(NSFontAttributeName, value: font, range: range)
        }
        return bolded
    }
    
    
    func setTableFooterView(flag:Bool){
        //var tableFooterView = UIView(frame: CGRectMake(0,0,self.resultsTableView.frame.width,60))
        //tableFooterView.backgroundColor = UIColor.blueColor()
       
        if(flag){
            
            let imageView = UIImageView(frame: CGRectMake(0,0,self.resultsTableView.frame.width,60))
            
            imageView.image = UIImage(named: "poweredbygoogle")
            imageView.contentMode = .Center
            //tableFooterView.addSubview(imageView)
            self.resultsTableView.tableFooterView = imageView//tableFooterView//
        }else{
            self.resultsTableView.tableFooterView = UIView()
            
        }
    }
    /*func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var view = UIView(frame: CGRectMake(0,0,tableView.frame.width,1))
        view.backgroundColor = UIColor.lightGrayColor()
        return  view
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.5
    }*/

}
