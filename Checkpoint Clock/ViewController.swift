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
    
    
    func updateTimeLabel() {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .MediumStyle
        timeLbl.text = formatter.stringFromDate(NSDate())
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
        
    }
    // End Table

}

