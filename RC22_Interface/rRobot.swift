//
//  rRobot.swift
//  Robot_Interface
//
//  Created by Ruedi Heimlicher on 12.09.2019.
//  Copyright © 2019 Ruedi Heimlicher. All rights reserved.
//

import Cocoa

let LOK_0_ADDRESS:UInt8 = 0xA0
let LOK_0_SPEED:UInt8 = 0xB0
let LOK_0_DIR:UInt8 = 0xC0
let LOK_0_FUNKTION:UInt8 = 0xD0
let LOK_0_PAUSE:UInt8 = 0xE0

let LOK_FAKTOR0:Float = 1
let LOK0_START:UInt16 = 0  // Startwert Slider 1
let LOK0_OFFSET:UInt16 = 8 // Startwert low


// 
let LOK_1_ADDRESS:UInt8 = 0xA1
let LOK_1_SPEED:UInt8 = 0xB1
let LOK_1_DIR:UInt8 = 0xC1
let LOK_1_FUNKTION:UInt8 = 0xD1
let LOK_1_PAUSE:UInt8 = 0xE1

let LOK_1:UInt8 = 0xA1
let LOK1_START:UInt16 = 0 // Startwert Slider 1
let LOK1_OFFSET:UInt16 = 8 // Startwert low
let LOK_FAKTOR1:Float = 1


let LOK_2_ADDRESS:UInt8 = 0xA2
let LOK_2_SPEED:UInt8 = 0xB2
let LOK_2_DIR:UInt8 = 0xC2
let LOK_2_FUNKTION:UInt8 = 0xD2
let LOK_2_PAUSE:UInt8 = 0xE2

let LOK_2:UInt8 = 0xA2
let LOK2_START:UInt16 = 0 // Startwert Slider 1
let LOK2_OFFSET:UInt16 = 8 // starteinstellung
let LOK_FAKTOR2:Float = 1

let LOK_3_ADDRESS:UInt8 = 0xA3
let LOK_3_SPEED:UInt8 = 0xB3
let LOK_3_DIR:UInt8 = 0xC3
let LOK_3_FUNKTION:UInt8 = 0xD3
let LOK_3_PAUSE:UInt8 = 0xE3


let ANZLOKS:Int = 4

let LOCAL = 0
let USB = 1


var addresscodearray = [LOK_0_ADDRESS,LOK_1_ADDRESS,LOK_2_ADDRESS,LOK_3_ADDRESS]
var speedcodearray = [LOK_0_SPEED,LOK_1_SPEED,LOK_2_SPEED,LOK_3_SPEED]
var dircodearray = [LOK_0_DIR,LOK_1_DIR,LOK_2_DIR,LOK_3_DIR]
var funktioncoderray = [LOK_0_FUNKTION,LOK_1_FUNKTION,LOK_2_FUNKTION,LOK_3_FUNKTION]

var rng = SystemRandomNumberGenerator()

class rRobot: rViewController 
{

   @IBOutlet weak var Intervalltimer_Feld: NSTextField!
   @IBOutlet weak var Intervalltimer_Stepper: NSStepper!

   @IBOutlet weak var Pause_Feld: NSTextField!
   @IBOutlet weak var Pause_Stepper: NSStepper!
   
   
   @IBOutlet  weak var RobotarmFeld:rRobotarm!
   
   @IBOutlet  weak var DrehknopfFeld:rDrehknopfView!
   
   @IBOutlet weak var Drehknopf_Feld: NSTextField!
   @IBOutlet weak var Drehknopf_Feld_raw: NSTextField!
   
   @IBOutlet weak var Drehknopf_Stepper_H: NSStepper!
   @IBOutlet weak var Drehknopf_Stepper_L: NSStepper!
   @IBOutlet weak var Drehknopf_Stepper_L_Feld: NSTextField!
   @IBOutlet weak var Drehknopf_Stepper_H_Feld: NSTextField!
   
    
   
   @IBOutlet weak var pos0Feld: NSTextField!
   @IBOutlet weak var pos1Feld: NSTextField!
   @IBOutlet weak var pos2Feld: NSTextField!
   
   @IBOutlet weak var intpos0Feld: NSTextField!
   @IBOutlet weak var intpos1Feld: NSTextField!
   @IBOutlet weak var intpos2Feld: NSTextField!
  
   @IBOutlet weak var TeensyPot0Feld: NSTextField!
   @IBOutlet weak var TeensyPot1Feld: NSTextField!
   @IBOutlet weak var TeensyPot2Feld: NSTextField!
   @IBOutlet weak var TeensyPot3Feld: NSTextField!

   @IBOutlet weak var LocalTaste: NSButton!
   
   @IBOutlet weak var Lok_0_RichtungTaste: NSButton!
   @IBOutlet weak var Lok_1_RichtungTaste: NSButton!
   @IBOutlet weak var Lok_2_RichtungTaste: NSButton!
   
   @IBOutlet weak var Lok_0_FunktionTaste: NSButton!
   @IBOutlet weak var Lok_1_FunktionTaste: NSButton!
   @IBOutlet weak var Lok_2_FunktionTaste: NSButton!

   
   @IBOutlet weak var a0: NSSegmentedControl!
   @IBOutlet weak var a1: NSSegmentedControl!
   @IBOutlet weak var a2: NSSegmentedControl!
   @IBOutlet weak var a3: NSSegmentedControl!

   @IBOutlet weak var b0: NSSegmentedControl!
   @IBOutlet weak var b1: NSSegmentedControl!
   @IBOutlet weak var b2: NSSegmentedControl!
   @IBOutlet weak var b3: NSSegmentedControl!

   @IBOutlet weak var c0: NSSegmentedControl!
   @IBOutlet weak var c1: NSSegmentedControl!
   @IBOutlet weak var c2: NSSegmentedControl!
   @IBOutlet weak var c3: NSSegmentedControl!
   
   
   @IBOutlet weak var loknummer: NSSegmentedControl!
   
   @IBOutlet weak var autospeedtaste: NSButton!
   @IBOutlet weak var autospeedmaxstepper: NSStepper!
   @IBOutlet weak var autospeedmaxfeld: NSTextField!
   @IBOutlet weak var autospeedminstepper: NSStepper!
   @IBOutlet weak var autospeedminfeld: NSTextField!
    @IBOutlet weak var autospeedrandomfeld: NSTextField!
   
     
   var hintergrundfarbe = NSColor()
   
   var lastwinkel:CGFloat = 3272
   
   var geometrie = geom()
   
   var wegmarke:UInt16 = 0
   
    var timerintervall:UInt8 = 13
   
   var startzeit:Int64 = 0
   
   var spee0darray:[UInt8] = [UInt8](repeating: 0x00, count: 5)
   var spee1darray:[UInt8] = [UInt8](repeating: 0x00, count: 5)
   var spee2darray:[UInt8] = [UInt8](repeating: 0x00, count: 5)
   var spee3darray:[UInt8] = [UInt8](repeating: 0x00, count: 5)
   
   
   
   var lok0array:[UInt8] = [UInt8](repeating: 0x00, count:16)
   var lok1array:[UInt8] = [UInt8](repeating: 0x00, count:16)
   var lok2array:[UInt8] = [UInt8](repeating: 0x00, count:16)
   var lok3array:[UInt8] = [UInt8](repeating: 0x00, count:16)
   
   var address0array:[UInt8] = [UInt8](repeating: 0x00, count: 4)
   var address1array:[UInt8] = [UInt8](repeating: 0x00, count: 4)
   var address2array:[UInt8] = [UInt8](repeating: 0x00, count: 4)
   var address3array:[UInt8] = [UInt8](repeating: 0x00, count: 4)
   
   var addressarray = Array(repeating: Array(repeating: UInt8(0x00), count: ANZLOKS), count: 3)
   
   var speedarray:[UInt8] = [UInt8](repeating: 0x00, count: ANZLOKS)
   
   var speedautocounter = 0
   var sinarray:[UInt8] = [10,11,12,13,14,14,13,12,11,10,8,7,6,5,5,6,7,8,9]
   var pause:UInt8 = 5
   
   var firstrun = 1 // Task in Startloop
   
   var sourcestatus = 0
   override func viewDidAppear() 
   {
      //print ("Robot viewDidAppear selectedDevice: \(selectedDevice)")
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
 //     NotificationCenter.default.addObserver(self, selector:#selector(joystickAktion(_:)),name:NSNotification.Name(rawValue: "joystick"),object:nil)
      NotificationCenter.default.addObserver(self, selector:#selector(usbstatusAktion(_:)),name:NSNotification.Name(rawValue: "usb_status"),object:nil)
      NotificationCenter.default.addObserver(self, selector:#selector(drehknopfAktion(_:)),name:NSNotification.Name(rawValue: "drehknopf"),object:nil)
      
  //    UserDefaults.standard.removeObject(forKey: "robot1_min")
  //    UserDefaults.standard.removeObject(forKey: "robot2_min")

      Pot0_Slider.integerValue = Int(LOK0_START)
      Pot0_Feld.integerValue = 0 //Int(Pot0_Slider.floatValue * LOK_FAKTOR0)
      
      let a0seg  = Int(UserDefaults.standard.string(forKey: "a0index") ?? "0")
      let a1seg  = Int(UserDefaults.standard.string(forKey: "a1index") ?? "0")
      let a2seg  = Int(UserDefaults.standard.string(forKey: "a2index") ?? "0")
      let a3seg  = Int(UserDefaults.standard.string(forKey: "a3index") ?? "0")
      
      // Adresse einstellen
      a0.selectSegment(withTag:  a0seg ?? 0)
      a1.selectSegment(withTag:  a1seg ?? 0)
      a2.selectSegment(withTag:  a2seg ?? 0)
      a3.selectSegment(withTag:  a3seg ?? 0)

      
      
      let b0seg  = Int(UserDefaults.standard.string(forKey: "b0index") ?? "0")
      let b1seg  = Int(UserDefaults.standard.string(forKey: "b1index") ?? "0")
      let b2seg  = Int(UserDefaults.standard.string(forKey: "b2index") ?? "0")
      let b3seg  = Int(UserDefaults.standard.string(forKey: "b3index") ?? "0")
      
 //     print("viewDidLoad b seg: \(b0seg) \(b1seg) \(b2seg) \(b3seg)")

      
      b0.selectSegment(withTag:  b0seg ?? 0)
      b1.selectSegment(withTag:  b1seg ?? 0)
      b2.selectSegment(withTag:  b2seg ?? 0)
      b3.selectSegment(withTag:  b3seg ?? 0)

      print("viewDidLoad b: \(b0.indexOfSelectedItem) \(b1.indexOfSelectedItem) \(b2.indexOfSelectedItem) \(b3.indexOfSelectedItem)")

      let c0seg  = Int(UserDefaults.standard.string(forKey: "c0index") ?? "0")
      let c1seg  = Int(UserDefaults.standard.string(forKey: "c1index") ?? "0")
      let c2seg  = Int(UserDefaults.standard.string(forKey: "c2index") ?? "0")
      let c3seg  = Int(UserDefaults.standard.string(forKey: "c3index") ?? "0")
      
      c0.selectSegment(withTag:  c0seg ?? 0)
      c1.selectSegment(withTag:  c1seg ?? 0)
      c2.selectSegment(withTag:  c2seg ?? 0)
      c3.selectSegment(withTag:  c3seg ?? 0)

      print("viewDidLoad c: \(c0.indexOfSelectedItem) \(c1.indexOfSelectedItem) \(c2.indexOfSelectedItem) \(c3.indexOfSelectedItem)")

      
      
      pause = UInt8(UserDefaults.standard.string(forKey: "pause") ?? "5" ) ?? 5
      Pause_Feld.integerValue = Int(pause)
      Pause_Stepper.integerValue = Int(pause)

      
      
      timerintervall = UInt8(UserDefaults.standard.string(forKey: "timerintervall") ?? "13") ?? 13
      
      Intervalltimer_Feld.integerValue = Int((timerintervall));
      Intervalltimer_Stepper.integerValue = Int((timerintervall));
     
      
      //print("UserDefaults a0seg: \(a0seg)")
      
     /* 
      address0array[0] = UInt8(a0seg ?? 0)
      address0array[1] = UInt8(a1seg ?? 0)
      address0array[2] = UInt8(a2seg ?? 0)
      address0array[3] = UInt8(a3seg ?? 0)
      */
      
      
      addressarray[0][0] = UInt8(a0seg ?? 0)
      addressarray[0][1] = UInt8(a1seg ?? 0)
      addressarray[0][2] = UInt8(a2seg ?? 0)
      addressarray[0][3] = UInt8(a3seg ?? 0)
      
      lok0array[0] = UInt8(a0seg ?? 0)
      lok0array[1] = UInt8(a1seg ?? 0)
      lok0array[2] = UInt8(a2seg ?? 0)
      lok0array[3] = UInt8(a3seg ?? 0)
      print("lok0array: \(lok0array)")
     
      // Lokadresse 0 schicken
      teensy.write_byteArray[8] = UInt8(a0seg ?? 0)
      teensy.write_byteArray[9] = UInt8(a1seg ?? 0)
      teensy.write_byteArray[10] = UInt8(a2seg ?? 0)
      teensy.write_byteArray[11] = UInt8(a3seg ?? 0)
      
      teensy.write_byteArray[16] = 0 // Funktion
      teensy.write_byteArray[17] = 0 // speed
      teensy.write_byteArray[18] = timerintervall // step speed
      teensy.write_byteArray[19] = pause // pause
      
     /* 
      address1array[0] = UInt8(b0seg ?? 0)
      address1array[1] = UInt8(b1seg ?? 0)
      address1array[2] = UInt8(b2seg ?? 0)
      address1array[3] = UInt8(b3seg ?? 0)
       */
      
      addressarray[1][0] = UInt8(b0seg ?? 0)
      addressarray[1][1] = UInt8(b1seg ?? 0)
      addressarray[1][2] = UInt8(b2seg ?? 0)
      addressarray[1][3] = UInt8(b3seg ?? 0)
  
      addressarray[2][0] = UInt8(c0seg ?? 0)
      addressarray[2][1] = UInt8(c1seg ?? 0)
      addressarray[2][2] = UInt8(c2seg ?? 0)
      addressarray[2][3] = UInt8(c3seg ?? 0)
      
     
      
      Pot1_Slider.integerValue = Int(LOK1_START)
      Pot1_Feld.integerValue = Int(Pot1_Slider.floatValue * LOK_FAKTOR1)
      
 
      
      Pot2_Slider.integerValue = Int(LOK2_START)
      Pot2_Feld.integerValue = Int(Pot2_Slider.floatValue * LOK_FAKTOR2)

       
        
       
      
      teensy.write_byteArray[0] = LOK_0_ADDRESS // Lok 0
   
      if (globalusbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         print("Robot viewDidLoad senderfolg: \(senderfolg)")
      }
      
      
      
      
      
      /*
       
       Pot1_Feld.integerValue = Int(UInt16(Float(ACHSE1_START) * LOK_FAKTOR1))
       */
      
      Drehknopf_Stepper_H_Feld.integerValue = Int(DrehknopfFeld.maxwinkel)
      Drehknopf_Stepper_H.integerValue = Int(DrehknopfFeld.maxwinkel)
      
      Drehknopf_Stepper_L_Feld.integerValue = Int(DrehknopfFeld.minwinkel)
      Drehknopf_Stepper_L.integerValue = Int(DrehknopfFeld.minwinkel)
      
      DrehknopfFeld.hgfarbe = hgfarbe
      print("Robot globalusbstatus: \(globalusbstatus)")
      
      loknummer.selectSegment(withTag: 0)
      
      autospeedmaxstepper.integerValue = 5
      autospeedmaxfeld.integerValue = autospeedmaxstepper.integerValue

      autospeedminstepper.integerValue = 1
      autospeedminfeld.integerValue = autospeedminstepper.integerValue
      

   }
   
   
   
   @nonobjc override func 
      windowShouldClose(_ sender: Any) 
   {
      
      print("Robot windowShouldClose")
      NSApplication.shared.terminate(self)
   }
   
   
   @objc func usbstatusAktion(_ notification:Notification) 
   {
      let info = notification.userInfo
      let status = info?["usbstatus"] as! Int // 
      let manufactorer = info?["manufactorer"] as! String
     print("Robot usbstatusAktion:\t \(status) manufactorer: \(manufactorer)")
      usbstatus = (status)
   }
   
   @objc override func newDataAktion(_ notification:Notification) 
   {
      let lastData = teensy.getlastDataRead()
      //print("lastData:\t \(lastData[1])\t\(lastData[2])   ")
      var ii = 0
      while ii < 10
      {
         //print("ii: \(ii)  wert: \(lastData[ii])\t")
         ii = ii+1
      }
      
      let u = ((Int32(lastData[1])<<8) + Int32(lastData[2]))
      //print("hb: \(lastData[1]) lb: \(lastData[2]) u: \(u)")
      let info = notification.userInfo
      
      //print("info: \(String(describing: info))")
      //print("new Data")
      let data = notification.userInfo?["data"] as! [UInt8]
      //print("data: \(String(describing: data)) \n") // data: Optional([0, 9, 51, 0,....
      
      
      //print("lastDataRead: \(lastDataRead)   ")
      var i = 0
      var teensypotwerte:[UInt8] = [UInt8](repeating: 0x00, count: 20)
      while i < 20
      {
         teensypotwerte[i] = data[i]
      //   print("i: \(i)  wert: \(data[i])\t")
         i = i+1
      }
      print("teensypotwerte: \(teensypotwerte[16])")
      TeensyPot0Feld.integerValue = Int(teensypotwerte[16])
      
      var emitter = UInt16(data[13]) << 8  | UInt16(data[12])
      
//      print("emitteradresse: \(data[10]) emitterwerte: \(data[12]) \(data[13]) emitter: \(emitter)")
//      print("emitter: \(emitter)")

      emitterFeld.integerValue = Int(emitter)
      /*
      if let d:[UInt8] = (notification.userInfo!["usbdata"] as! [UInt8]) 
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
            while i < 20
            {
               let dd = d[i] as uint8
               print("i: \(i)  wert: \(dd)\t")
               i = i+1
            }
            
         }
         
         
         //print("dic end\n")
      }
 */
      
      //let dic = notification.userInfo as? [String:[UInt8]]
      //print("dic: \(dic ?? ["a":[123]])\n")
      
   }
   
   @objc  func drehknopfAktion(_ notification:Notification) 
   {
      //print("Robot drehknopfAktion usbstatus:\t \(usbstatus)  globalusbstatus: \(globalusbstatus) selectedDevice: \(selectedDevice) ident: \(String(describing: self.view.identifier))")
      let sel = NSUserInterfaceItemIdentifier(selectedDevice)
      if (sel == self.view.identifier)
      {
         // print("Robot drehknopfAktion passt")
         teensy.write_byteArray[0] = DREHKNOPF
         
         let info = notification.userInfo
         
         // ident als String: s. joystickaktion
         //     let ident = Int(info?["ident"] as! String) 
         let punkt:CGPoint = info?["punkt"] as! CGPoint
         
         let winkel = (punkt.x ) // Winkel in Grad. Nullpunkt senkrecht
         
         
         let winkel2 = Int(10*(winkel + 180)) // 
         Drehknopf_Feld.integerValue = Int(winkel)
         let h = Double(Joystickfeld.bounds.size.height)
         let randbereich = abs(DrehknopfFeld.minwinkel) + abs(DrehknopfFeld.maxwinkel)
         let drehknopfnormierung = 360/(360 - randbereich )
         
         // minwinkel ist negativ von Scheitelpunkt aus
         let wert = CGFloat(Float((winkel + 180 + (DrehknopfFeld.minwinkel))*drehknopfnormierung) * DREHKNOPF_FAKTOR) // red auf 0
         Drehknopf_Feld_raw.integerValue = Int(wert)
        
         print("Robot drehknopfAktion winkel: \(winkel) wert: \(wert)")
         
         var achse0:UInt16 = 0
         if (wert > 0)
         {
            achse0 =  UInt16(wert)
            lastwinkel = wert
         }
         else
         {
            //achse0 = UInt16(lastwinkel)
         }
         
         //
         //ACHSE0_START_BYTE_H
 //        let achse0_start = 
 //        print("Robot drehknopfAktion achse0: \(achse0)")
         //print("Drehknopf winkel: \(winkel) winkel2: \(winkel2) *** normierung: \(drehknopfnormierung)   wert: \(wert) achse0: \(achse0)")
         
         teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8((achse0 & 0xFF00) >> 8) // hb
         teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8((achse0 & 0x00FF) & 0xFF) // lb
         
         let startint = UInt(0x680)
         teensy.write_byteArray[ACHSE0_START_BYTE_H] = UInt8((startint & 0xFF00) >> 8) // hb
         teensy.write_byteArray[ACHSE0_START_BYTE_L] = UInt8((startint & 0x00FF) & 0xFF) // lb

         if (globalusbstatus > 0)
         {
            let senderfolg = teensy.send_USB()
            print("Robot Drehknopfaktion senderfolg: \(senderfolg)")
         }         
      } // identifier passt
   }
   @objc func setDrehknopfwinkel(winkel:Float)
   {
      print("Robot setDrehknopfwinkel winkel:\t \(winkel)") 
   }
   
   // MARK joystick
   @objc override func joystickAktion(_ notification:Notification) 
   {
          print("Robot joystickAktion usbstatus:\t \(usbstatus)  selectedDevice: \(selectedDevice) ident: \(String(describing: self.view.identifier))")
      let sel = NSUserInterfaceItemIdentifier.init(selectedDevice)
      //  if (selectedDevice == self.view.identifier)
      //var ident = ""
      if (sel == self.view.identifier)
      {
         print("Robot joystickAktion passt")
         
         var ident = "13"
         let info = notification.userInfo 
         print("Robot joystickAktion info: \(info)")
         let i = info?["ident"]
         print("Robot joystickAktion i: \(i)")
         if let joystickident = info?["ident"]as? String
         {
            print("Robot joystickAktion ident da: \(joystickident)")
            ident = joystickident
         }
         else
         {
            print("Robot joystickAktion ident nicht da")
         }
         // let id = NSUserInterfaceItemIdentifier.init(rawValue:(info?["ident"] as! NSString) as String)
         
         
         //   let ident = "aa" //info["ident"] as! String 
         let punkt:CGPoint = info?["punkt"] as! CGPoint
         
         
         let wegindex:Int = info?["index"] as! Int // 
         let first:Int = info?["first"] as! Int
         
         //      print("Robot joystickAktion:\t \(punkt)")
         //      print("x: \(punkt.x) y: \(punkt.y) index: \(wegindex) first: \(first) ident: \(ident)")
         
         
         if ident == "3001" // Drehknopf
         {
            print("Drehknopf ident 2001")
            teensy.write_byteArray[0] = DREHKNOPF
            let winkel = Int(punkt.x )
            print("Drehknopf winkel: \(winkel)")
         }
         else if ident == "3000"
            
         {
            
            teensy.write_byteArray[0] = SET_ROB // Code 
            
            // Horizontal Pot0
            let w = Double(Joystickfeld.bounds.size.width) // Breite Joystickfeld
            let faktorw:Double = (Pot0_Slider.maxValue - Pot0_Slider.minValue) / w  // Normierung auf Feldbreite
            //      print("w: \(w) faktorw: \(faktorw)")
            var x = Double(punkt.x)
            if (x > w)
            {
               x = w
            }
            /*
             goto_x.integerValue = Int(Float(x*faktorw))
             joystick_x.integerValue = Int(Float(x*faktorw))
             goto_x_Stepper.integerValue = Int(Float(x*faktorw))
             */
            let achse0 = UInt16(Float(x*faktorw) * LOK_FAKTOR0)
            //print("x: \(x) achse0: \(achse0)")
            teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8((achse0 & 0xFF00) >> 8) // hb
            teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8((achse0 & 0x00FF) & 0xFF) // lb
            
            
            let h = Double(Joystickfeld.bounds.size.height)
            let faktorh:Double = (Pot1_Slider.maxValue - Pot1_Slider.minValue) / h  // Normierung auf Feldhoehe
            
            let faktorz = 1
            //     print("h: \(h) faktorh: \(faktorh)")
            var y = Double(punkt.y)
            if (y > h)
            {
               y = h
            }
            let z = 0
            
            /*
             goto_y.integerValue = Int(Float(y*faktorh))
             joystick_y.integerValue = Int(Float(y*faktorh))
             goto_y_Stepper.integerValue = Int(Float(y*faktorh))
             */
            
            let achse1 = UInt16(Float(y*faktorh) * LOK_FAKTOR1)
            //print("y: \(y) achse1: \(achse1)")
            teensy.write_byteArray[ACHSE1_BYTE_H] = UInt8((achse1 & 0xFF00) >> 8) // hb
            teensy.write_byteArray[ACHSE1_BYTE_L] = UInt8((achse1 & 0x00FF) & 0xFF) // lb
            
            let achse2 =  UInt16(Float(z*faktorz) * LOK_FAKTOR2)
            teensy.write_byteArray[ACHSE2_BYTE_H] = UInt8((achse2 & 0xFF00) >> 8) // hb
            teensy.write_byteArray[ACHSE2_BYTE_L] = UInt8((achse2 & 0x00FF) & 0xFF) // lb
            
            let message:String = info?["message"] as! String
            if ((message == "mousedown") && (first >= 0))// Polynom ohne mousedragged
            {
               
               teensy.write_byteArray[0] = SET_RING
               let anz:Int = servoPfad?.anzahlPunkte() ?? 0
               print("robot joystickAktion anz: \(anz)")
               if (wegindex > 1)
               {
                  print("")
                  print("robot joystickAktion cont achse0: \(achse0) achse1: \(achse1)  achse2: \(achse2) anz: \(String(describing: anz)) wegindex: \(wegindex)")
                  
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
                  
                  print("joystickAktion lastx: \(lastx) nextx: \(nextx) lasty: \(lasty) nexty: \(nexty) ***  lastz: \(lastz) nextz: \(nextz)")
                  
                  
                  let hyp:Float = (sqrt((Float(hypx + hypy + hypz)))) // Gesamter Weg ueber x,y,z
                  
    //              let anzahlsteps = hyp/schrittweiteFeld.floatValue
     //             print("Robot joystickAktion hyp: \(hyp) anzahlsteps: \(anzahlsteps) ")
                  
                  teensy.write_byteArray[HYP_BYTE_H] = UInt8((Int(hyp) & 0xFF00) >> 8) // hb
                  teensy.write_byteArray[HYP_BYTE_L] = UInt8((Int(hyp) & 0x00FF) & 0xFF) // lb
                  
  //                teensy.write_byteArray[STEPS_BYTE_H] = UInt8((Int(anzahlsteps) & 0xFF00) >> 8) // hb
  //                teensy.write_byteArray[STEPS_BYTE_L] = UInt8((Int(anzahlsteps) & 0x00FF) & 0xFF) // lb
                  
                  teensy.write_byteArray[INDEX_BYTE_H] = UInt8(((wegindex-1) & 0xFF00) >> 8) // hb // hb // Start, Index 0
                  teensy.write_byteArray[INDEX_BYTE_L] = UInt8(((wegindex-1) & 0x00FF) & 0xFF) // lb
                  
                  print("joystickAktion hypx: \(hypx) hypy: \(hypy) hypz: \(hypz) hyp: \(hyp)")
                  
               }
               else
               {
                  print("robot joystickAktion start achse0: \(achse0) achse1: \(achse1)  achse2: \(achse2) anz: \(anz) wegindex: \(wegindex)")
                  teensy.write_byteArray[HYP_BYTE_H] = 0 // hb // Start, keine Hypo
                  teensy.write_byteArray[HYP_BYTE_L] = 0 // lb
                  teensy.write_byteArray[INDEX_BYTE_H] = 0 // hb // Start, Index 0
                  teensy.write_byteArray[INDEX_BYTE_L] = 0 // lb
                  
               }
               
               servoPfad?.addPosition(newx: achse0, newy: achse1, newz: 0)
               
            }
         } // if 2000
         if (globalusbstatus > 0)
         {
            let senderfolg = teensy.send_USB()
            print("robot joystickaktion  senderfolg: \(senderfolg)")
         }
      }
      else
      {
         //         print("Robot joystickAktion passt nicht")
      }
      
      
   }
   
   //MARK Geometrie
   
   @IBAction  func report_Intervalltimer_Stepper(_ sender: NSStepper) // untere Grenze
   {
      print("report_Intervalltimer_Stepper IntVal: \(sender.integerValue)")
      teensy.write_byteArray[0] = LOK_0_ADDRESS 
      let intpos = sender.integerValue 
      Intervalltimer_Feld.integerValue = intpos
      teensy.write_byteArray[18] = UInt8(intpos)
      timerintervall = UInt8(intpos)
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         print("Robot report_Intervalltimer_Stepper senderfolg: \(senderfolg)")
      }

      
   }

   
   @IBAction  func report_Pause_Stepper(_ sender: NSStepper) // untere Grenze
   {
      print("report_Pause_Stepper IntVal: \(sender.integerValue)")
      teensy.write_byteArray[0] = LOK_0_PAUSE 
      let intpos = sender.integerValue 
      Pause_Feld.integerValue = intpos
      teensy.write_byteArray[19] = UInt8(intpos)
      pause = UInt8(intpos)
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         print("Robot report_Pause_Stepper senderfolg: \(senderfolg)")
      }
      
      
   }
   
   @IBAction  func report_checkadresse(_ sender: NSButton)
   {
      lok0array[12] = LOK_0_ADDRESS
      teensy.write_byteArray[20] = UInt8(loknummer.indexOfSelectedItem)
      for i in 0...3
      {
         for k in 0...3
         {
            
            address0array[i] = UInt8(k)
            print("i: \(i) adresse: \(address0array)")
            
            teensy.write_byteArray[8] = UInt8(k)
            
         }
         //print("i: \(i) adresse: \(address0array)")
      }
      return
      /*
         {
         teensy.write_byteArray[0] = LOK_0_ADDRESS // Code 
         print("Robot report_checkadresse ")
         lok0array[12] = LOK_0_ADDRESS
         let ident:String = ((sender.identifier)!.rawValue)
         var lok:Int = Int(ident)!
         lok /= 100
         //print("Robot report_Address0 lok A: \(lok) ")
         lok %= 10
         print("Robot report_Address0 lok B: \(lok) ")
         switch ident
         {
         case "1000":
            print("Robot report_Address0 index: \(sender.indexOfSelectedItem)")
            lok0array[0] = UInt8((sender.indexOfSelectedItem))
            address0array[0] = UInt8((sender.indexOfSelectedItem))
            teensy.write_byteArray[8] = UInt8((sender.indexOfSelectedItem))
            break;
         case "1001":
            print("Robot report_Address0 index: \(sender.indexOfSelectedItem)")
            lok0array[1] = UInt8((sender.indexOfSelectedItem))
            address0array[1] = UInt8((sender.indexOfSelectedItem))
            teensy.write_byteArray[9] = UInt8((sender.indexOfSelectedItem))
            break;
         case "1002":
            print("Robot report_Address0 index: \(sender.indexOfSelectedItem)")
            lok0array[2] = UInt8((sender.indexOfSelectedItem))
            address0array[2] = UInt8((sender.indexOfSelectedItem))
            teensy.write_byteArray[10] = UInt8((sender.indexOfSelectedItem))
            break;
         case "1003":
            print("Robot report_Address0 index: \(sender.indexOfSelectedItem)")
            lok0array[3] = UInt8((sender.indexOfSelectedItem))
            address0array[3] = UInt8((sender.indexOfSelectedItem))
            teensy.write_byteArray[11] = UInt8((sender.indexOfSelectedItem))
            break;
         default:
            break;
         }
         print("lok0array: \(lok0array)")
         print("address0array: \(address0array)")
         
         //      teensy.write_byteArray[9] = UInt8((sender.indexOfSelectedItem))
         //      teensy.write_byteArray[10] = UInt8((sender.indexOfSelectedItem))
         //      teensy.write_byteArray[11] = UInt8((sender.indexOfSelectedItem))
         
         //      teensy.write_byteArray[16] = 0 // Richtung
         //      teensy.write_byteArray[17] = 0 // speed
         
         if (usbstatus > 0)
         {
            let senderfolg = teensy.send_USB()
            print("Robot report_Address0 senderfolg: \(senderfolg)")
         }
      }
 */
   }
   
   @objc func loadLokAddress(lok:Int)
   {
   //   print("loadLokAddress lok: \(lok)")
      for i in 0...3
      {
         teensy.write_byteArray[8 + i] = addressarray[lok][i]
         //print(addressarray[lok][i])
      }
      //print("loadLokAddress\(teensy.write_byteArray[8...18])")
    } // loadLokAddress
   
   @objc func loadFunktion(lok:Int)
   {
      
      let loktag = Lok_2_FunktionTaste.tag - 3000
      if loktag == lok
      {
         var funktion:UInt8 = 0
         if Lok_2_FunktionTaste.state == .on
         {
            funktion = 1
         }
         teensy.write_byteArray[16] = funktion // Richtung
      }
      
   }
   
   @objc func loadSpeed(lok:Int)
   {
      teensy.write_byteArray[20] = UInt8(loknummer.indexOfSelectedItem)
      teensy.write_byteArray[17] = speedarray[lok]
   }
   
   @IBAction  func report_Local(_ sender: NSButton)
   {
      print("report_Local status: \(sender.state.rawValue)")
      let status:UInt8 = UInt8(sender.state.rawValue)
      if status == 0
          {
            sourcestatus |= (1<<LOCAL)
            sourcestatus &= ~(1<<USB)
          }
      else
            {
            sourcestatus &= ~(1<<LOCAL)
            sourcestatus |= (1<<USB)
            }
      teensy.write_byteArray[21] = UInt8(sourcestatus)
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         print("Robot report_Local senderfolg: \(senderfolg)")
      }

   }
   
   @IBAction  func report_Speed_auto(_ sender: NSButton)
   {
      let autospeed = sender.state.rawValue
      
      Pot0_Slider.intValue = 0
      speedautocounter = 0 
      
      startzeit = Int64(NSDate().timeIntervalSince1970)
      if autospeed == 1
      {
         var minspeed = 0
         var maxspeed = 14
         var step = 1
         var interval:Double = 2
         
         var userinformation:NSMutableDictionary = ["minspeed": minspeed, "maxspeed": maxspeed, "step": step, "speedautocounter":speedautocounter] //as! [String : Int]
         var timer : Timer? = nil
         
         timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(speed_auto(_:)), userInfo: userinformation, repeats: true)
      }
      else 
      {
         print("auto off")
      }
   }
   
   @objc func speed_auto(_ timer: Timer)
   {
      if (autospeedtaste.state.rawValue == 1)
      {
         // print("speed_auto : \( timer.userInfo)")
  //       if  var dic = timer.userInfo as? NSMutableDictionary
  //       {
            //print("step: \(dic["step"])")
            speedautocounter += 1
         if speedautocounter > sinarray.count - 1
         {
            speedautocounter = 0
         }
      //      var tempmin:Int = dic["minspeed"] as! Int
      //      var tempmax:Int = dic["maxspeed"] as! Int
     //       var tempspeedautocounter = dic["speedautocounter"] as! Int
            
     var       tempmin = autospeedminstepper.integerValue
     var       tempmax = autospeedmaxstepper.integerValue
     if !(tempmax > tempmin)
     {
      tempmax = tempmin + 1
      }
         
         var sinint = sinarray[speedautocounter]
         print("speedautocounter : \( speedautocounter) sinint: \(sinint)")
         teensy.write_byteArray[0] = speedcodearray[0]
         teensy.write_byteArray[17] = sinint
         //return
         
         var randomInt = Int.random(in: tempmin..<tempmax)
            if randomInt > 0 
            {
               randomInt += 1
            }
            
            
            teensy.write_byteArray[0] = speedcodearray[0]
            if speedautocounter % 5 == 0
            {
               teensy.write_byteArray[17] = 0
               autospeedrandomfeld.integerValue = 0
            }
            else
            {
               teensy.write_byteArray[17] = UInt8(randomInt)
               autospeedrandomfeld.integerValue = randomInt
         //      dic["step"] = randomInt
            }
        var date = Int64(NSDate().timeIntervalSince1970) - startzeit            
         
          
         print("speed_auto : \( autospeedrandomfeld.integerValue) time: \(date)")

            loadLokAddress(lok: 0)
            //teensy.write_byteArray[20] = UInt8(loknummer.indexOfSelectedItem)
            if (usbstatus > 0)
            {
               let senderfolg = teensy.send_USB()
               //print("Robot report_Slider senderfolg: \(senderfolg)")
            }
   //      }
      }
      else 
      {
         timer.invalidate()
         teensy.write_byteArray[17] = 0
         loadLokAddress(lok: 0)
         //teensy.write_byteArray[20] = UInt8(loknummer.indexOfSelectedItem)
         if (usbstatus > 0)
         {
            let senderfolg = teensy.send_USB()
            //print("Robot report_Slider senderfolg: \(senderfolg)")
         }
      }
      
   }
   
   //MARK: Slider 
   @IBAction  func report_Slider(_ sender: NSSlider)
   {
      let loktag = sender.tag - 1000
 //     teensy.write_byteArray[0] = LOK_0_SPEED // Code 
      teensy.write_byteArray[0] = speedcodearray[loktag]
      print("Robot report_Slider loktag \(loktag) IntVal: \(sender.intValue) ")
 //     lok0array[12] = LOK_0_SPEED
   //   print("report_Slider funktioncoderray: \(funktioncoderray) ")
      
      let pos = sender.floatValue
      
  //    let intpos = UInt8(pos * LOK_FAKTOR0)
       let intpos = UInt8(pos)
  //    let Ustring = formatter.string(from: NSNumber(value: intpos))
  //    var speed:UInt8 =  intpos
      var speed:UInt8 =  UInt8(sender.intValue)
      
      print("report_Slider pos: \(pos) intpos: \(intpos)  speed: \(speed)")
      //      print("report_Slider0 speed: \(speed) richtung: \(richtung)")
      if speed > 0
      {
         speed += 1 // speed 1 ist Richtungsumschaltung
      }
      
      speedarray[loktag] = speed
      
   //   print("spee0darray: \(spee0darray)")
   //   print("lok0array vor loadLokAddress: \(lok0array)")
      
      loadLokAddress(lok: loktag)
      
      
      teensy.write_byteArray[17] = speed
      
//      print("teensy.write_byteArray:")
//      print("\(teensy.write_byteArray[8...18])")
       
      (self.view.viewWithTag(2000 + loktag) as! NSTextField).intValue = Int32(pos)
      
      print("report_Slider usbstatus: \(usbstatus)")
      print("report_Slider loknummer: \(loknummer.indexOfSelectedItem)")
      teensy.write_byteArray[20] = UInt8(loknummer.indexOfSelectedItem)
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         //print("Robot report_Slider senderfolg: \(senderfolg)")
      }
   }
   
   
   @IBAction  func report_loknummer(_ sender: NSSegmentedControl)
   {
      let loknummer = sender.indexOfSelectedItem
      print("report_loknummer lok: \(loknummer)")
   }
   
   @IBAction  func report_maxstep(_ sender: NSStepper)
   {
      autospeedmaxfeld.integerValue = sender.integerValue
   }

   @IBAction  func report_minstep(_ sender: NSStepper)
   {
      var minstep = sender.integerValue
      if minstep > autospeedmaxfeld.integerValue
      {
         minstep = autospeedmaxfeld.integerValue
         sender.integerValue = minstep
      }

      autospeedminfeld.integerValue = sender.integerValue
   }

   //MARK: Slider 0
   @IBAction override func report_Slider0(_ sender: NSSlider)
   {
      teensy.write_byteArray[0] = LOK_0_SPEED // Code 
      print("Robot report_Slider0 IntVal: \(sender.intValue) ")
      lok0array[12] = LOK_0_SPEED
      let pos = sender.floatValue
      
      let intpos = UInt8(pos * LOK_FAKTOR0)
      //let Ustring = formatter.string(from: NSNumber(value: intpos))
      var speed:UInt8 =  intpos
      print("report_Slider0 pos: \(pos) intpos: \(intpos)  speed: \(speed)")
      
 //      print("report_Slider0 speed: \(speed) richtung: \(richtung)")
      if speed > 0
      {
         speed += 1 // speed 1 ist Richtungsumschaltung
      }
      spee0darray[1] = speed
      lok0array[6] = speed
      
      speedarray[0] = speed
      
      print("spee0darray: \(spee0darray)")
      print("lok0array: \(lok0array)")
      
      loadLokAddress(lok: sender.tag)
      /*
       // Lokadresse 0 schicken
       teensy.write_byteArray[8] = UInt8(a0seg ?? 0)
       teensy.write_byteArray[9] = UInt8(a1seg ?? 0)
       teensy.write_byteArray[10] = UInt8(a2seg ?? 0)
       teensy.write_byteArray[11] = UInt8(a3seg ?? 0)
       
       teensy.write_byteArray[16] = 0 // Funktion
 */
      
      teensy.write_byteArray[17] = UInt8(speed) // speed
      
      Pot0_Feld.integerValue = Int(pos)
      
      print("usbstatus: \(usbstatus)")
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         print("Robot report_Slider0 senderfolg: \(senderfolg)")
      }
   }
   
   @IBAction  func report_Richtung(_ sender: NSButton)
   {
      let loktag = sender.tag - 4000
      print("report_Richtung state: \(sender.state) tag: \(sender.tag) loktag: \(loktag)")
      
      teensy.write_byteArray[0] = dircodearray[loktag] // Code 
      teensy.write_byteArray[17] = 1 // speed 1: Richtung togglen
      
      (self.view.viewWithTag(loktag + 2000) as! NSTextField).intValue = 0
     (self.view.viewWithTag(loktag + 1000) as! NSSlider).intValue = 0

      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         if (senderfolg < BUFFER_SIZE)
         {
            print("report_Richtung: %d",senderfolg)
         }
      }
      let userinformation = ["tag": loktag] //as! [String : Int]
      var timer : Timer? = nil
      timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(resetfunktion(_:)), userInfo: userinformation, repeats: false)
   }   
   
   @objc open func resetfunktion(_ timer: Timer) // Richtung-Bit resetten
   {
      print("resetfunktion userInfo: \(timer.userInfo ?? "")")
      var loktag = 0xFF
      
      if  var dic = timer.userInfo as? [String : Int] 
      {
         // if var count:Int = dic["tag"]
         if dic["tag"] != nil
         {
            loktag = dic["tag"] ?? 0xFF
         }
      }
      if loktag == 0xFF
      {
         print("resetfunktion kein tag")
         return
      }
      print("resetfunktion userInfo: \(timer.userInfo ?? "") tag: \(loktag) dircode: \(dircodearray[loktag])")

      teensy.write_byteArray[0] = dircodearray[loktag]
      
      teensy.write_byteArray[17] = 0 // Richtungimpuls resetten
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         if (senderfolg <= BUFFER_SIZE)
         {
            print("resetfunktion: \(senderfolg)")
         }
      }
   }
   
   @IBAction  func report_Funktion(_ sender: NSButton)
   {
 //     print("report_Funktion state: \(sender.state) tag: \(sender.tag)")
      let loktag = sender.tag - 3000
      
      teensy.write_byteArray[0] = funktioncoderray[loktag] // Code 
      var funktion:UInt8 = 0
      if sender.state == .on
      {
         funktion = 1
      }
     teensy.write_byteArray[16] = funktion // Richtung
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         if (senderfolg < BUFFER_SIZE)
         {
            print("report_Funktion: %d",senderfolg)
         }
      }
   }
   
   
   @IBAction override func report_set_Pot0(_ sender: NSTextField)
   {
      teensy.write_byteArray[0] = SET_0 // Code 
      
      // senden mit faktor 1000
      //let u = Pot0_Feld.floatValue 
      let Pot0_wert = Pot0_Feld.floatValue * 100
      let Pot0_intwert = UInt(Pot0_wert)
      
      let Pot0_HI = (Pot0_intwert & 0xFF00) >> 8
      let Pot0_LO = Pot0_intwert & 0x00FF
      
      print("Robot report_set_Pot0 Pot0_wert: \(Pot0_wert) Pot0 HI: \(Pot0_HI) Pot0 LO: \(Pot0_LO) ")
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
   // NOT
    @IBAction func report_Address(_ sender: NSSegmentedControl)
    {
      let ident:String = ((sender.identifier)!.rawValue)
      var lok:Int = Int(ident)!
      lok /= 100
      lok %= 10
      
      let subs = self.view.subviews
      let lokseg = 1000 + 100 * lok
      print("Robot report_Address lok: \(lok) lokseg: \(lokseg)")
      let range = lokseg...(lokseg + 3)
      for addressview in self.view.subviews
      {
         let id = Int(addressview.identifier!.rawValue)
         if id != nil && (range.contains(id!) )
         {
            let lok = id!%1000/100
            let pos = id!%1000%100
            let seg = addressview as! NSSegmentedControl
            let ind = seg.indexOfSelectedItem // 
            print("ident da: \(id) lok: \(lok) pos: \(pos) ind: \(ind)")
            addressarray[lok][pos] = UInt8(ind) 
         }
      }
      print("addressarray: \(addressarray)")
   }
   
   @IBAction func report_Address0(_ sender: NSSegmentedControl)
   {
      teensy.write_byteArray[0] = LOK_0_ADDRESS // Code 
      print("Robot report_Address0 ident: \(sender.identifier!.rawValue) ")
      lok0array[12] = LOK_0_ADDRESS
      
      let ident:String = ((sender.identifier)!.rawValue)
      var lok:Int = Int(ident)!
      lok /= 100
      //print("Robot report_Address0 lok A: \(lok) ")
      lok %= 10
      print("Robot report_Address0 lok 0: \(lok)  ident: \(ident) ")
      print("Robot report_Address0 lok0array: \(lok0array)  address0array: \(address0array) ")
      switch ident
      {
      case "1000":
         print("Robot report_Address0 index: \(sender.indexOfSelectedItem)")
         lok0array[0] = UInt8((sender.indexOfSelectedItem))
         address0array[0] = UInt8((sender.indexOfSelectedItem))
         teensy.write_byteArray[8] = UInt8((sender.indexOfSelectedItem))
         break;
      case "1001":
         print("Robot report_Address0 index: \(sender.indexOfSelectedItem)")
         lok0array[1] = UInt8((sender.indexOfSelectedItem))
         address0array[1] = UInt8((sender.indexOfSelectedItem))
         teensy.write_byteArray[9] = UInt8((sender.indexOfSelectedItem))
         break;
      case "1002":
         print("Robot report_Address0 index: \(sender.indexOfSelectedItem)")
         lok0array[2] = UInt8((sender.indexOfSelectedItem))
         address0array[2] = UInt8((sender.indexOfSelectedItem))
         teensy.write_byteArray[10] = UInt8((sender.indexOfSelectedItem))
         break;
      case "1003":
         print("Robot report_Address0 index: \(sender.indexOfSelectedItem)")
         lok0array[3] = UInt8((sender.indexOfSelectedItem))
         address0array[3] = UInt8((sender.indexOfSelectedItem))
         teensy.write_byteArray[11] = UInt8((sender.indexOfSelectedItem))
         break;
      default:
         break;
      }
      print("lok0array: \(lok0array)")
      // aktualisieren nach Aenderung
      address0array[0] = UInt8(a0.indexOfSelectedItem)
      address0array[1] = UInt8(a1.indexOfSelectedItem)
      address0array[2] = UInt8(a2.indexOfSelectedItem)
      address0array[3] = UInt8(a3.indexOfSelectedItem)
      
      /*
      let subs = self.view.subviews
      let range = 1000...1203
      for addressview in self.view.subviews
      {
         let id = Int(addressview.identifier!.rawValue)
         
         if id != nil && (range.contains(id!) )
         {
            let lok = id!%1000/100
            let pos = id!%1000%100
            let seg = addressview as! NSSegmentedControl
            let ind = seg.indexOfSelectedItem
            print("ident da: \(id) lok: \(lok) pos: \(pos) ind: \(ind)")
            addressarray[lok][pos] = UInt8(ind) 
         }
      
      }
      */

      addressarray[0][0] = UInt8(a0.indexOfSelectedItem)
      addressarray[0][1] = UInt8(a1.indexOfSelectedItem)
      addressarray[0][2] = UInt8(a2.indexOfSelectedItem)
      addressarray[0][3] = UInt8(a3.indexOfSelectedItem)

      print("address0array: \(address0array)")
      print("lok0 write_byteArray: \(teensy.write_byteArray)")
      for i in 0...3
      {
         teensy.write_byteArray[8 + i] = addressarray[0][i]
      }

      print("lok0 write_byteArray neu: \(teensy.write_byteArray[8])  \(teensy.write_byteArray[9])  \(teensy.write_byteArray[10])  \(teensy.write_byteArray[11])")
      
//      teensy.write_byteArray[9] = UInt8((sender.indexOfSelectedItem))
//      teensy.write_byteArray[10] = UInt8((sender.indexOfSelectedItem))
//      teensy.write_byteArray[11] = UInt8((sender.indexOfSelectedItem))
      
//      teensy.write_byteArray[16] = 0 // Richtung
//      teensy.write_byteArray[17] = 0 // speed

      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         print("Robot report_Address0 senderfolg: \(senderfolg)")
      }
   }
  
   @IBAction func report_Address1(_ sender: NSSegmentedControl)
   {
      teensy.write_byteArray[0] = LOK_1 // Code 
      print("Robot report_Address1 ident: \(sender.identifier!.rawValue) ")
      lok0array[12] = LOK_1
      let ident:String = ((sender.identifier)!.rawValue)
      var lok:Int = Int(ident)!
      lok /= 100
      //print("Robot report_Address0 lok A: \(lok) ")
      lok %= 10
      print("Robot report_Address1 lok 1: \(lok) ident: \(ident)")
      /*
      switch ident
      {
      case "1100":
         print("Robot report_Address1 index: \(sender.indexOfSelectedItem)")
         lok1array[0] = UInt8((sender.indexOfSelectedItem))
         address1array[0] = UInt8((sender.indexOfSelectedItem))
         teensy.write_byteArray[8] = UInt8((sender.indexOfSelectedItem))
         break;
      case "1101":
         print("Robot report_Address1 index: \(sender.indexOfSelectedItem)")
         lok1array[1] = UInt8((sender.indexOfSelectedItem))
         address1array[1] = UInt8((sender.indexOfSelectedItem))
         teensy.write_byteArray[9] = UInt8((sender.indexOfSelectedItem))
         break;
      case "1102":
         print("Robot report_Address1 index: \(sender.indexOfSelectedItem)")
         lok1array[2] = UInt8((sender.indexOfSelectedItem))
         address1array[2] = UInt8((sender.indexOfSelectedItem))
         teensy.write_byteArray[10] = UInt8((sender.indexOfSelectedItem))
         break;
      case "1103":
         print("Robot report_Address1 index: \(sender.indexOfSelectedItem)")
         lok1array[3] = UInt8((sender.indexOfSelectedItem))
         address1array[3] = UInt8((sender.indexOfSelectedItem))
         teensy.write_byteArray[11] = UInt8((sender.indexOfSelectedItem))
         break;
      default:
         break;
      }
 */
      print("report_Address1 b0: \(b0.indexOfSelectedItem)  b1: \(b1.indexOfSelectedItem)  b2: \(b2.indexOfSelectedItem)  b3: \(b3.indexOfSelectedItem)")
      address1array[0] = UInt8(b0.indexOfSelectedItem)
      address1array[1] = UInt8(b1.indexOfSelectedItem)
      address1array[2] = UInt8(b2.indexOfSelectedItem)
      address1array[3] = UInt8(b3.indexOfSelectedItem)

      addressarray[1][0] = UInt8(b0.indexOfSelectedItem)
      addressarray[1][1] = UInt8(b1.indexOfSelectedItem)
      addressarray[1][2] = UInt8(b2.indexOfSelectedItem)
      addressarray[1][3] = UInt8(b3.indexOfSelectedItem)

      print("lok1array: \(lok1array)")
      print("address1array: \(address1array)")
      print("lok1 write_byteArray vor: \(teensy.write_byteArray)")
      print("lok1 write_byteArray vor: \(teensy.write_byteArray[8])  \(teensy.write_byteArray[9])  \(teensy.write_byteArray[10])  \(teensy.write_byteArray[11])")

      for i in 0...3
      {
         teensy.write_byteArray[8 + i] = addressarray[1][i]
      }
      
//      print("lok1 write_byteArray nach: \(teensy.write_byteArray[8])  \(teensy.write_byteArray[9])  \(teensy.write_byteArray[10])  \(teensy.write_byteArray[11])")
      print("lok1 write_byteArray nach: \(teensy.write_byteArray)")
      //      teensy.write_byteArray[9] = UInt8((sender.indexOfSelectedItem))
      //      teensy.write_byteArray[10] = UInt8((sender.indexOfSelectedItem))
      //      teensy.write_byteArray[11] = UInt8((sender.indexOfSelectedItem))
      
      //      teensy.write_byteArray[16] = 0 // Richtung
      //      teensy.write_byteArray[17] = 0 // speed
      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         print("Robot report_Address1 senderfolg: \(senderfolg)")
      }
   }

   @IBAction func report_Address2(_ sender: NSSegmentedControl)
   {
      teensy.write_byteArray[0] = LOK_2 // Code 
      print("Robot report_Address2 ident: \(sender.identifier!.rawValue) ")
      lok0array[12] = LOK_2
      let ident:String = ((sender.identifier)!.rawValue)
      var lok:Int = Int(ident)!
      lok /= 100
      //print("Robot report_Address2 lok: \(lok) ")
      lok %= 10
      print("Robot report_Address2 lok 2: \(lok) ident: \(ident)")
      print("\nlok2array vor: \(lok2array)")
      switch ident
      {
      case "1200":
         print("Robot report_Address2 index: \(sender.indexOfSelectedItem)")
         lok2array[0] = UInt8((sender.indexOfSelectedItem))
         address2array[0] = UInt8((sender.indexOfSelectedItem))
         teensy.write_byteArray[8] = UInt8((sender.indexOfSelectedItem))
         break;
      case "1201":
         print("Robot report_Address2 index: \(sender.indexOfSelectedItem)")
         lok2array[1] = UInt8((sender.indexOfSelectedItem))
         address2array[1] = UInt8((sender.indexOfSelectedItem))
         teensy.write_byteArray[9] = UInt8((sender.indexOfSelectedItem))
         break;
      case "1202":
         print("Robot report_Address2 index: \(sender.indexOfSelectedItem)")
         lok2array[2] = UInt8((sender.indexOfSelectedItem))
         address2array[2] = UInt8((sender.indexOfSelectedItem))
         teensy.write_byteArray[10] = UInt8((sender.indexOfSelectedItem))
         break;
      case "1203":
         print("Robot report_Address2 index: \(sender.indexOfSelectedItem)")
         lok2array[3] = UInt8((sender.indexOfSelectedItem))
         address2array[3] = UInt8((sender.indexOfSelectedItem))
         teensy.write_byteArray[11] = UInt8((sender.indexOfSelectedItem))
         break;
      default:
         break;
      }
      print("report_Address2 c0: \(c0.indexOfSelectedItem)  c1: \(c1.indexOfSelectedItem)  c2: \(c2.indexOfSelectedItem)  c3: \(c3.indexOfSelectedItem)")
      address2array[0] = UInt8(c0.indexOfSelectedItem)
      address2array[1] = UInt8(c1.indexOfSelectedItem)
      address2array[2] = UInt8(c2.indexOfSelectedItem)
      address2array[3] = UInt8(c3.indexOfSelectedItem)
 
      addressarray[2][0] = UInt8(c0.indexOfSelectedItem)
      addressarray[2][1] = UInt8(c1.indexOfSelectedItem)
      addressarray[2][2] = UInt8(c2.indexOfSelectedItem)
      addressarray[2][3] = UInt8(c3.indexOfSelectedItem)

      print("\nlok2array nach: \(lok2array)")
      print("address2array nach: \(address2array)")
      print("lok2 write_byteArray vor: \(teensy.write_byteArray)")
      print("lok2 write_byteArray vor lok2adresse: \(teensy.write_byteArray[8])  \(teensy.write_byteArray[9])  \(teensy.write_byteArray[10])  \(teensy.write_byteArray[11])")
      
      for i in 0...3
      {
         teensy.write_byteArray[8 + i] = addressarray[2][i]
      }
      
      //      print("lok1 write_byteArray nach: \(teensy.write_byteArray[8])  \(teensy.write_byteArray[9])  \(teensy.write_byteArray[10])  \(teensy.write_byteArray[11])")
      print("lok2 write_byteArray nach: \(teensy.write_byteArray)")
      print("lok2 write_byteArray nach lok2adresse: \(teensy.write_byteArray[8])  \(teensy.write_byteArray[9])  \(teensy.write_byteArray[10])  \(teensy.write_byteArray[11])")

      //      teensy.write_byteArray[9] = UInt8((sender.indexOfSelectedItem))
      //      teensy.write_byteArray[10] = UInt8((sender.indexOfSelectedItem))
      //      teensy.write_byteArray[11] = UInt8((sender.indexOfSelectedItem))
      
      //      teensy.write_byteArray[16] = 0 // Richtung
      //      teensy.write_byteArray[17] = 0 // speed
      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         print("Robot report_Address2 senderfolg: \(senderfolg)")
      }
   } 
   
   // alle Adressen senden
   @IBAction func loadAdresse(_ sender: NSButton)
   {
      addressarray[0][0] = UInt8(a0.indexOfSelectedItem)
      addressarray[0][1] = UInt8(a1.indexOfSelectedItem)
      addressarray[0][2] = UInt8(a2.indexOfSelectedItem)
      addressarray[0][3] = UInt8(a3.indexOfSelectedItem)

      addressarray[1][0] = UInt8(b0.indexOfSelectedItem)
      addressarray[1][1] = UInt8(b1.indexOfSelectedItem)
      addressarray[1][2] = UInt8(b2.indexOfSelectedItem)
      addressarray[1][3] = UInt8(b3.indexOfSelectedItem)

   
      addressarray[2][0] = UInt8(c0.indexOfSelectedItem)
      addressarray[2][1] = UInt8(c1.indexOfSelectedItem)
      addressarray[2][2] = UInt8(c2.indexOfSelectedItem)
      addressarray[2][3] = UInt8(c3.indexOfSelectedItem)

      for lok in 0...2
      {
         teensy.write_byteArray[0] = addresscodearray[lok]
         
         for i in 0...3
         {
            teensy.write_byteArray[8 + i] = addressarray[lok][i]
         }
         if (usbstatus > 0)
         {
            let senderfolg = teensy.send_USB()
            print("Robot loadAdresse lok: \(lok)  senderfolg: \(senderfolg)")
         }

      }
     
      
   }
    // MARK:Slider 1
   @IBAction override func report_Slider1(_ sender: NSSlider)
   {
      teensy.write_byteArray[0] = LOK_1 // Code
      lok0array[12] = LOK_1_SPEED
 //     let name = UserDefaults.standard.string(forKey: "name")
 //     let robot1_offset = UserDefaults.standard.integer(forKey: "robot1offset")
      
   //   print(name)

 //    print("report_Slider1 float: \(sender.floatValue) min: \(sender.minValue) ")
      /*
       let pos = sender.floatValue
       Pot1_Feld_raw.integerValue = Int(pos)
       let intpos = UInt16(pos * FAKTOR1)
       //     let Istring = formatter.string(from: NSNumber(value: intpos))
       */
      /*
      let inv = Pot1_Inverse_Check.state.rawValue
      var pos:Float = 0
      if (inv == 0)
      {
         pos = sender.floatValue 
      }
      else
      {
         pos = Float(sender.maxValue) - sender.floatValue + Float(sender.minValue)
      }
      */
      let pos = sender.floatValue
      let intpos = UInt8(pos  * LOK_FAKTOR1)
      print("report_Slider1 pos: \(pos) intpos: \(intpos) ") 
      Pot1_Feld.integerValue  = Int(intpos)
      var speed:UInt8 =  intpos
      if speed > 0
      {
         speed += 1 // speed 1 ist Richtungsumschaltung
      }
      spee1darray[1] = speed
      lok1array[6] = speed
      print("spee1darray: \(spee1darray)")
      print("lok1array: \(lok1array)")

      teensy.write_byteArray[17] = UInt8(speed) // speed
      
      Pot1_Feld.integerValue = Int(pos)
      
      print("usbstatus: \(usbstatus)")
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         print("Robot report_Slider1 senderfolg: \(senderfolg)")
      }

      

    }
   
   // MARK:Slider 2
   @IBAction override func report_Slider2(_ sender: NSSlider)
   {
      UserDefaults.standard.set("Ruedi Heimlicher", forKey: "name")
      
      teensy.write_byteArray[0] = SET_2 // Code 
      print("Robot report_Slider2 IntVal: \(sender.intValue)")
      let inv = Pot2_Inverse_Check.state.rawValue
      var pos:Float = 0
      if (inv == 0)
      {
         pos = sender.floatValue
         /*
         Pot2_Stepper_L.integerValue  = Int(sender.minValue) // Stepper min setzen
         Pot2_Stepper_L_Feld.integerValue = Int(sender.minValue)
         Pot2_Stepper_H.integerValue  = Int(sender.maxValue) // Stepper max setzen
         Pot2_Stepper_H_Feld.integerValue = Int(sender.maxValue)
         */
      }
      else
      {
         pos = Float(sender.maxValue) - sender.floatValue + Float(sender.minValue)
         Pot2_Stepper_L.integerValue  = Int(sender.maxValue) // Stepper min setzen
         Pot2_Stepper_L_Feld.integerValue = Int(sender.maxValue)
         Pot2_Stepper_H.integerValue  = Int(sender.minValue) // Stepper max setzen
         Pot2_Stepper_H_Feld.integerValue = Int(sender.minValue)
         
         
      }
      let intpos = UInt16(pos * LOK_FAKTOR2)
      
      
      Pot2_Feld_raw.integerValue  = Int(pos)
      Pot2_Feld.integerValue  = Int(intpos)
      
 //     setAchse2(pos: pos * LOK_FAKTOR2)
      
   }
   
     
   
   
   @IBAction override func report_Slider3(_ sender: NSSlider)
   {
      teensy.write_byteArray[0] = SET_3 // Code 
      print("Robot report_Slider3 IntVal: \(sender.intValue)")
      
      let pos = sender.floatValue
      
      let intpos = UInt16(pos * FAKTOR3)
      let Ustring = formatter.string(from: NSNumber(value: intpos))
      
      //print("report_Slider3 pos: \(pos) intpos: \(intpos)  Ustring: \(Ustring ?? "0")")
      // Pot0_Feld.stringValue  = Ustring!
      Pot3_Feld.integerValue  = Int(intpos)
      Pot3_Stepper_L.integerValue  = Int(sender.minValue) // Stepper min setzen
      Pot3_Stepper_L_Feld.integerValue = Int(sender.minValue)
      Pot3_Stepper_H.integerValue  = Int(sender.maxValue) // Stepper max setzen
      Pot3_Stepper_H_Feld.integerValue = Int(sender.maxValue)
      
      teensy.write_byteArray[ACHSE3_BYTE_H] = UInt8((intpos & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE3_BYTE_L] = UInt8((intpos & 0x00FF) & 0xFF) // lb
      
      if (globalusbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         print("report_Slider3 senderfolg: \(senderfolg)")
      }
   }
   
   
   
   @IBAction  func report_Drehknopf_Stepper_L(_ sender: NSStepper) // untere Grenze
   {
      print("report_Drehknopf_Stepper_L IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
      Drehknopf_Stepper_L_Feld.integerValue = intpos
      
      DrehknopfFeld.minwinkel = CGFloat(sender.doubleValue)
      print("report_Drehknopf_Stepper_L DrehknopfFeld.minwinkel: \(DrehknopfFeld.minwinkel)")
      DrehknopfFeld.bogen.removeAllPoints()
      DrehknopfFeld.bogen.appendArc(withCenter:  DrehknopfFeld.mittelpunkt, radius: DrehknopfFeld.knopfrect.size.height/2-2, startAngle: DrehknopfFeld.minwinkel + 90, endAngle: DrehknopfFeld.maxwinkel + 90)
      
      //   abdeckpfad.fill()
      
      DrehknopfFeld.needsDisplay = true
      
   }
   
   
   
   @IBAction  func report_Drehknopf_Stepper_H(_ sender: NSStepper) // untere Grenze
   {
      print("report_Drehknopf_Stepper_H IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
      Drehknopf_Stepper_H_Feld.integerValue = intpos
      
      DrehknopfFeld.maxwinkel = CGFloat(sender.doubleValue)
      print("report_Drehknopf_Stepper_H DrehknopfFeld.minwinkel: \(DrehknopfFeld.minwinkel)")
      DrehknopfFeld.bogen.removeAllPoints()
      DrehknopfFeld.bogen.appendArc(withCenter:  DrehknopfFeld.mittelpunkt, radius: DrehknopfFeld.knopfrect.size.height/2-2, startAngle: DrehknopfFeld.minwinkel + 90, endAngle: DrehknopfFeld.maxwinkel + 90)
      
      DrehknopfFeld.needsDisplay = true
      
   }
   
    @objc override func beendenAktion(_ notification:Notification) 
    {
      let local:UInt8 = (1<<LOCAL)
      teensy.write_byteArray[21] = local
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         print("Robot beendenAktion senderfolg: \(senderfolg)")
      }

      UserDefaults.standard.set(a0.indexOfSelectedItem, forKey: "a0index")
      UserDefaults.standard.set(a1.indexOfSelectedItem, forKey: "a1index")
      UserDefaults.standard.set(a2.indexOfSelectedItem, forKey: "a2index")
      UserDefaults.standard.set(a3.indexOfSelectedItem, forKey: "a3index")
      
      print("*** Robot UserDefaults b: \(b0.indexOfSelectedItem) \(b1.indexOfSelectedItem) \(b2.indexOfSelectedItem) \(b3.indexOfSelectedItem)")
      
      
      UserDefaults.standard.set(b0.indexOfSelectedItem, forKey: "b0index")
      UserDefaults.standard.set(b1.indexOfSelectedItem, forKey: "b1index")
      UserDefaults.standard.set(b2.indexOfSelectedItem, forKey: "b2index")
      UserDefaults.standard.set(b3.indexOfSelectedItem, forKey: "b3index")
      

      UserDefaults.standard.set(c0.indexOfSelectedItem, forKey: "c0index")
      UserDefaults.standard.set(c1.indexOfSelectedItem, forKey: "c1index")
      UserDefaults.standard.set(c2.indexOfSelectedItem, forKey: "c2index")
      UserDefaults.standard.set(c3.indexOfSelectedItem, forKey: "c3index")
      
      print("*** UserDefaults c: \(c0.indexOfSelectedItem) \(c1.indexOfSelectedItem) \(c2.indexOfSelectedItem) \(c3.indexOfSelectedItem)")
      
      
      
      
      UserDefaults.standard.set(pause, forKey: "pause")
      
      UserDefaults.standard.set(timerintervall, forKey: "timerintervall")
      
           /*
      UserDefaults.standard.set(Pot1_Stepper_L.integerValue, forKey: "robot1min")
      UserDefaults.standard.set(Pot2_Stepper_L.integerValue, forKey: "robot2min")
      
      UserDefaults.standard.set(rotoffsetstepper.integerValue, forKey: "rotoffset")
      UserDefaults.standard.set(pot1offsetstepper.integerValue, forKey: "robot1offset")
      UserDefaults.standard.set(pot2offsetstepper.integerValue, forKey: "robot2offset")
   
      UserDefaults.standard.set(winkelfaktor1stepper.floatValue,forKey: "winkelfaktor1")
      UserDefaults.standard.set(winkelfaktor2stepper.floatValue,forKey: "winkelfaktor2")
      
      */
      print("Robot beendenAktion")
      
      NSApplication.shared.terminate(self)
      
   }

    
}
