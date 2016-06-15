//
//  ViewController.swift
//  Checkpoint Clock
//
//  Created by Clarence Westberg on 12/16/15.
//  Copyright © 2015 Clarence Westberg. All rights reserved.
//

import UIKit
import MessageUI
import GameController

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var timeLbl: UILabel!
   
    @IBOutlet weak var splitTable: UITableView!
    
    @IBOutlet weak var offsetStepper: UIStepper!
    @IBOutlet weak var offsetStepperLabel: UILabel!
    
//    var items: [String] = []
    var splits: [SplitTime] = []
    var controls: [Control] = []
    var timeUnit = "seconds"
    var delayTimer = NSTimer()
    var timeUp = true
    
    // Bluetooth EZ-Key
    var keys = [UIKeyCommand]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.splitTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        _ = NSTimer.scheduledTimerWithTimeInterval(0.02, target: self,
            selector: #selector(ViewController.updateTimeLabel), userInfo: nil, repeats: true)
        
        // GameControler
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.controllerDidConnect(_:)), name: "GCControllerDidConnectNotification", object: nil)
        
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
        
//        print("sender \(sender)")
        let mailString = NSMutableString()
        mailString.appendString("Car Number,Time In,Ta\n")

        for split in self.splits {
            mailString.appendString("\(split.carNumber),\(split.inTime),\(split.ta)\n")
        }
        
        mailString.appendString("Control Number,Open,Close\n")
        for control in controls {
            mailString.appendString("\(control.controlNumber),\(control.openTime),\(control.closeTime)\n")
        }

        let data = mailString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        // Unwrapping the optional.
        if let content = data {
            print("NSData: \(content)")
        }
        
        let emailController = MFMailComposeViewController()
        emailController.mailComposeDelegate = self
        emailController.setSubject("CSV File")
        emailController.setMessageBody("", isHTML: false)
        
        // Attaching the .CSV file to the email.
        emailController.addAttachmentData(data!, mimeType: "text/csv", fileName: "Control Log")

        // If the view controller can send the email.
        // This will show an email-style popup that allows you to enter
        // Who to send the email to, the subject, the cc's and the message.
        // As the .CSV is already attached, you can simply add an email
        // and press send.
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(emailController, animated: true, completion: nil)
        }


    }
    // Delegate requirement

    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
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
    }
    func splitActions(){
        if timeUp == true {
            let splitTime = SplitTime(carNumber: 0,inTime: timeLbl.text!, ta: 0, controlNumber: 1,note: "")
            self.splits.insert(splitTime,atIndex:0)
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
        offsetStepperLabel.text = "\(Int(offsetStepper.value))"
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
        let secondsToAdd = (offsetStepper.value * 0.1)
        let correctedDate = currentDate.dateByAddingTimeInterval(Double(secondsToAdd))

        let calendar = NSCalendar.currentCalendar()
        let dateComponents = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second, NSCalendarUnit.Nanosecond], fromDate: correctedDate)
        
        let millisecond = Int(Double(dateComponents.nanosecond)/1000000)
        let mytime = dateComponents.second * 1000 + millisecond
        let cents = trunc((Double(mytime) * 1.66667)/1000)
//        print("second = \(dateComponents.second) \(mytime) \(cents)")
        

        let unit = Double(dateComponents.second)
        let second = Int(unit)
        let secondString = String(format: "%02d", second)

//        let cent = Int((unit * (1.6667)))
        let centString = String(format: "%02d", Int(cents))
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
    
    // Table ----------------------------------------------------
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.splits.count
//        return self.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.splitTable.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        let split = self.splits[indexPath.row]
        cell.textLabel?.text = "Car: \(split.carNumber) Time: \(split.inTime) TA: \(split.ta)"
//        cell.textLabel?.text = self.items[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
        showAlertTapped(indexPath.row)
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
//            items.removeAtIndex(indexPath.row)
            splits.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    // End Table
    

//    ==========================================
    @IBAction func showAlertTapped(sender: Int) {
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Enter/Edit", message: "Car Number\nTA\nNote", preferredStyle: .Alert)
        
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
            let note = actionSheetController.textFields![2]
            
            var split = self.splits[sender]
            if carNumber.text! != "" {
                let sa = carNumber.text!
                if let cn = Int(sa) {
                    split.carNumber = cn
                }
//                let sa = carNumber.text!.stringByReplacingOccurrencesOfString("Car # ", withString: "")
//                
//                if let cn = Int(sa) {
//                    split.carNumber = cn
//                }
            }
            if ta.text! != "TA " {
                let sa = ta.text!.stringByReplacingOccurrencesOfString("TA ", withString: "")
                if let ta = Int(sa) {
                    split.ta = ta
                }
            }
            split.note = note.text!
//            if note.text! != "Note " {
//                let sa = note.text!.stringByReplacingOccurrencesOfString("Note ", withString: "")
//                split.note = sa
//                
//            }
            
//            var item = self.items[sender]
//            if ta.text! == "TA " {
//                item = "\(item),\(carNumber.text!)"
//
//            }
//            else {
//                item = "\(item),\(carNumber.text!),\(ta.text!)"
//            }
//            
//            self.items[sender] = item
            self.splits[sender] = split
            self.splitTable.reloadData()
        }
        actionSheetController.addAction(nextAction)
        
        let deletaAllAction: UIAlertAction = UIAlertAction(title: "Delete All", style: .Default) { action -> Void in
            //Do some stuff
//            self.items = []
            self.splits = []
            self.splitTable.reloadData()
        }
        actionSheetController.addAction(deletaAllAction)
        
        //Add a text field
        actionSheetController.addTextFieldWithConfigurationHandler { textField -> Void in
            //TextField configuration
            let split = self.splits[sender]
            if split.carNumber == 0 {
                textField.placeholder = "Car Number:"
            }
            else {
                textField.text = "\(split.carNumber)"
            }
            textField.textColor = UIColor.blueColor()
            textField.keyboardType = UIKeyboardType.NumberPad
        }
        
        actionSheetController.addTextFieldWithConfigurationHandler { textField -> Void in
            //TextField configuration
            let split = self.splits[sender]
            if split.ta == 0 {
                textField.placeholder = "TA:"
            }
            else {
                textField.text = "\(split.ta)"
            }
            
            textField.textColor = UIColor.blueColor()
            textField.keyboardType = UIKeyboardType.NumberPad
        }
        
        
        actionSheetController.addTextFieldWithConfigurationHandler { textField -> Void in
            //TextField configuration
            let split = self.splits[sender]
            if split.note == "" {
                textField.placeholder = "Note:"
            }
            else {
                textField.text = "\(split.note)"
            }
            textField.textColor = UIColor.blueColor()
        }
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    

    @IBAction func openBtn(sender: AnyObject) {
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Open", message: "Control Number", preferredStyle: .Alert)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Do some stuff
        }
        actionSheetController.addAction(cancelAction)
        
        //Create and add the Open action
        let openAction: UIAlertAction = UIAlertAction(title: "Open", style: .Default) { action -> Void in
            //Do some stuff
            print(actionSheetController.textFields![0])
            let controlNumber = actionSheetController.textFields![0].text!
            if let cn = Int(controlNumber) {
                let control = Control(controlNumber: cn,openTime: self.timeLbl.text!, closeTime: "")
                self.controls.append(control)
            }
            
//            let control = Control(controlNumber: controlNumber!,openTime: self.timeLbl.text!, closeTime: "")
//            self.controls.append(control)
//            let item = "Opened \(controlNumber.text!) at \(self.timeLbl.text!)"
//            self.items.insert(item,atIndex:0)
//            self.splitTable.reloadData()

        }
        actionSheetController.addAction(openAction)
        
        
        //Add a text field
        actionSheetController.addTextFieldWithConfigurationHandler { textField -> Void in
            //TextField configuration
            textField.text = ""
            textField.textColor = UIColor.blueColor()
            textField.keyboardType = UIKeyboardType.NumberPad
        }
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        
    }
    
    @IBAction func closeBtn(sender: AnyObject) {
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Close", message: "Control Number", preferredStyle: .Alert)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Do some stuff
        }
        actionSheetController.addAction(cancelAction)
        
        //Create and add the Open action
        let openAction: UIAlertAction = UIAlertAction(title: "Close", style: .Default) { action -> Void in
            //Do some stuff
            let controlNumber = actionSheetController.textFields![0].text!
            
            if let cn = Int(controlNumber) {
                let control = Control(controlNumber: cn,openTime: "", closeTime: self.timeLbl.text!)
                self.controls.append(control)
            }
            
//            let control = Control(controlNumber: controlNumber!,openTime: "", closeTime: self.timeLbl.text!)
//            self.controls.append(control)

            //            let controlNumber = actionSheetController.textFields![0]
//            let item = "Closed \(controlNumber.text!) at \(self.timeLbl.text!)"
//            self.items.insert(item,atIndex:0)
//            self.splitTable.reloadData()
            
        }
        actionSheetController.addAction(openAction)
        
        
        //Add a text field
        actionSheetController.addTextFieldWithConfigurationHandler { textField -> Void in
            //TextField configuration
            textField.text = ""
            textField.textColor = UIColor.blueColor()

            textField.keyboardType = UIKeyboardType.NumberPad
        }
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        
    }
    
    //    Game Controller
    
    func controllerDidConnect(notification: NSNotification) {
        
        let controller = notification.object as! GCController
//        print("controller is \(controller)")
//        print("game on ")
//        print("\(controller.gamepad!.buttonA.pressed)")
        
        controller.gamepad?.dpad.up.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed  && value > 0.2 {
                print("dpad.up")
                
            }
        }
        
        controller.gamepad?.dpad.down.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed && value > 0.2  {
                print("dpad.up")
            }
        }
        
        controller.gamepad?.dpad.left.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed  && value > 0.2 {
                print("dpad.left")
                
            }
        }
        
        controller.gamepad?.dpad.right.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed && value > 0.2  {
                print("dpad.right")
                
            }
        }
        
        controller.gamepad?.buttonA.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed {
                print("buttonA")
                self.splitBtn(self)
            }
        }
        //        controller.gamepad?.rightShoulder
        controller.gamepad?.buttonB.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed {
                print("buttonB")
                
            }
        }
        
        controller.gamepad?.buttonY.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed {
                print("buttonY")
            }
        }
        
        
        controller.gamepad?.buttonX.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed {
                print("buttonX")
                
            }
        }
        controller.gamepad?.rightShoulder.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed {
                print("rightShoulder")
                self.splitBtn(self)
            }
        }
    }
}

struct SplitTime {
    var carNumber = 0
    var inTime = "12:00:00"
    var ta = 0
    var controlNumber = 1
    var note = ""
}

struct Control {
    var controlNumber = 0
    var openTime = "12:00:00"
    var closeTime = "12:00:00"
}

