// AppDelegate.swift Created by mason on 2015-11-01. Copyright © 2015 mason. All rights reserved.

import Cocoa

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate
{

  @IBOutlet weak var window: NSWindow!


  func applicationDidFinishLaunching(aNotification: NSNotification)
  {
    // Insert code here to initialize your application
  }

  
  func applicationWillTerminate(aNotification: NSNotification)
  {
    // Insert code here to tear down your application
  }

  @IBAction func catchException(sender: NSButton)
  {
    let t = NSTask()
    t.launchPath = "/nope/bogus/launch/path/will/cause/exception"
    
    let thrownException = CatchObjCException
    {
        t.launch()
    }
    
    print("thrownException: \(thrownException)")
  }
  
  
  @IBAction func dontCatchException(sender: NSButton)
  {
    let t = NSTask()
    t.launchPath = "/nope/bogus/launch/path/will/cause/exception"
    
    t.launch()
    
    print("we will never get here...")
  }
  
  
}

