//
//  WelcomeInterfaceViewController.swift
//  OttawaParking
//
//  Created by 赵嘉伟 on 08/10/2016.
//  Copyright © 2016 赵嘉伟. All rights reserved.
//

import UIKit

class WelcomeInterfaceViewController: UIViewController {
    
    //Attributes
    @IBOutlet var startBtn:UIButton!
    
    @IBOutlet var titleImage:UIImageView!
    
    @IBOutlet var labLogo:UIImageView!
    
    @IBOutlet var labCopyrightLabel:UILabel!
    
    @IBOutlet var transitLogo:UIImageView!
    //Methods
    //Actors
    @IBAction func start(){
        var mapViewCtl =  MapViewController(nibName:"MapViewController", bundle: NSBundle.mainBundle());
        self.presentViewController(mapViewCtl, animated: true, completion: nil)
    }
    //
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let titleImgPath = NSBundle.mainBundle().pathForResource("title", ofType: "png")
        if(titleImgPath != nil){
            var image = UIImage(contentsOfFile: titleImgPath!)
            self.titleImage.image  = image
        }
        self.titleImage.contentMode = .ScaleToFill
        
        let labLogoPath = NSBundle.mainBundle().pathForResource("labLogo", ofType: "png")
        if(labLogoPath != nil){
            var image = UIImage(contentsOfFile: labLogoPath!)
            self.labLogo.image  = image
        }
        self.labLogo.contentMode = .ScaleToFill
        
        let transitLogoPath = NSBundle.mainBundle().pathForResource("transit", ofType: "jpg")
        if(transitLogoPath != nil){
            var image = UIImage(contentsOfFile: transitLogoPath!)
            self.transitLogo.image  = image
        }
        self.transitLogo.contentMode = .ScaleToFill
        
        let attributedLabCopyrightLabelText = NSMutableAttributedString(string: "Copyright © 2016. PARADISE Research Lab.")
        attributedLabCopyrightLabelText.addAttribute(NSFontAttributeName, value: UIFont.italicSystemFontOfSize(12), range: NSMakeRange(18,8));
        self.labCopyrightLabel.attributedText = attributedLabCopyrightLabelText
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
