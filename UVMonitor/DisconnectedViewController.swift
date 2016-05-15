//
//  DisconnectedViewController.swift
//  UVMonitor
//
//  Created by Jidesh on 5/15/16.
//  Copyright © 2016 Prenetics. All rights reserved.
//

import UIKit
import Bean_iOS_OSX_SDK


class DisconnectedViewController: UIViewController {
    
    var manager: PTDBeanManager!
    
    let vcSegueIdentifier = "ViewData"
    
    private var connectedBean: PTDBean? {
        didSet {
            connectedBean == nil ? beanManagerDidUpdateState(manager) : performSegueWithIdentifier(vcSegueIdentifier, sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        manager = PTDBeanManager(delegate: self)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == vcSegueIdentifier {
            let vc = segue.destinationViewController as! ViewController
            vc.connectedBean = connectedBean
            vc.connectedBean?.delegate = vc
        }
    }
}

// MARK: - PTDBeanManagerDelegate

extension DisconnectedViewController: PTDBeanManagerDelegate {
    
    func beanManagerDidUpdateState(beanManager: PTDBeanManager!) {
        switch beanManager.state {
        case .Unsupported:
            UIAlertView(title: "Error", message: "This device is unsupported.", delegate: self, cancelButtonTitle: "OK").show()
        case .PoweredOff:
            UIAlertView(title: "Error", message: "Please turn on Bluetooth.", delegate: self, cancelButtonTitle: "OK").show()
        case .PoweredOn:
            beanManager.startScanningForBeans_error(nil)
        case .Unknown, .Resetting, .Unauthorized:
            break
        }
    }
    
    func beanManager(beanManager: PTDBeanManager!, didDiscoverBean bean: PTDBean!, error: NSError!) {
        if connectedBean == nil {
            if bean.state == .Discovered {
                manager.connectToBean(bean, error: nil)
            }
        }
        
        print("DISCOVERED BEAN Name: \(bean.name), UUID: \(bean.identifier) RSSI: \(bean.RSSI)")
    }
    
    func beanManager(beanManager: PTDBeanManager!, didConnectBean bean: PTDBean!, error: NSError!) {
        if connectedBean == nil {
            connectedBean = bean
        }
        
            print("CONNECTED BEAN Name: \(bean.name), UUID: \(bean.identifier) RSSI: \(bean.RSSI)")
    }
    
    func beanManager(beanManager: PTDBeanManager!, didDisconnectBean bean: PTDBean!, error: NSError!) {
        // Dismiss any modal view controllers.
        presentedViewController?.dismissViewControllerAnimated(true) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        connectedBean = nil
        
        print("DISCONNECTED BEAN Name: \(bean.name), UUID: \(bean.identifier) RSSI: \(bean.RSSI)")
    }
}