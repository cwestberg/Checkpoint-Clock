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
     @IBOutlet weak var centsSecsSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var offsetStepper: UIStepper!
    @IBOutlet weak var offsetStepperLabel: UILabel!
    
//    var items: [String] = []
    var splits: [SplitTime] = []
    var controls: [Control] = []
    var timeUnit = "cents"
    var delayTimer = Timer()
    var timeUp = true
    var bczt = Date()
    var bcztHour = 0
    var bcztMinute = 0
    
    // Bluetooth EZ-Key
    var keys = [UIKeyCommand]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.splitTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        _ = Timer.scheduledTimer(timeInterval: 0.02, target: self,
            selector: #selector(ViewController.updateTimeLabel), userInfo: nil, repeats: true)
        
        // GameControler
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.controllerDidConnect(_:)), name: NSNotification.Name(rawValue: "GCControllerDidConnectNotification"), object: nil)
        
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
    @IBAction func bcztBtn(_ sender: Any) {
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Enter", message: "BCZ Hour\nMinute", preferredStyle: .alert)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Do some stuff
        }
        actionSheetController.addAction(cancelAction)
        
        //Create and an option action
        let nextAction: UIAlertAction = UIAlertAction(title: "Add", style: .default) { action -> Void in
            //Do some other stuff
            let bczHourText = actionSheetController.textFields![0]
            let bczMinuteText = actionSheetController.textFields![1]
            
            if bczHourText.text! != "" {
                self.bcztHour = Int(bczHourText.text!)!
            }
            if bczMinuteText.text! != "" {
                self.bcztMinute = Int(bczMinuteText.text!)!
            }
        }
        actionSheetController.addAction(nextAction)
        
        //Add a text field
        actionSheetController.addTextField { textField -> Void in
            //TextField configuration
            textField.textColor = UIColor.blue
            textField.keyboardType = UIKeyboardType.numberPad
        }
        
        actionSheetController.addTextField { textField -> Void in
            //TextField configuration
            textField.textColor = UIColor.blue
            textField.keyboardType = UIKeyboardType.numberPad
        }
     //Present the AlertController
     self.present(actionSheetController, animated: true, completion: nil)

    }

    @IBAction func shareBtn(_ sender: AnyObject) {
        
//        print("sender \(sender)")
        let mailString = NSMutableString()
        mailString.append("Car Number,Time In,Ta\n")

        for split in self.splits {
            mailString.append("\(split.carNumber),\(split.inTime),\(split.ta)\n")
        }
        
        mailString.append("Control Number,Open,Close\n")
        for control in controls {
            mailString.append("\(control.controlNumber),\(control.openTime),\(control.closeTime)\n")
        }
     
     
        mailString.append("\(bcztHour):\(bcztMinute)\n")

        let data = mailString.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)
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
            self.present(emailController, animated: true, completion: nil)
        }


    }
    // Delegate requirement

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // Split functions
    func keyPressed(_ command: UIKeyCommand) {
        print("key pressed")
        self.splitActions()

//        self.items.insert(timeLbl.text!,atIndex:0)
//        self.splitTable.reloadData()
    }
    @IBAction func splitBtn(_ sender: AnyObject) {
        self.splitActions()
    }
    func splitActions(){
        if timeUp == true {
            let splitTime = SplitTime(carNumber: 0,inTime: timeLbl.text!, ta: 0, controlNumber: 1,note: "")
            self.splits.insert(splitTime,at:0)
            self.splitTable.reloadData()
            timeUp = false
            // start the timer
            delayTimer = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        }

    }
    func timerAction(){
        timeUp = true
        delayTimer.invalidate()
    }
    
    @IBAction func stepperAction(_ sender: AnyObject) {
        offsetStepperLabel.text = "\(Int(offsetStepper.value))"
    }
    
    @IBAction func secondsOrCents(_ sender:UISegmentedControl) {
     ruSure(sender)
//        switch sender.selectedSegmentIndex {
//        case 0:
//            timeUnit = "cents"
//        case 1:
//            timeUnit = "seconds"
//        default:
//            break;
//        }
    }
//     func changeSecondsOrCents(_ sender:UISegmentedControl, ok:Bool) -> Void {
//          print("\(ok)")
//
//          if ok {
//               switch sender.selectedSegmentIndex {
//               case 0:
//                    timeUnit = "cents"
//               case 1:
//                    timeUnit = "seconds"
//               default:
//                    break;
//               }
//          }
//
//     }
     
     func ruSure(_ sender:UISegmentedControl) {
          let alertController = UIAlertController(title: "Change Time Units", message: "OK to Change", preferredStyle: .alert)
          let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
               print("OK Button Pressed \(sender.selectedSegmentIndex)")
               switch sender.selectedSegmentIndex {
               case 0:
                    self.timeUnit = "cents"
               case 1:
                    self.timeUnit = "seconds"
               default:
                    break;
               }
          })
          let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
               print("Cancel Button Pressed")
               switch sender.selectedSegmentIndex {
               case 0:
                    self.centsSecsSegmentedControl.selectedSegmentIndex = 1
               case 1:
                    self.centsSecsSegmentedControl.selectedSegmentIndex = 0
               default:
                    break;
               }

          }
          alertController.addAction(ok)
          alertController.addAction(cancel)
          present(alertController, animated: true, completion: nil)
     }
    
    func updateTimeLabel() {
        let currentDate = Date()
        let secondsToAdd = (offsetStepper.value * 0.1)
        let correctedDate = currentDate.addingTimeInterval(Double(secondsToAdd))

        let calendar = Calendar.current
        let dateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.day, NSCalendar.Unit.month, NSCalendar.Unit.year, NSCalendar.Unit.weekOfYear, NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second, NSCalendar.Unit.nanosecond], from: correctedDate)
        
        let millisecond = Int(Double(dateComponents.nanosecond!)/1000000)
        let mytime = dateComponents.second! * 1000 + millisecond
        let cents = trunc((Double(mytime) * 1.66667)/1000)
//        print("second = \(dateComponents.second) \(mytime) \(cents)")
        

        let unit = Double(dateComponents.second!)
        let second = Int(unit)
        let secondString = String(format: "%02d", second)

//        let cent = Int((unit * (1.6667)))
        let centString = String(format: "%02d", Int(cents))
        let minuteString = String(format: "%02d", dateComponents.minute!)
        switch timeUnit {
        case "seconds":
            timeLbl.text = "\(dateComponents.hour!):\(minuteString):\(secondString)"
        case "cents":
            timeLbl.text = "\(dateComponents.hour!):\(minuteString).\(centString)"
        default:
            break;
        }
//     timeLbl.text = "\(dateComponents.hour!):\(minuteString):\(secondString) (.\(centString))"


    
//          formatter.timeStyle = .MediumStyle
//        timeLbl.text = formatter.stringFromDate(NSDate())
    }
    
    // Table ----------------------------------------------------
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.splits.count
//        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.splitTable.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        let split = self.splits[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = "Car: \(split.carNumber) Time: \(split.inTime) TA: \(split.ta) -\(split.note)"
//        cell.textLabel?.text = self.items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\((indexPath as NSIndexPath).row)!")
        showAlertTapped((indexPath as NSIndexPath).row)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
//            items.removeAtIndex(indexPath.row)
            splits.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    // End Table
    

//    ==========================================
    @IBAction func showAlertTapped(_ sender: Int) {
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Enter/Edit", message: "Car Number\nTA\nNote", preferredStyle: .alert)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Do some stuff

        }

        actionSheetController.addAction(cancelAction)
        //Create and an option action
        let nextAction: UIAlertAction = UIAlertAction(title: "Add", style: .default) { action -> Void in
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
                let sa = ta.text!.replacingOccurrences(of: "TA ", with: "")
                if let ta = Int(sa) {
                    split.ta = ta
                }
            }
            split.note = note.text!
//            print("note: \(note.text) st \(split.note)")
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
        
        let deletaAllAction: UIAlertAction = UIAlertAction(title: "Delete All", style: .default) { action -> Void in
            //Do some stuff
//            self.items = []
            self.splits = []
            self.splitTable.reloadData()
        }
        actionSheetController.addAction(deletaAllAction)
        
        //Add a text field
        actionSheetController.addTextField { textField -> Void in
            //TextField configuration
            let split = self.splits[sender]
            if split.carNumber == 0 {
                textField.placeholder = "Car Number:"
            }
            else {
                textField.text = "\(split.carNumber)"
            }
            textField.textColor = UIColor.blue
            textField.keyboardType = UIKeyboardType.numberPad
        }
        
        actionSheetController.addTextField { textField -> Void in
            //TextField configuration
            let split = self.splits[sender]
            if split.ta == 0 {
                textField.placeholder = "TA:"
            }
            else {
                textField.text = "\(split.ta)"
            }
            
            textField.textColor = UIColor.blue
            textField.keyboardType = UIKeyboardType.numberPad
        }
        
        
        actionSheetController.addTextField { textField -> Void in
            //TextField configuration
            let split = self.splits[sender]
            if split.note == "" {
                textField.placeholder = "Note:"
            }
            else {
                textField.text = "\(split.note)"
            }
            textField.textColor = UIColor.blue
        }
        
        //Present the AlertController
        self.present(actionSheetController, animated: true, completion: nil)
    }
    

    @IBAction func openBtn(_ sender: AnyObject) {
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Open", message: "Control Number", preferredStyle: .alert)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Do some stuff
        }
        actionSheetController.addAction(cancelAction)
        
        //Create and add the Open action
        let openAction: UIAlertAction = UIAlertAction(title: "Open", style: .default) { action -> Void in
            //Do some stuff
            print(actionSheetController.textFields![0])
            let controlNumber = actionSheetController.textFields![0].text!
            if let cn = Int(controlNumber) {
                let control = Control(controlNumber: cn,openTime: self.timeLbl.text!, closeTime: "")
                self.controls.append(control)
                let splitTime = SplitTime(carNumber: 0,inTime: self.timeLbl.text!, ta: 0, controlNumber: 1,note: "Open")
                self.splits.insert(splitTime,at:0)
                self.splitTable.reloadData()
            }
            
//            let control = Control(controlNumber: controlNumber!,openTime: self.timeLbl.text!, closeTime: "")
//            self.controls.append(control)
//            let item = "Opened \(controlNumber.text!) at \(self.timeLbl.text!)"
//            self.items.insert(item,atIndex:0)
//            self.splitTable.reloadData()

        }
        actionSheetController.addAction(openAction)
        
        
        //Add a text field
        actionSheetController.addTextField { textField -> Void in
            //TextField configuration
            textField.text = ""
            textField.textColor = UIColor.blue
            textField.keyboardType = UIKeyboardType.numberPad
        }
        
        //Present the AlertController
        self.present(actionSheetController, animated: true, completion: nil)
        
    }
    
    @IBAction func closeBtn(_ sender: AnyObject) {
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Close", message: "Control Number", preferredStyle: .alert)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Do some stuff
        }
        actionSheetController.addAction(cancelAction)
        
        //Create and add the Open action
        let openAction: UIAlertAction = UIAlertAction(title: "Close", style: .default) { action -> Void in
            //Do some stuff
            let controlNumber = actionSheetController.textFields![0].text!
            
            if let cn = Int(controlNumber) {
                let control = Control(controlNumber: cn,openTime: "", closeTime: self.timeLbl.text!)
                self.controls.append(control)
                let splitTime = SplitTime(carNumber: 99,inTime: self.timeLbl.text!, ta: 0, controlNumber: 1,note: "Close")
                self.splits.insert(splitTime,at:0)
                self.splitTable.reloadData()
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
        actionSheetController.addTextField { textField -> Void in
            //TextField configuration
            textField.text = ""
            textField.textColor = UIColor.blue

            textField.keyboardType = UIKeyboardType.numberPad
        }
        
        //Present the AlertController
        self.present(actionSheetController, animated: true, completion: nil)
        
    }
    
    //    Game Controller
    
    func controllerDidConnect(_ notification: Notification) {
        
        let controller = notification.object as! GCController
//        print("controller is \(controller)")
//        print("game on ")
//        print("\(controller.gamepad!.buttonA.pressed)")
        
        
        controller.gamepad?.buttonA.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed {
                print("buttonA")
                self.splitBtn(self)
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

