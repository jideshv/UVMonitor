//
//  ViewController.swift
//  UVMonitor
//
//  Created by Jidesh on 5/8/16.
//  Copyright © 2016 Prenetics. All rights reserved.
//

import UIKit
import Bean_iOS_OSX_SDK

class ViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var uvaIrradienceValue: UILabel!
    @IBOutlet weak var uvbIrradienceValue: UILabel!
    
    @IBOutlet weak var uvaFluenceValue: UILabel!
    @IBOutlet weak var uvbFluenceValue: UILabel!
    
    @IBOutlet weak var temperatureValue: UILabel!
    @IBOutlet weak var batteryValue: UILabel!
    
    @IBOutlet weak var updateTime: UILabel!
    
    var connectedBean: PTDBean?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        connectedBean?.delegate = self
        
        connectedBean?.readTemperature()
        connectedBean?.readBatteryVoltage()
        connectedBean?.readScratchBank(2)
        connectedBean?.readScratchBank(3)
        
        let todaysDate:NSDate = NSDate()
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let dateInFormat:String = dateFormatter.stringFromDate(todaysDate)
        updateTime.text = dateInFormat;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    


}

// MARK: - PTDBeanDelegate

extension ViewController: PTDBeanDelegate {
    func bean(bean: PTDBean!, didUpdateTemperature degrees_celsius: NSNumber!) {
        temperatureValue.text = String(degrees_celsius);
    }

    func beanDidUpdateBatteryVoltage(bean: PTDBean!, error: NSError!) {
        batteryValue.text = String(bean.batteryVoltage)
    }
    
    func bean(bean: PTDBean!, didUpdateScratchBank bank: NSInteger, data: NSData!) {
        if (bank == 2) {
            var totalIrradience :NSInteger = 0
            data.getBytes(&totalIrradience, length: 4)
            let uvaIrradience: NSInteger = NSInteger(Double(totalIrradience) * 0.94)
            let uvbIrradience: NSInteger = NSInteger(Double(totalIrradience) * 0.06)
            uvaIrradienceValue.text = String(uvaIrradience)
            uvbIrradienceValue.text = String(uvbIrradience)
        }
        if (bank == 3) {
            var totalFluence :NSInteger = 0
            data.getBytes(&totalFluence, length: 4)
            let uvaFluence: NSInteger = NSInteger(Double(totalFluence) * 0.94)
            let uvbFluence: NSInteger = NSInteger(Double(totalFluence) * 0.06)
            uvaFluenceValue.text = String(uvaFluence)
            uvbFluenceValue.text = String(uvbFluence)
        }
    }
    
}


