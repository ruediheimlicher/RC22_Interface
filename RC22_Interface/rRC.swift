//
//  rRC.swift
//  RC22_Interface
//
//  Created by Ruedi Heimlicher on 20.02.2022.
//  Copyright © 2022 Ruedi Heimlicher. All rights reserved.
//
import Cocoa


let SET_RC:UInt8 = 0xA2


class rRC: rViewController 
{

   
   
   var hintergrundfarbe = NSColor()
 
   override func viewDidAppear() 
   {
      print ("RC viewDidAppear selectedDevice: \(selectedDevice)")
   }

   override func viewDidLoad() 
   {
      super.viewDidLoad()
      self.view.window?.acceptsMouseMovedEvents = true
      //let view = view[0] as! NSView
      self.view.wantsLayer = true
      hintergrundfarbe  = NSColor.init(red: 0.25, 
                                    green: 0.45, 
                                    blue: 0.45, 
                                    alpha: 0.25)
      self.view.layer?.backgroundColor =  hintergrundfarbe.cgColor
      formatter.maximumFractionDigits = 1
      formatter.minimumFractionDigits = 2
      formatter.minimumIntegerDigits = 1
      //formatter.roundingMode = .down
      
      
      //USB_OK.backgroundColor = NSColor.greenColor()
      // Do any additional setup after loading the view.
      let newdataname = Notification.Name("newdata")
      NotificationCenter.default.addObserver(self, selector:#selector(newDataAktion(_:)),name:newdataname,object:nil)
//      NotificationCenter.default.addObserver(self, selector:#selector(joystickAktion(_:)),name:NSNotification.Name(rawValue: "joystick"),object:nil)
  //    NotificationCenter.default.addObserver(self, selector:#selector(usbstatusAktion(_:)),name:NSNotification.Name(rawValue: "usb_status"),object:nil)
 //     NotificationCenter.default.addObserver(self, selector:#selector(drehknopfAktion(_:)),name:NSNotification.Name(rawValue: "drehknopf"),object:nil)
   
      teensy.write_byteArray[0] = SET_RC // Code
   
   
   } // end viewDidLoad

   func usbstatusAktion(_ notification:Notification) 
  {
     let info = notification.userInfo
     let status = info?["usbstatus"] as! Int32 // 
     print("Trigo usbstatusAktion:\t \(status) ")
     usbstatus = Int32(status)
  }


  @nonobjc override func windowShouldClose(_ sender: Any) 
  {
     print("RC windowShouldClose")
     NSApplication.shared.terminate(self)
  }

}// end class rRC

