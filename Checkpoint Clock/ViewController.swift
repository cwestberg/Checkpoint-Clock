//
//  ViewController.swift
//  Checkpoint Clock
//
//  Created by Clarence Westberg on 12/16/15.
//  Copyright © 2015 Clarence Westberg. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var timeLbl: UILabel!
   
    @IBOutlet weak var splitTable: UITableView!
    
    var items: [String] = []
    var timeUnit = "seconds"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.splitTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        _ = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self,
            selector: "updateTimeLabel", userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func splitBtn(sender: AnyObject) {
        self.items.insert(timeLbl.text!,atIndex:0)
        self.splitTable.reloadData()
    }
    
    @IBAction func stepperAction(sender: AnyObject) {
    }
    @IBAction func secondsOrCents(sender:UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            timeUnit = "seconds"
        case 1:
            timeUnit = "cents"
        default:
            break;
        }
    }
    
    func updateTimeLabel() {
        
        let currentDate = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let dateComponents = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second, NSCalendarUnit.Nanosecond], fromDate: currentDate)
        
        print("second = \(dateComponents.second)")
        

        let unit = Double(dateComponents.second)
        let second = Int(unit)
        let secondString = String(format: "%02d", second)

        let cent = Int((unit * (1.6667)))
        let centString = String(format: "%02d", cent)
        let minuteString = String(format: "%02d", dateComponents.minute)
        switch timeUnit {
        case "seconds":
            timeLbl.text = "\(dateComponents.hour):\(minuteString):\(secondString)"
        case "cents":
            timeLbl.text = "\(dateComponents.hour):\(minuteString).\(centString)"
        default:
            break;
        }

    
//          formatter.timeStyle = .MediumStyle
//        timeLbl.text = formatter.stringFromDate(NSDate())
    }
    
    // Table
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.splitTable.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        cell.textLabel?.text = self.items[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
        showAlertTapped(indexPath.row)
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            items.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    // End Table

    @IBAction func showAlertTapped(sender: Int) {
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Alert", message: "Car Number!", preferredStyle: .Alert)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Do some stuff
        }
        actionSheetController.addAction(cancelAction)
        //Create and an option action
        let nextAction: UIAlertAction = UIAlertAction(title: "Add", style: .Default) { action -> Void in
            //Do some other stuff
            let carNumber = actionSheetController.textFields![0] 
            var item = self.items[sender]
            item = "\(item) for car number: \(carNumber.text!)"
            self.items[sender] = item
            self.splitTable.reloadData()
        }
        actionSheetController.addAction(nextAction)
        //Add a text field
        actionSheetController.addTextFieldWithConfigurationHandler { textField -> Void in
            //TextField configuration
            textField.textColor = UIColor.blueColor()
            textField.keyboardType = UIKeyboardType.NumberPad
        }
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
}

