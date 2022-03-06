//
//  ViewController.swift
//  Digital_Power_Interface
//
//  Created by Ruedi Heimlicher on 02.11.2014.
//  Copyright (c) 2014 Ruedi Heimlicher. All rights reserved.
//
// Bridging-Header: https://stackoverflow.com/questions/24146677/swift-bridging-header-import-issue/31717280#31717280

import Cocoa

 public var lastDataRead = Data.init(count:64)


var globalusbstatus = 0


class rZeigerView:NSView
{
   var zeigerpfad: NSBezierPath = NSBezierPath()
   var feld = frame
   override init(frame frameRect: NSRect) 
   {
      super.init(frame:frameRect);
      self.wantsLayer = true
      //self.layer?.backgroundColor = NSColor.red.cgColor
      let w:CGFloat = bounds.size.width
      let h:CGFloat = bounds.size.height
      let mittex:CGFloat = bounds.size.width / 2
      let mittey:CGFloat = bounds.size.height / 2
      zeigerpfad.move(to: NSMakePoint(mittex, 0)) // start point
      zeigerpfad.line(to: NSMakePoint(mittex, h))
//    zeigerpfad.rotateAroundCenter(angle: 10)
      //zeigerpfad.stroke()
   }
   
   required init?(coder: NSCoder) {
      super.init(coder: coder)
   }
   
   func setFeld(feld: NSRect)
   {
   //   self.setBoundsOrigin(feld.origin)
      self.setBoundsOrigin(feld.origin)
      self.setBoundsSize(feld.size)
      

   }
   
   override func draw(_ dirtyRect: NSRect)
   {
      let blackColor = NSColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
      blackColor.set()
      //zeigerpfad.stroke()
    //  zeigerpfad.move(to: NSMakePoint(20, 75))
      /*
      var bPath: NSBezierPath = NSBezierPath(rect:dirtyRect)
      var lineDash:[CGFloat] = [20.0,5.0,5.0]
      bPath.move(to: NSMakePoint(20, 75))
      bPath.line(to: NSMakePoint(dirtyRect.size.width - 20, 75))
      bPath.lineWidth = 10.0
      bPath.setLineDash(lineDash, count: 3, phase: 0.0)
      bPath.stroke()
      
      
      var cPath: NSBezierPath = NSBezierPath(rect:dirtyRect)
      cPath.move(to: NSMakePoint(10, 10))
      cPath.curve(to: NSMakePoint(dirtyRect.size.width - 20, 25), controlPoint1: NSMakePoint(10, 10), controlPoint2: NSMakePoint(15, 20))
      cPath.lineWidth = 4.0
      
      cPath.stroke()
 */
   }
   
}


struct position
{
   var x:UInt16 = 0
   var y:UInt16 = 0
   var z:UInt16 = 0
   
}
//MARK: rServoPfad
class rServoPfad 
{
   var pfadarray = [position]()
   var delta = 1 // Abstand der Schritte
   required init?() 
   {
      //super.init()
      //Swift.print("servoPfad init")
      var startposition = position()
      startposition.x = 0
      startposition.y = 0
      startposition.z = 0
 //     pfadarray.append(startposition)
      
   }
   
   func setStartposition(x:UInt16, y:UInt16, z:UInt16)
   {
      let anz = pfadarray.count
      if (pfadarray.count > 0)
      {
         pfadarray[0].x = x
         pfadarray[0].y = y
         pfadarray[0].z = z
      }
      else
      {
         addPosition(newx: x, newy: y, newz: z)
      }
   }
   
   func addPosition(newx:UInt16, newy:UInt16, newz:UInt16)
   {
       let newposition = position(x:newx,y:newy,z:newz)
      pfadarray.append(newposition)
    }
 
   func clearPfadarray()
   {
      pfadarray.removeAll()
   }
   
   func anzahlPunkte() -> Int
   {
      return Int(pfadarray.count)
   }
   
}

//MARK: TABVIEW
class rDeviceTabViewController: NSTabViewController 
{
   
   override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) 
   {
      let identifier:String = tabViewItem?.identifier as! String
    //  print("DeviceTab identifier: \(String(describing: identifier)) usbstatus: \(globalusbstatus)")
    // let sup = self.view.superview
     // print("DeviceTab superview: \(sup) ident: \(sup?.identifier)")
   //let supsup = self.view.superview?.superview
      //print("DeviceTab supsup: \(supsup) ident: \(supsup?.identifier)")
      //print("subviews: \(supsup?.subviews)")
      
      var userinformation:[String : Any]
      userinformation = ["message":"tabview",  "ident": identifier, ] as [String : Any]
      let nc = NotificationCenter.default
      nc.post(name:Notification.Name(rawValue:"tabview"),
              object: nil,
              userInfo: userinformation)
 
      userinformation = ["message":"usb"] as [String : Any]
      /*
      nc.post(name:Notification.Name(rawValue:"usb_status"),
              object: nil,
              userInfo: userinformation)
*/
   }
 
}

//MARK: ViewController
class rViewController: NSViewController, NSWindowDelegate
{
   let notokimage :NSImage = NSImage(named:NSImage.Name(rawValue: "notok_image"))!
   let okimage :NSImage = NSImage(named:NSImage.Name(rawValue: "ok_image"))!
 
   let pfeillinksimage :NSImage = NSImage(named:NSImage.Name(rawValue: "pfeillinks"))!
   let pfeilrechtsimage :NSImage = NSImage(named:NSImage.Name(rawValue: "pfeilrechts"))!
   let pfeilupimage :NSImage = NSImage(named:NSImage.Name(rawValue: "pfeilup"))!
   let pfeildownimage :NSImage = NSImage(named:NSImage.Name(rawValue: "pfeildown"))!

 
  
   
   // Robot
   var z0:Float = 30 // Hoehe Drehpunkt 0
   var l0:Float = 1// laenge Arm 0
   var l1:Float = 1 // laenge Arm 1
   var l2:Float = 1 // laenge Arm 2
   
   var phi0:Float = 0 // Winkel Arm 0 von Senkrechte
   var phi1:Float = 0 // Winkel Arm 1
   var phi2:Float = 0 // Winkel Arm 2
   // var  myUSBController:USBController
   // var usbzugang:
   var usbstatus: Int32 = 0
   
   var teensy = usb_teensy()
   
   var servoPfad = rServoPfad()
   
   var selectedDevice:String = ""
   
   var hgfarbe  = NSColor()
   
  
   
   var formatter = NumberFormatter()
   
      
   var achse0_start:UInt16  = ACHSE0_START;
   var achse0_max:UInt16   = ACHSE0_MAX;

   var robotPList = UserDefaults.standard 
   let defaults = UserDefaults.standard
   
   // https://learnappmaking.com/plist-property-list-swift-how-to/
   struct Preferences: Codable {
      var webserviceURL:String
      var itemsPerPage:Int
      var backupEnabled:Bool
      var robot1_offset:Int
   }

   func windowWillClose(_ aNotification: Notification) {
      print("VC windowWillClose")
      let nc = NotificationCenter.default
      nc.post(name:Notification.Name(rawValue:"beenden"),
              object: nil,
              userInfo: nil)
      
   }
   
   override func viewDidLoad()
   {
      super.viewDidLoad()
      view.window?.delegate = self // https://stackoverflow.com/questions/44685445/trying-to-know-when-a-window-closes-in-a-macos-document-based-application
      self.view.window?.acceptsMouseMovedEvents = true
 
      formatter.maximumFractionDigits = 1
      formatter.minimumFractionDigits = 2
      formatter.minimumIntegerDigits = 1
      //formatter.roundingMode = .down

      
      //USB_OK.backgroundColor = NSColor.greenColor()
      // Do any additional setup after loading the view.
      let newdataname = Notification.Name("newdata")
      NotificationCenter.default.addObserver(self, selector:#selector(newDataAktion(_:)),name:newdataname,object:nil)
      NotificationCenter.default.addObserver(self, selector:#selector(joystickAktion(_:)),name:NSNotification.Name(rawValue: "joystick"),object:nil)
      NotificationCenter.default.addObserver(self, selector:#selector(tabviewAktion(_:)),name:NSNotification.Name(rawValue: "tabview"),object:nil)
      NotificationCenter.default.addObserver(self, selector: #selector(beendenAktion), name:NSNotification.Name(rawValue: "beenden"), object: nil)

      
      
      defaults.set(25, forKey: "Age")
      defaults.set(true, forKey: "UseTouchID")
      defaults.set(CGFloat.pi, forKey: "Pi")
      
      defaults.set("Paul Hudson", forKey: "Name")
      defaults.set(Date(), forKey: "LastRun")
      
      let name = "John Doe"
      let robot1 = 300
//      robotPList.set(name, forKey: "name")
      robotPList.set(robot1, forKey: "robot1")
      
      var preferences = Preferences(webserviceURL: "https://api.twitter.com", itemsPerPage: 12, backupEnabled: false,robot1_offset: 300)
      
      preferences.robot1_offset = 400
 
      
      let encoder = PropertyListEncoder()
      encoder.outputFormat = .xml
      
      let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Robot/Preferences.plist")
      
      do {
         let data = try encoder.encode(preferences)
         try data.write(to: path)
      } catch {
         print(error)
      }
     
      if  let path        = Bundle.main.path(forResource: "Preferences", ofType: "plist"),
         let xml         = FileManager.default.contents(atPath: path),
         let preferences = try? PropertyListDecoder().decode(Preferences.self, from: xml)
      {
         print(preferences.webserviceURL)
      }
      
      // servoPfad
      servoPfad?.setStartposition(x: 0x800, y: 0x800, z: 0)
      

   }
   
   override func viewDidAppear() 
   {
      print("VC viewDidAppear")
      let nc = NotificationCenter.default
      var userinformation:[String : Any]
      var manufactorername = "-"
      
      self.view.window?.delegate = self as? NSWindowDelegate 
      let erfolg = teensy.USBOpen()
      if erfolg == 1
      {
         USB_OK_Feld.image = okimage
         manufactorername = teensy.manustring
         usbstatus = Int32(1)
      }
      else
      {
         USB_OK_Feld.image = notokimage
         usbstatus = Int32(0)
      }
      userinformation = ["message":"usb", "usbstatus": usbstatus,"manufactorer": manufactorername] as [String : Any]
      nc.post(name:Notification.Name(rawValue:"usb_status"),
              object: nil,
              userInfo: userinformation)

   }

   @objc func beendenAktion(_ notification:Notification) 
   {
      
      print("VC beendenAktion")
      NSApplication.shared.terminate(self)
      
      
   }
   
   @objc func tabviewAktion(_ notification:Notification) 
   {
      let info = notification.userInfo
      let ident:String = info?["ident"] as! String  // 
      //print("Basis tabviewAktion:\t \(ident)")
      selectedDevice = ident
   }

   
   
   @objc func joystickAktion(_ notification:Notification) 
   {
      let info = notification.userInfo
      let punkt:CGPoint = info?["punkt"] as! CGPoint
      let wegindex:Int = info?["index"] as! Int // 
      let first:Int = info?["first"] as! Int
      //print("xxx joystickAktion:\t \(punkt)")
      //print("x: \(punkt.x) y: \(punkt.y) index: \(wegindex) first: \(first)")
      
      /*
      teensy.write_byteArray[0] = SET_ROB // Code 
      
      // Horizontal Pot0
      let w = Double(Joystickfeld.bounds.size.width) // Breite Joystickfeld
      let faktorw:Double = (Pot0_Slider.maxValue - Pot0_Slider.minValue) / w
      //      print("w: \(w) faktorw: \(faktorw)")
      var x = Double(punkt.x)
      if (x > w)
      {
         x = w
      }
      goto_x.integerValue = Int(Float(x*faktorw))
      joystick_x.integerValue = Int(Float(x*faktorw))
      goto_x_Stepper.integerValue = Int(Float(x*faktorw))
      let achse0 = UInt16(Float(x*faktorw) * FAKTOR0)
      //print("x: \(x) achse0: \(achse0)")
      teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8((achse0 & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8((achse0 & 0x00FF) & 0xFF) // lb
      
      
      let h = Double(Joystickfeld.bounds.size.height)
      let faktorh:Double = (Pot1_Slider.maxValue - Pot1_Slider.minValue) / h
      
      let faktorz = 1
      //     print("h: \(h) faktorh: \(faktorh)")
      var y = Double(punkt.y)
      if (y > h)
      {
         y = h
      }
      let z = 0
      goto_y.integerValue = Int(Float(y*faktorh))
      joystick_y.integerValue = Int(Float(y*faktorh))
      goto_y_Stepper.integerValue = Int(Float(y*faktorh))
      let achse1 = UInt16(Float(y*faktorh) * FAKTOR1)
      //print("y: \(y) achse1: \(achse1)")
      teensy.write_byteArray[ACHSE1_BYTE_H] = UInt8((achse1 & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE1_BYTE_L] = UInt8((achse1 & 0x00FF) & 0xFF) // lb
      let achse2 =  UInt16(Float(z*faktorz) * FAKTOR2)
      teensy.write_byteArray[ACHSE2_BYTE_H] = UInt8((achse2 & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE2_BYTE_L] = UInt8((achse2 & 0x00FF) & 0xFF) // lb
    
      
      let message:String = info?["message"] as! String
      if ((message == "mousedown") && (first >= 0))// Polynom ohne mousedragged
      {
         teensy.write_byteArray[0] = SET_RING
         let anz = servoPfad?.anzahlPunkte()
         if (wegindex > 1)
         {
            print("")
            print("joystickAktion cont achse0: \(achse0) achse1: \(achse1)  achse2: \(achse2) anz: \(String(describing: anz)) wegindex: \(wegindex)")
            
            let lastposition = servoPfad?.pfadarray.last
            
            let lastx:Int = Int(lastposition!.x)
            let nextx:Int = Int(achse0)
            let hypx:Int = (nextx - lastx) * (nextx - lastx)
            
            let lasty:Int = Int(lastposition!.y)
            let nexty:Int = Int(achse1)
            let hypy:Int = (nexty - lasty) * (nexty - lasty)
            
            let lastz:Int = Int(lastposition!.z)
            let nextz:Int = Int(achse2)
            let hypz:Int = (nextz - lastz) * (nextz - lastz)
            
            print("joystickAktion lastx: \(lastx) nextx: \(nextx) lasty: \(lasty) nexty: \(nexty)")
            
            let hyp:Float = (sqrt((Float(hypx + hypy + hypz))))
            
            let anzahlsteps = hyp/schrittweiteFeld.floatValue
            print("joystickAktion hyp: \(hyp) anzahlsteps: \(anzahlsteps) ")

            teensy.write_byteArray[HYP_BYTE_H] = UInt8((Int(hyp) & 0xFF00) >> 8) // hb
            teensy.write_byteArray[HYP_BYTE_L] = UInt8((Int(hyp) & 0x00FF) & 0xFF) // lb
       
            teensy.write_byteArray[STEPS_BYTE_H] = UInt8((Int(anzahlsteps) & 0xFF00) >> 8) // hb
            teensy.write_byteArray[STEPS_BYTE_L] = UInt8((Int(anzahlsteps) & 0x00FF) & 0xFF) // lb
            
            teensy.write_byteArray[INDEX_BYTE_H] = UInt8(((wegindex-1) & 0xFF00) >> 8) // hb // hb // Start, Index 0
            teensy.write_byteArray[INDEX_BYTE_L] = UInt8(((wegindex-1) & 0x00FF) & 0xFF) // lb

            print("joystickAktion hypx: \(hypx) hypy: \(hypy) hypz: \(hypz) hyp: \(hyp)")
            
         }
         else
         {
            print("joystickAktion start achse0: \(achse0) achse1: \(achse1)  achse2: \(achse2) anz: \(anz) wegindex: \(wegindex)")
            teensy.write_byteArray[HYP_BYTE_H] = 0 // hb // Start, keine Hypo
            teensy.write_byteArray[HYP_BYTE_L] = 0 // lb
            teensy.write_byteArray[INDEX_BYTE_H] = 0 // hb // Start, Index 0
            teensy.write_byteArray[INDEX_BYTE_L] = 0 // lb

         }
         
         servoPfad?.addPosition(newx: achse0, newy: achse1, newz: 0)
      }
      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         //print("report_Slider0 senderfolg: \(senderfolg)")
      }
      */
   }
 
 
   @objc func newDataAktion(_ notification:Notification) 
   {
      let lastData = teensy.getlastDataRead()
      //print("lastData:\t \(lastData[1])\t\(lastData[2])   ")
      var ii = 0
      while ii < 10
      {
         //print("ii: \(ii)  wert: \(lastData[ii])\t")
         ii = ii+1
      }
      return;
      let u = ((Int32(lastData[1])<<8) + Int32(lastData[2]))
      //print("hb: \(lastData[1]) lb: \(lastData[2]) u: \(u)")
      let info = notification.userInfo
      
      //print("info: \(String(describing: info))")
      //print("new Data")
      let data = notification.userInfo?["data"] as! [UInt8]
      //print("data: \(String(describing: data)) \n") // data: Optional([0, 9, 51, 0,....
      
      
      //print("lastDataRead: \(lastDataRead)   ")
      var i = 0
      while i < 10
      {
//         print("i: \(i)  wert: \(lastDataRead[i])\t")
         i = i+1
      }
      var emitter = UInt16(data[13]) << 8  | UInt16(data[12])
      
         print("emitteradresse: \(lastDataRead[10]) emitterwerte: \(lastDataRead[12]) \(lastDataRead[13]) emitter: \(emitter)")
      //emitterFeld.integerValue = Int(emitter)
      if let d = notification.userInfo!["usbdata"]
      {
            
         //print("d: \(d)\n") // d: [0, 9, 56, 0, 0,... 
         let t = type(of:d)
         //print("typ: \(t)\n") // typ: Array<UInt8>
         
         //print("element: \(d[1])\n")
         
  //       print("d as string: \(String(describing: d))\n")
         if d != nil
         {
            //print("d not nil\n")
            var i = 0
            while i < 10
            {
              // print("i: \(i)  wert: \(d![i])\t")
               i = i+1
            }
            
         }
        
         
         //print("dic end\n")
      }
      
      //let dic = notification.userInfo as? [String:[UInt8]]
      //print("dic: \(dic ?? ["a":[123]])\n")

   }
   
   func tester(_ timer: Timer)
   {
      let theStringToPrint = timer.userInfo as! String
      print(theStringToPrint)
   }
   
   @IBAction func report_Slider0(_ sender: NSSlider)
   {
      teensy.write_byteArray[0] = SET_0 // Code 
      //print("report_Slider0 IntVal: \(sender.intValue)")
      
      let pos = sender.floatValue
      
      let intpos = UInt16(pos * FAKTOR0)
      let Ustring = formatter.string(from: NSNumber(value: intpos))
      
      print("report_Slider0 pos: \(pos) intpos: \(intpos)  Ustring: \(Ustring ?? "0")")
     // Pot0_Feld.stringValue  = Ustring!
      Pot0_Feld.integerValue  = Int(intpos)
      Pot0_Stepper_L.integerValue  = Int(sender.minValue) // Stepper min setzen
      Pot0_Stepper_L_Feld.integerValue = Int(sender.minValue)
      Pot0_Stepper_H.integerValue  = Int(sender.maxValue) // Stepper max setzen
      Pot0_Stepper_H_Feld.integerValue = Int(sender.maxValue)
      
      teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8((intpos & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8((intpos & 0x00FF) & 0xFF) // lb
      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         //print("report_Slider0 senderfolg: \(senderfolg)")
      }
   }
   
   @IBAction func report_goto_0(_ sender: NSButton)
   {
      print("report_goto_0")
      var x = goto_x.integerValue
      if x > Int(Pot0_Slider.maxValue)
      {
         x = Int(Pot0_Slider.maxValue)
      }
      var y = goto_y.integerValue
      if y > Int(Pot1_Slider.maxValue)
      {
         y = Int(Pot1_Slider.maxValue)
      }
      
      print("report_goto_0  x: \(x) y: \(y)")
      self.goto_0(x:Float(x),y:Float(y),z: 0)
   }

   func goto_0(x:Float, y:Float, z:Float)
   {
      teensy.write_byteArray[0] = GOTO_0
      print("goto_0 x: \(x) y: \(y)")
      // achse 0
      let intposx = UInt16(x * FAKTOR0)
      goto_x_Stepper.integerValue = Int(x) //Int(intposx)
      teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8((intposx & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8((intposx & 0x00FF) & 0xFF) // lb

      // Achse 1
      let intposy = UInt16(y * FAKTOR1)
      goto_y_Stepper.integerValue = Int(y)
      teensy.write_byteArray[ACHSE1_BYTE_H] = UInt8((intposy & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE1_BYTE_L] = UInt8((intposy & 0x00FF) & 0xFF) // lb

      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
      }

      
   }
   
    @IBAction func report_clear_Ring(_ sender: NSButton)
    {
      print("report_clear_Ring ")
      teensy.write_byteArray[0] = CLEAR_RING
      teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8(((ACHSE0_START) & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8(((ACHSE0_START) & 0x00FF) & 0xFF) // lb
      
      teensy.write_byteArray[ACHSE1_BYTE_H] = UInt8(((ACHSE1_START) & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE1_BYTE_L] = UInt8(((ACHSE1_START) & 0x00FF) & 0xFF) // lb

      teensy.write_byteArray[ACHSE2_BYTE_H] = UInt8(((ACHSE2_START) & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE2_BYTE_L] = UInt8(((ACHSE2_START) & 0x00FF) & 0xFF) // lb
 
      teensy.write_byteArray[HYP_BYTE_H] = 0 // hb
      teensy.write_byteArray[HYP_BYTE_L] = 0 // lb

      teensy.write_byteArray[INDEX_BYTE_H] = 0 // hb
      teensy.write_byteArray[INDEX_BYTE_L] = 0 // lb
      Joystickfeld.clearWeg()
      servoPfad?.clearPfadarray()

      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
      }

   }
   
   @IBAction func report_goto_x_Stepper(_ sender: NSStepper)
   {
      //teensy.write_byteArray[0] = SET_0 // Code 
      print("report_goto_x_Stepper IntVal: \(sender.intValue)")
      let intpos = sender.integerValue 
      goto_x.integerValue = intpos
      let intposx = UInt16(Float(intpos ) * FAKTOR0)
      teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8((intposx & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8((intposx & 0x00FF) & 0xFF) // lb
      
      let w = Double(Joystickfeld.bounds.size.width) // Breite Joystickfeld
      let invertfaktorw:Float = Float(w / (Pot0_Slider.maxValue - Pot0_Slider.minValue)) 

      var currpunkt:NSPoint = Joystickfeld.weg.currentPoint
      currpunkt.x = CGFloat(Float(intpos) * invertfaktorw)
      Joystickfeld.weg.line(to: currpunkt)
      Joystickfeld.needsDisplay = true 
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
      }
   }

   @IBAction func report_goto_y_Stepper(_ sender: NSStepper)
   {
      //teensy.write_byteArray[0] = SET_0 // Code 
      //print("report_goto_y_Stepper IntVal: \(sender.intValue)")
      let intpos = sender.integerValue 
      goto_y.integerValue = intpos
      let intposy = UInt16(Float(intpos ) * FAKTOR0)
      teensy.write_byteArray[ACHSE1_BYTE_H] = UInt8((intposy & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE1_BYTE_L] = UInt8((intposy & 0x00FF) & 0xFF) // lb

      let h = Double(Joystickfeld.bounds.size.width) // Breite Joystickfeld
      let invertfaktorh:Float = Float(h / (Pot1_Slider.maxValue - Pot1_Slider.minValue)) 
      
      var currpunkt:NSPoint = Joystickfeld.weg.currentPoint
      currpunkt.y = CGFloat(Float(intpos) * invertfaktorh)
      Joystickfeld.weg.line(to: currpunkt)
      Joystickfeld.needsDisplay = true 

      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
      }
   }
   
   @IBAction func report_Slider1(_ sender: NSSlider)
   {
      let loktag = sender.tag
      teensy.write_byteArray[0] = addresscodearray[loktag]// Code
      
     
      print("report_Slider1 IntVal: \(sender.intValue)")
      
      let pos = sender.floatValue
      let intpos = UInt16(pos * FAKTOR0)
      let Istring = formatter.string(from: NSNumber(value: intpos))
      print("intpos: \(intpos) IString: \(Istring)") 
      Pot1_Feld.integerValue  = Int(intpos)
      
      Pot1_Stepper_L.integerValue  = Int(sender.minValue) // Stepper min setzen
      Pot1_Stepper_L_Feld.integerValue = Int(sender.minValue)
      Pot1_Stepper_H.integerValue  = Int(sender.maxValue) // Stepper max setzen
      Pot1_Stepper_H_Feld.integerValue = Int(sender.maxValue)

     

      teensy.write_byteArray[ACHSE1_BYTE_H] = UInt8((intpos & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE1_BYTE_L] = UInt8((intpos & 0x00FF) & 0xFF) // lb

      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
      }
   }

   @IBAction func report_Pot1_Stepper_L(_ sender: NSStepper) // untere Grenze
   {
      print("report_Pot1_Stepper_L IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
      Pot1_Stepper_L_Feld.integerValue = intpos
      
      Pot1_Slider.minValue = sender.doubleValue 
      print("report_Pot1_Stepper_L Pot1_Slider.minValue: \(Pot1_Slider.minValue)")
      
   }
   
   @IBAction func report_Pot1_Stepper_H(_ sender: NSStepper)// Obere Grenze
   {
      print("report_Pot1_Stepper_H IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
      Pot1_Stepper_H_Feld.integerValue = intpos
      
      Pot1_Slider.maxValue = sender.doubleValue 
      print("report_Pot1_Stepper_H Pot1_Slider.maxValue: \(Pot1_Slider.maxValue)")
      
   }

   @IBAction func report_I_Stepper(_ sender: NSStepper)
   {
      //teensy.write_byteArray[0] = SET_0 // Code 
      print("report_I_Stepper IntVal: \(sender.intValue)")
      let I = Pot1_Feld.floatValue
      let intpos = sender.intValue 
      
      let pos = sender.floatValue
      let Istring = formatter.string(from: NSNumber(value: intpos))
 //     print("report_U_Stepper u: \(u) Istring: \(Istring ?? "0")")
      Pot1_Feld.stringValue  = Istring!
      
      self.Pot1_Stepper_H.floatValue = sender.floatValue
      
      teensy.write_byteArray[ACHSE1_BYTE_H] = UInt8((intpos & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE1_BYTE_L] = UInt8((intpos & 0x00FF) & 0xFF) // lb
      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
      }
   }

   @IBAction func report_StartSinus(_ sender: NSButton)
   {
      print("report_StartSinus ")
      let intpos0 = UInt16(Float(ACHSE0_START) * FAKTOR0)
      Pot0_Feld.integerValue = Int(UInt16(Float(ACHSE0_START) * FAKTOR0))

      teensy.write_byteArray[0] = SIN_START
      let intpos = UInt16(Float(ACHSE0_START) * FAKTOR0)
      let startwert = UInt16(Float(ACHSE0_START) * FAKTOR0)
      
      teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8((startwert & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8((startwert & 0x00FF) & 0xFF) // lb
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         print("report_sinus senderfolg: \(senderfolg) startwert: \(startwert)")
      }
      
      
   }
   @IBAction func report_StopSinus(_ sender: NSButton)
   {
      print("report_StopSinus ")
      teensy.write_byteArray[0] = SIN_END
      teensy.write_byteArray[1] = SIN_END
      let startwert = ACHSE0_START
      teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8((startwert & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8((startwert & 0x00FF) & 0xFF) // lb
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         print("report_sinus senderfolg: \(senderfolg) startwert: \(startwert)")
      }
      
      
   }
  
   @IBAction func report_Slider_sin(_ sender: NSSlider)
   {
      teensy.write_byteArray[0] = SET_2 // Code 
      //print("report_Slider:sin IntVal: \(sender.intValue)")
      
      let pos = sender.floatValue
    
      let intpos = UInt16(pos * FAKTOR0)
      let Ustring = formatter.string(from: NSNumber(value: intpos))
      
      //print("report_Slider0 pos: \(pos) intpos: \(intpos)  Ustring: \(Ustring ?? "0")")
      Pot2_Feld.stringValue  = Ustring!
      Pot2_Feld.integerValue  = Int(intpos)
      Pot2_Stepper_L.integerValue  = Int(sender.minValue) // Stepper min setzen
      Pot2_Stepper_L_Feld.integerValue = Int(sender.minValue)
      Pot2_Stepper_H.integerValue  = Int(sender.maxValue) // Stepper max setzen
      Pot2_Stepper_H_Feld.integerValue = Int(sender.maxValue)
      
      teensy.write_byteArray[ACHSE2_BYTE_H] = UInt8((intpos & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE2_BYTE_L] = UInt8((intpos & 0x00FF) & 0xFF) // lb
      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         //print("report_Slider0 senderfolg: \(senderfolg)")
      }
   }
   
   @IBAction func report_Pot0_Stepper_L(_ sender: NSStepper) // untere Grenze
   {
      print("report_Pot0_Stepper_L IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
//      Pot0_Stepper_L_Feld.integerValue = intpos
      
 //     Pot0_Slider.minValue = sender.doubleValue 
      print("report_Pot0_Stepper_L Pot0_Slider.minValue: \(Pot0_Slider.minValue)")
      
   }
   
   @IBAction func report_Pot0_Stepper_H(_ sender: NSStepper)// Obere Grenze
   {
      print("report_Pot0_Stepper_H IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
      Pot0_Stepper_H_Feld.integerValue = intpos
      
      Pot0_Slider.maxValue = sender.doubleValue 
      print("report_Pot0_Stepper_H Pot0_Slider.maxValue: \(Pot0_Slider.maxValue)")
      
   }

   
   @IBAction func report_set_Pot0(_ sender: NSTextField)
   {
      teensy.write_byteArray[0] = SET_0 // Code 
      
      // senden mit faktor 1000
      //let u = Pot0_Feld.floatValue 
      let Pot0_wert = Pot0_Feld.floatValue * 100
      let Pot0_intwert = UInt(Pot0_wert)
      
      let Pot0_HI = (Pot0_intwert & 0xFF00) >> 8
      let Pot0_LO = Pot0_intwert & 0x00FF
      
      print("report_set_Pot0 Pot0_wert: \(Pot0_wert) Pot0 HI: \(Pot0_HI) Pot0 LO: \(Pot0_LO) ")
      let intpos = sender.intValue 
      self.Pot0_Slider.floatValue = Pot0_wert //sender.floatValue
      self.Pot0_Stepper_L.floatValue = Pot0_wert//sender.floatValue

      teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8(Pot0_LO)
      teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8(Pot0_HI)
      
       if (usbstatus > 0)
       {
         let senderfolg = teensy.send_USB()
         if (senderfolg < BUFFER_SIZE)
         {
            print("report_set_Pot0 U: %d",senderfolg)
         }
      }
   }
   
   
   @IBAction func report_Slider2(_ sender: NSSlider)
   {
      teensy.write_byteArray[0] = SET_3 // Code 
      //print("report_Slider2 IntVal: \(sender.intValue)")
      let pos = sender.floatValue
      
      let intpos = UInt16(pos * FAKTOR3)
      let Ustring = formatter.string(from: NSNumber(value: intpos))
      
      //print("report_Slider2 pos: \(pos) intpos: \(intpos)  Ustring: \(Ustring ?? "0")")
      // Pot0_Feld.stringValue  = Ustring!
      Pot2_Feld.integerValue  = Int(intpos)
      Pot2_Stepper_L.integerValue  = Int(sender.minValue) // Stepper min setzen
      Pot2_Stepper_L_Feld.integerValue = Int(sender.minValue)
      Pot2_Stepper_H.integerValue  = Int(sender.maxValue) // Stepper max setzen
      Pot2_Stepper_H_Feld.integerValue = Int(sender.maxValue)
      
      teensy.write_byteArray[ACHSE3_BYTE_H] = UInt8((intpos & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE3_BYTE_L] = UInt8((intpos & 0x00FF) & 0xFF) // lb
      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         //print("report_Slider2 senderfolg: \(senderfolg)")
      }
   }
   @IBAction  func report_Pot2_Stepper_H(_ sender: NSStepper) // untere Grenze
   {
      print("report_Pot2_Stepper_H IntVal: \(sender.integerValue)")
   }
   @IBAction  func report_Pot2_Stepper_L(_ sender: NSStepper) // untere Grenze
   {
      print("report_Pot2_Stepper_L IntVal: \(sender.integerValue)")

   }
   
   @IBAction  func report_Slider3(_ sender: NSSlider)
   {
      teensy.write_byteArray[0] = SET_3 // Code 
      print("report_Slider3 IntVal: \(sender.intValue)")
   }


   @IBAction func report_set_Pot1(_ sender: AnyObject)
   {
      
   }

   @IBAction  func report_Pot3_Stepper_L(_ sender: NSStepper) // untere Grenze
   {
   }
   @IBAction  func report_Pot3_Stepper_H(_ sender: NSStepper)// Obere Grenze
   {
      print("report_Pot3_Stepper_H IntVal: \(sender.integerValue)")
   }
   
    
   @IBAction func report_start_read_USB(_ sender: AnyObject)
   {
      //myUSBController.startRead(1)
      if teensy.dev_present() > 0
      {
         var start_read_USB_erfolg = teensy.start_read_USB(true)
         Start_Knopf.isEnabled = false
         Stop_Knopf.isEnabled = true

      }
      else
      {
         let warnung = NSAlert.init()
         warnung.messageText = "USB"
         warnung.messageText = "report_start_read_USB: Kein USB-Device"
         warnung.addButton(withTitle: "OK")
         warnung.runModal()
         Start_Knopf.isEnabled = false
         Stop_Knopf.isEnabled = false

      }
      
      //teensy.start_teensy_Timer()
      
      //     var somethingToPass = "It worked"
      
      //      let timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("tester:"), userInfo: somethingToPass, repeats: true)
      
   }
   
   @IBAction func check_USB(_ sender: NSButton)
   {
      let present = teensy.dev_present()
      let hidstatus = teensy.status()
      let nc = NotificationCenter.default
      var userinformation:[String : Any]
     // print("USBOpen usbstatus vor check: \(usbstatus) hidstatus: \(hidstatus) present: \(present)")
      if (usbstatus > 0) // already open
      {
         print("USB-Device ist schon da")
         let warnung = NSAlert.init()
         warnung.messageText = "USB"
         warnung.messageText = "USB-Device ist schon da"
         warnung.addButton(withTitle: "OK")
         warnung.runModal()
         return

      }
      let erfolg = teensy.USBOpen()
      usbstatus = erfolg
      globalusbstatus = Int(erfolg)
      print("USBOpen erfolg: \(erfolg) usbstatus: \(usbstatus)")
      
      if (rawhid_status()==1)
      {
         print("status 1")
         //USB_OK.backgroundColor = NSColor.green
         //USB_OK.stringValue = "+"
         USB_OK_Feld.image = okimage
         print("USB-Device da")
         /*
         let warnung = NSAlert.init()
         warnung.messageText = "USB"
         warnung.messageText = "USB-Device ist da"
         warnung.addButton(withTitle: "OK")
         //warnung.runModal()
          */
         let manu = get_manu()
         //println(manu) // ok, Zahl
//         var manustring = UnsafePointer<CUnsignedChar>(manu)
         //println(manustring) // ok, Zahl
         
         let manufactorername = String(cString: UnsafePointer(manu!))
       //  print("str: ", manufactorername)
         manufactorer.stringValue = manufactorername
         
         //manufactorer.stringValue = "Manufactorer: " + teensy.manufactorer()!
         Start_Knopf.isEnabled = true
         Send_Knopf.isEnabled = true
         
         userinformation = ["message":"usb", "usbstatus": 1,"manufactorer": manufactorername] as [String : Any]
         nc.post(name:Notification.Name(rawValue:"usb_status"),
                 object: nil,
                 userInfo: userinformation)

      }
      else
         
      {
         print("status 0")
        // USB_OK.backgroundColor = NSColor.yellow
        // USB_OK.stringValue = "-"
         USB_OK_Feld.image = notokimage
         let warnung = NSAlert.init()
         warnung.messageText = "USB"
         warnung.messageText = "check_USB: Kein USB-Device"
         warnung.addButton(withTitle: "OK")
         warnung.runModal()
         userinformation = ["message":"usb", "usbstatus": 0] as [String : Any]
         nc.post(name:Notification.Name(rawValue:"usb_status"),
                 object: nil,
                 userInfo: userinformation)

         /*
         if let taste = USB_OK
         {
            //print("Taste USB_OK ist nicht nil")
            taste.backgroundColor = NSColor.red
         //USB_OK.backgroundColor = NSColor.redColor()
           
         }
         else
         {
            print("Taste USB_OK ist nil")
         }*/ 
         Start_Knopf.isEnabled = false
         Stop_Knopf.isEnabled = false
         Send_Knopf.isEnabled = false
         return
      }
      //print("antwort: \(teensy.status())")
   }
   
   @IBAction func report_stop_read_USB(_ sender: AnyObject)
   {
      if teensy.dev_present() > 0
      {
         teensy.read_OK = false
         if teensy.dev_present() > 0
         {
            Start_Knopf.isEnabled = true
            Send_Knopf.isEnabled = true
         }
         else
         {
            Start_Knopf.isEnabled = false
         }
         Stop_Knopf.isEnabled = false
      }
   }
   
   @IBAction func send_USB(_ sender: AnyObject)
   {
      //NSBeep()
      if teensy.dev_present() > 0
      {
         var senderfolg = teensy.send_USB()
      }
      else
      {
         let warnung = NSAlert.init()
         warnung.messageText = "USB"
         warnung.messageText = "send_USB: Kein USB-Device"
         warnung.addButton(withTitle: "OK")
         warnung.runModal()
         Send_Knopf.isEnabled = false

      }
      
      //println("send_USB senderfolg: \(senderfolg)")
      
      
      /*
      var USB_Zugang = USBController()
      USB_Zugang.setKontrollIndex(5)
      
      Counter.intValue = USB_Zugang.kontrollIndex()
      
      // var  out  = 0
      
      //USB_Zugang.Alert("Hoppla")
      
      var x = getX()
      Counter.intValue = x
      
      var    out = rawhid_open(1, 0x16C0, 0x0480, 0xFFAB, 0x0200)
      
      println("send_USB out: \(out)")
      
      if (out <= 0)
      {
      usbstatus = 0
      Anzeige.stringValue = "not OK"
      println("kein USB-Device")
      }
      else
      {
      usbstatus = 1
      println("USB-Device da")
      var manu = get_manu()
      //println(manu) // ok, Zahl
      var manustring = UnsafePointer<CUnsignedChar>(manu)
      //println(manustring) // ok, Zahl
      
      let manufactorername = String.fromCString(UnsafePointer(manu))
      println("str: %s", manufactorername!)
      manufactorer.stringValue = manufactorername!
      
      /*
      var strA = ""
      strA.append(Character("d"))
      strA.append(UnicodeScalar("e"))
      println(strA)
      
      let x = manu
      let s = "manufactorer"
      println("The \(s) is \(manu)")
      var pi = 3.14159
      NSLog("PI: %.7f", pi)
      let avgTemp = 66.844322156
      println(NSString(format:"AAA: %.2f", avgTemp))
      */
      }
      */
      
   }
   
   // https://nabtron.com/quit-cocoa-app-window-close/
   
   @nonobjc func windowShouldClose(_ sender: Any) 
   {
      print("windowShouldClose")
      
      NSApplication.shared.terminate(self)
   }
   
   override var representedObject: Any? 
      {
      didSet {
         // Update the view, if already loaded.
      }
   }
   
   func getPlist(withName name: String) -> [String]?
   {
      // https://learnappmaking.com/plist-property-list-swift-how-to/
      if  let path = Bundle.main.path(forResource: name, ofType: "plist"),
         let xml = FileManager.default.contents(atPath: path)
      {
         return (try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil)) as? [String]
      }
      
      return nil
   }
   
   
   //MARK: Konstanten
   // const fuer USB
   let SET_0:UInt8 = 0xA1
   let SET_1:UInt8 = 0xB1
   
   let SET_2:UInt8 = 0xC1
   let SET_3:UInt8 = 0xD1
   
   let SET_ROB:UInt8 = 0xA2
   
   let SET_P:UInt8 = 0xA3
   let GET_P:UInt8 = 0xB3
   
   let SIN_START:UInt8 = 0xE0
   let SIN_END:UInt8 = 0xE1
   
   let U_DIVIDER:Float = 9.8
   let ADC_REF:Float = 3.26
   
   let ACHSE0_BYTE_H = 4
   let ACHSE0_BYTE_L = 5
   let ACHSE0_START_BYTE_H = 6
   let ACHSE0_START_BYTE_L = 7

   
   let ACHSE1_BYTE_H = 11
   let ACHSE1_BYTE_L = 12
   let ACHSE1_START_BYTE_H = 13
   let ACHSE1_START_BYTE_L = 14
  
   let ACHSE2_BYTE_H = 17
   let ACHSE2_BYTE_L = 18
   let ACHSE2_START_BYTE_H = 19
   let ACHSE2_START_BYTE_L = 20
   
   let ACHSE3_BYTE_H = 23
   let ACHSE3_BYTE_L = 24
   let ACHSE3_START_BYTE_H = 25
   let ACHSE3_START_BYTE_L = 26

   let HYP_BYTE_H = 32 // Hypotenuse
   let HYP_BYTE_L = 33
   
   let INDEX_BYTE_H = 34
   let INDEX_BYTE_L = 35
   
   let STEPS_BYTE_H = 36
   let STEPS_BYTE_L = 37
   
   
   
  
   
   //MARK:      Outlets 
   @IBOutlet weak var Device: NSTabView!
   @IBOutlet weak var manufactorer: NSTextField!
   @IBOutlet weak var Counter: NSTextField!
   
   @IBOutlet weak var Start_Knopf: NSButton!
   @IBOutlet weak var Stop_Knopf: NSButton!
   @IBOutlet weak var Send_Knopf: NSButton!
   @IBOutlet weak var Start_Read_Knopf: NSButton!
   
   @IBOutlet weak var Anzeige: NSTextField!
   
   //@IBOutlet weak var USB_OK: NSTextField!
   @IBOutlet weak var USB_OK_Feld: NSImageView!
   
   @IBOutlet weak var check_USB_Knopf: NSButton!
   
   
   //@IBOutlet weak var start_read_USB_Knopf: NSButtonCell!
   
   @IBOutlet weak var codeFeld: NSTextField!
   
   @IBOutlet weak var dataFeld: NSTextField!
   
   @IBOutlet weak var schrittweiteFeld: NSTextField!
   
   @IBOutlet weak var Pot0_Feld: NSTextField!
   @IBOutlet weak var Pot0_Slider: NSSlider!
   @IBOutlet weak var Pot0_Stepper_H: NSStepper!
   @IBOutlet weak var Pot0_Stepper_L: NSStepper!
   @IBOutlet weak var Pot0_Stepper_L_Feld: NSTextField!
   @IBOutlet weak var Pot0_Stepper_H_Feld: NSTextField!
   @IBOutlet weak var Pot0_Inverse_Check: NSButton!
   
   @IBOutlet weak var joystick_x: NSTextField!
   @IBOutlet weak var joystick_y: NSTextField!
   
   @IBOutlet weak var goto_x: NSTextField!
   @IBOutlet weak var goto_x_Stepper: NSStepper!
   @IBOutlet weak var goto_y: NSTextField!
   @IBOutlet weak var goto_y_Stepper: NSStepper!
   
   @IBOutlet weak var Pot1_Feld_raw: NSTextField!
   @IBOutlet weak var Pot1_Feld: NSTextField!
   @IBOutlet weak var Pot1_Slider: NSSlider!
   @IBOutlet weak var Pot1_Stepper_H: NSStepper!
   @IBOutlet weak var Pot1_Stepper_L: NSStepper!
   @IBOutlet weak var Pot1_Stepper_L_Feld: NSTextField!
   @IBOutlet weak var Pot1_Stepper_H_Feld: NSTextField!
   @IBOutlet weak var Pot1_Inverse_Check: NSButton!
   
   @IBOutlet weak var Pot2_Feld_raw: NSTextField!
   @IBOutlet weak var Pot2_Feld: NSTextField!
   @IBOutlet weak var Pot2_Slider: NSSlider!
   @IBOutlet weak var Pot2_Stepper: NSStepper!
   @IBOutlet weak var Pot2_Stepper_H: NSStepper!
   @IBOutlet weak var Pot2_Stepper_L: NSStepper!
   @IBOutlet weak var Pot2_Stepper_L_Feld: NSTextField!
   @IBOutlet weak var Pot2_Stepper_H_Feld: NSTextField!
   @IBOutlet weak var Pot2_Inverse_Check: NSButton!
   
   @IBOutlet weak var Pot3_Feld_raw: NSTextField!
   @IBOutlet weak var Pot3_Feld: NSTextField!
   @IBOutlet weak var Pot3_Slider: NSSlider!
   @IBOutlet weak var Pot3_Stepper: NSStepper!
   @IBOutlet weak var Pot3_Stepper_H: NSStepper!
   @IBOutlet weak var Pot3_Stepper_L: NSStepper!
   @IBOutlet weak var Pot3_Stepper_L_Feld: NSTextField!
   @IBOutlet weak var Pot3_Stepper_H_Feld: NSTextField!
   @IBOutlet weak var Pot3_Inverse_Check: NSButton!
   
   @IBOutlet weak var Joystickfeld: rJoystickView!
   
   @IBOutlet weak var clear_Ring: NSButton!
   @IBOutlet weak var emitterFeld: NSTextField!
   
}

extension NSBezierPath
{
   func rotateAroundCenter(angle: CGFloat)
   {
      let midh = NSMidX(self.bounds)/2
      let midv = NSMidY(self.bounds)/2
      let center = NSMakePoint(midh, midv)
      var transform = NSAffineTransform()
      //     transform.rotate(byDegrees: angle)
      //     self.transform(using: transform as AffineTransform)
      
      let originBounds:NSRect = NSMakeRect(NSZeroPoint.x, NSZeroPoint.y , self.bounds.size.width, self.bounds.size.height )
      Swift.print("rotateAround bounds vor rotate origin x: \(self.bounds.origin.x) y: \(self.bounds.origin.y) size h: \(self.bounds.height) w: \(self.bounds.width)")
      
      transform = NSAffineTransform()
      transform.translateX(by: +(NSWidth(originBounds) / 2 ), yBy: +(NSHeight(originBounds) / 2))
      transform.rotate(byDegrees: angle)
      transform.translateX(by: -(NSWidth(originBounds) / 2 ), yBy: -(NSHeight(originBounds) / 2))
      
      //   transform = transform.rotated(by: angle)
      //   transform = transform.translatedBy(x: -center.x, y: -center.y)
      self.transform(using:transform as AffineTransform)
      
      Swift.print("rotateAround bounds nach rotate origin x: \(self.bounds.origin.x) y: \(self.bounds.origin.y) size h: \(self.bounds.height) w: \(self.bounds.width)")
      
   }
   
   // https://stackoverflow.com/questions/50012606/how-to-rotate-uibezierpath-around-center-of-its-own-bounds
   func rotateAroundCenterB(angle: CGFloat)
   {
      let midh = NSMidX(self.bounds)
      let midv = NSMidY(self.bounds)
      let center = NSMakePoint(midh, midv)

      var transform = NSAffineTransform()
      transform.translateX(by: center.x, yBy: center.y)
      transform.rotate(byDegrees: angle)
      transform.translateX(by: -center.x, yBy: -center.y)
      self.transform(using:transform as AffineTransform)
   }
}
