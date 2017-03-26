//
//  ManageRecPlacesViewController.swift
//  OttawaParking
//
//  Created by 赵嘉伟 on 9/13/16.
//  Copyright © 2016 赵嘉伟. All rights reserved.
//

import UIKit
import CoreData
class ManageRecPlacesViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    //Attributes
    @IBOutlet var recordedPlacesTableView:UITableView!
    
    var recordedPlaceObjs:[RecordedPlace] = []
    
    var context:NSManagedObjectContext!
    //Methods
    //Selectors
    
    func back(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    func edit(){
        if(self.navigationItem.rightBarButtonItem?.title! == "Edit"){
            self.navigationItem.rightBarButtonItem?.title = "Done"
            self.recordedPlacesTableView.setEditing(true, animated: true)
        }else{
            self.navigationItem.rightBarButtonItem?.title = "Edit"
            self.recordedPlacesTableView.setEditing(false, animated: true)
        }
    }

    //
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .Plain, target: self, action: #selector(ManageRecPlacesViewController.back))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action:#selector(ManageRecPlacesViewController.edit))
        
        
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.blackColor()
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.blackColor()
        
        if( (UIDevice.currentDevice().systemVersion as NSString).doubleValue >= 7.0 ){
            
            self.edgesForExtendedLayout = UIRectEdge.None
            
        }
        self.title = "Recorded Places"
        self.recordedPlacesTableView.delegate = self;
        self.recordedPlacesTableView.dataSource = self;
        
        //Load the recorded places
        context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        var fetchRequest = NSFetchRequest()
        var recordedPlaceEntity =   NSEntityDescription.entityForName("RecordedPlace", inManagedObjectContext: context)
        fetchRequest.entity = recordedPlaceEntity
        let predicate = NSPredicate(format: "placeID MATCHES %@", argumentArray: [".*"])
        fetchRequest.predicate = predicate
        do{
            self.recordedPlaceObjs = (try context.executeFetchRequest(fetchRequest) as! [RecordedPlace]).reverse()
        }catch var error as NSError{
            print(error.description)
        }
        self.recordedPlacesTableView.tableFooterView = UIView()
        
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
        return 50.0
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.recordedPlaceObjs.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let identifier:String = "recordedPlaceCell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier)
        if(cell == nil){
            cell = UITableViewCell(style: .Default, reuseIdentifier: identifier)
        }
        cell!.accessoryType = .None
        cell!.textLabel?.numberOfLines = 0
        cell!.textLabel?.font = UIFont.systemFontOfSize(15.0)
        
        
        cell!.textLabel?.text = self.recordedPlaceObjs[indexPath.row].stringofAttributedFullText

        
        return cell!
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        self.context.deleteObject(recordedPlaceObjs[indexPath.row])
        
        do{
            try self.context.save()
            
            self.recordedPlaceObjs.removeAtIndex(indexPath.row)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        catch var error as NSError{
            print(error.description)
        }

    }
}
