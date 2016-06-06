//
//  ViewController.swift
//  Checkpoint Clock
//
//  Created by Clarence Westberg on 12/16/15.
//  Copyright © 2015 Clarence Westberg. All rights reserved.
//

import UIKit
//import CoreBluetooth

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var timeLbl: UILabel!
   
    @IBOutlet weak var splitTable: UITableView!
    
    var items: [String] = []
    var timeUnit = "seconds"
    var delayTimer = NSTimer()
    var timeUp = true
    
    // Bluetooth EZ-Key
    var keys = [UIKeyCommand]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.splitTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        _ = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self,
            selector: #selector(ViewController.updateTimeLabel), userInfo: nil, repeats: true)
        
        // Bluetooth EZ-Key
        // "w" is pin 8 of the Bluetooth EZ-key chip
        keys.append(UIKeyCommand(input: "w", modifierFlags: [], action:  #selector(ViewController.keyPressed(_:))))

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // Bluetooth EZ-Key
    
    override var keyCommands: [UIKeyCommand]? {
        get {
            return keys
        }
    }

    @IBAction func shareBtn(sender: AnyObject) {
        
        print("sender \(sender)")
        var message = ""
        for item in self.items {
            message = message + item + "\r\n"
        }
        print("Items contents \r\n \(message)")
        let firstActivityItem = "\(message)"
        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [firstActivityItem], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = sender as? UIView
        presentViewController(activityViewController, animated:true, completion: nil)



    }
    // Split functions
    func keyPressed(command: UIKeyCommand) {
        print("key pressed")
        self.splitActions()

//        self.items.insert(timeLbl.text!,atIndex:0)
//        self.splitTable.reloadData()
    }
    @IBAction func splitBtn(sender: AnyObject) {
        self.splitActions()
//        if timeUp == true {
//            self.items.insert(timeLbl.text!,atIndex:0)
//            self.splitTable.reloadData()
//            timeUp = false
//            // start the timer
//            delayTimer = NSTimer.scheduledTimerWithTimeInterval(0.7, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
//        }

    }
    func splitActions(){
        if timeUp == true {
            let splitTime = SplitTime(carNumber: 0,inTime: timeLbl.text!, ta: 0)
            self.items.insert(timeLbl.text!,atIndex:0)
            self.splitTable.reloadData()
            timeUp = false
            // start the timer
            delayTimer = NSTimer.scheduledTimerWithTimeInterval(0.7, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        }

    }
    func timerAction(){
        timeUp = true
        delayTimer.invalidate()
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
        
//        print("second = \(dateComponents.second)")
        

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
    

//    ==========================================
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
            let ta = actionSheetController.textFields![1]
 
            var item = self.items[sender]
            if ta.text! == "TA " {
                item = "\(item),\(carNumber.text!)"

            }
            else {
                item = "\(item),\(carNumber.text!),\(ta.text!)"
            }
            
            self.items[sender] = item
            self.splitTable.reloadData()
        }
        actionSheetController.addAction(nextAction)
        
        let deletaAllAction: UIAlertAction = UIAlertAction(title: "Delete All", style: .Default) { action -> Void in
            //Do some stuff
            self.items = []
            self.splitTable.reloadData()
        }
        actionSheetController.addAction(deletaAllAction)
        
        //Add a text field
        actionSheetController.addTextFieldWithConfigurationHandler { textField -> Void in
            //TextField configuration
            textField.text = "Car # "
            textField.textColor = UIColor.blueColor()
//            textField.keyboardType = UIKeyboardType.NumberPad
        }
        
        actionSheetController.addTextFieldWithConfigurationHandler { textField -> Void in
            //TextField configuration
            textField.text = "TA "
            textField.textColor = UIColor.blueColor()
//            textField.keyboardType = UIKeyboardType.NumberPad
        }
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    

    @IBAction func openBtn(sender: AnyObject) {
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Alert", message: "Open Control", preferredStyle: .Alert)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Do some stuff
        }
        actionSheetController.addAction(cancelAction)
        
        //Create and add the Open action
        let openAction: UIAlertAction = UIAlertAction(title: "Open", style: .Default) { action -> Void in
            //Do some stuff
            let controlNumber = actionSheetController.textFields![0]
            let item = "Opened \(controlNumber.text!) at \(self.timeLbl.text!)"
            self.items.insert(item,atIndex:0)
            self.splitTable.reloadData()

        }
        actionSheetController.addAction(openAction)
        
        
        //Add a text field
        actionSheetController.addTextFieldWithConfigurationHandler { textField -> Void in
            //TextField configuration
            textField.text = "Control # "
            textField.textColor = UIColor.blueColor()
//            textField.keyboardType = UIKeyboardType.NumberPad
        }
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        
    }
    
    @IBAction func closeBtn(sender: AnyObject) {
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Alert", message: "Close Control", preferredStyle: .Alert)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Do some stuff
        }
        actionSheetController.addAction(cancelAction)
        
        //Create and add the Open action
        let openAction: UIAlertAction = UIAlertAction(title: "Close", style: .Default) { action -> Void in
            //Do some stuff
            let controlNumber = actionSheetController.textFields![0]
            let item = "Closed \(controlNumber.text!) at \(self.timeLbl.text!)"
            self.items.insert(item,atIndex:0)
            self.splitTable.reloadData()
            
        }
        actionSheetController.addAction(openAction)
        
        
        //Add a text field
        actionSheetController.addTextFieldWithConfigurationHandler { textField -> Void in
            //TextField configuration
            textField.text = "Control # "
            textField.textColor = UIColor.blueColor()
//            textField.keyboardType = UIKeyboardType.NumberPad
        }
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        
    }
}

struct SplitTime {
    var carNumber = 0
    var inTime = "12:00:00"
    var ta = 0
}

