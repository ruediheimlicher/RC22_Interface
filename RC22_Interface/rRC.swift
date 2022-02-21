//
//  rRC.swift
//  RC22_Interface
//
//  Created by Ruedi Heimlicher on 20.02.2022.
//  Copyright © 2022 Ruedi Heimlicher. All rights reserved.
//
import Cocoa
import Darwin

let SET_RC:UInt8 = 0xA2


class rRC: rViewController, NSTabViewDelegate, NSTableViewDataSource,NSTableViewDelegate,NSComboBoxDataSource,NSComboBoxDelegate
{

   
   
   var hintergrundfarbe = NSColor()
 
   override func viewDidAppear() 
   {
      print ("RC viewDidAppear selectedDevice: \(selectedDevice)")
      KanalTable.dataSource = self
      KanalTable.delegate = self
      FunktionTable.dataSource = self
      FunktionTable.delegate = self
      MixingTable.dataSource = self
      MixingTable.delegate = self
      
      
       
      var    FunktionSettingArray = [[String:UInt8]]()
      for funktionindex:UInt8 in 0..<8
      {
         
         var devicenummer:UInt8 = funktionindex
         var funktionnummer:UInt8 = 7 - funktionindex
        
         var funktiondic = [String:UInt8]()
         funktiondic["nummer"] = funktionindex
         funktiondic["devicenummer"] = devicenummer
         funktiondic["device"] = funktionindex // default_DeviceArray  objectAtIndex:deviceindex
         funktiondic["funktion"] = funktionnummer         // default_FunktionArray objectAtIndex:funktionindex
         funktiondic["device_funktion"] = ((funktionnummer & 0xFF) | ((devicenummer & 0xFF)<<4))
         FunktionSettingArray.append(funktiondic)
      }
      FunktionArray.append(FunktionSettingArray)
      FunktionTable.reloadData()
         
      var   SettingArray = [[String:UInt8]]()
      for model:UInt8 in 0..<3
      {
         for kanal:UInt8 in 0..<8
         {
            var kanaldic = [String:UInt8]()
            kanaldic["nummer"] = kanal
            kanaldic["art"] = 0
            kanaldic["richtung"] = 0
            kanaldic["levela"]  = 0
            kanaldic["levelb"]  = 0
            kanaldic["expoa"]  = 0
            kanaldic["expob"]  = 0
            kanaldic["mix"]  = 0
            kanaldic["mixkanal"]  = kanal
            kanaldic["go"]  = 0
            kanaldic["state"]  = 0
            kanaldic["modelnummer"]  = model
            kanaldic["model"]  = model
            SettingArray.append(kanaldic)
         }// for kanal
      }// for model
      ModelArray.append(SettingArray)   // Daten aller Modelle
      KanalTable.reloadData()
      
      var   MixingSettingArray = [[String:UInt8]]()
      for mixingindex:UInt8 in 0..<4
      {
         var mixingdic = [String:UInt8]()
         mixingdic["mixnummer"] = mixingindex
         mixingdic["mixart"] = 0
         mixingdic["canala"] = 0x08
         mixingdic["canalb"] = 0x08
         mixingdic["mixing"] = 0 // verwendet als Mix xy
         MixingSettingArray.append(mixingdic)
      }
      MixingSettingArray[0]["mixart"] = 0x01
      MixingSettingArray[1]["mixart"] = 0x02
      MixingArray.append(MixingSettingArray)
      MixingTable.reloadData()
      
      //Device
      var     default_DeviceArray:[String] = ["L_H","L_V","R_H","R_V","S_L","S_R","Sch","-"]
      // Funktion
      var     default_FunktionArray:[String] = ["Seite","Hoehe","Quer","Motor","Quer L","Quer R","Lande","Aux"]

      var            FunktionArray = [UInt8]()
      
      (SettingTab.selectedTabViewItem?.view?.viewWithTag(100) as! NSTextField).stringValue =  "M 0"

      eepromwritestatus = 0
      Halt_Taste.toolTip = "HALT vor Aenderungen im EEPROM"
      
      var    container:NSTextContainer = EE_dataview.textContainer ?? NSTextContainer()
        
   } // end viewDidAppear

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
      NotificationCenter.default.addObserver(self, selector:#selector(usbstatusAktion(_:)),name:NSNotification.Name(rawValue: "usb_status"),object:nil)
//      NotificationCenter.default.addObserver(self, selector:#selector(drehknopfAktion(_:)),name:NSNotification.Name(rawValue: "drehknopf"),object:nil)
   
      teensy.write_byteArray[0] = SET_RC // Code
   
      SettingTab.selectTabViewItem(at: 0)
      
      var views:[NSView] = SettingTab.selectedTabViewItem?.view?.subviews ?? [NSView]()
      var index:Int = 0
      for element in views
      {
         let t = element.tag
         print("index: \(index) tag: \(t)")
         index += 1
      }
   
   
   
   } // end viewDidLoad

   @objc func usbstatusAktion(_ notification:Notification) 
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
   
   
   
   // MARK: TableView
   // http://stackoverflow.com/questions/36365242/cocoa-nspopupbuttoncell-not-displaying-selected-value

   func numberOfRowsInTableView(tableView: NSTableView) -> Int
   {
      
      //int tabindex = [aTableView tag]%100;
      int tabindex = [SettingTab indexOfTabViewItem:[SettingTab selectedTabViewItem]];

   }// numberOfRowsInTableView

   // MARK: Variablen
   var                     dumpCounter:Int = 0
   
   var                        lastValueRead: NSData = NSData() /*" The last value read"*/
   var                        lastDataRead: NSData = NSData()/*" The last value read"*/
   var                        EE_WriteTimer:Timer = Timer()
   
   var               schliessencounter:Int = 0
   var               haltFlag:Int = 0
   var               mausistdown:Int = 0
   var               anzrepeat:Int = 0
   var               pfeilaktion:Int = 0
   var               HALTStatus:Int = 0
   var              USBStatus:Int = 0
   var               pwm:Int = 0
   var               halt:Int = 0

  // var           newsendbuffer:char = ""
   
   var           eepromwritestatus:Int = 0// was tun
  
  // var               usbstatus:Int = 0// was tun
   var               usbtask:Int = 0 // welche Task ist aktuell

   
   
   var            ExpoDatenArray = [UInt8]()
   var            DiagrammExpoDatenArray = [UInt8]()
   var            USB_EEPROMArray = [UInt8]()
   var            ChecksummenArray = [UInt8]()
   var            ModelArray = [[[String:UInt8]]]()
   var            FunktionArray = [[[String:UInt8]]]()
   var            MixingArray = [[[String:UInt8]]]()
   
   
   var            Math = rMath()
   var            checksumme:Int = 0
   
   
    
// MARK: outlets
   // @IBOutlet weak var Pot1_Feld_raw: NSTextField!
   @IBOutlet  weak var     dumpTable: NSTableView!
  
   @IBOutlet   weak var          logTable:NSTableView!
   @IBOutlet   weak var          window:NSWindow!
   @IBOutlet   weak var          macroPopup:NSPopUpButton!
   @IBOutlet   weak var          readButton:NSButton!

  
  
   
   @IBOutlet     weak var      AdressPop:NSPopUpButton!
  
  @IBOutlet        weak var          readUSB:NSButton!
  @IBOutlet       weak var        USB_DataFeld:NSTextField!
  @IBOutlet       weak var        rundeFeld:NSTextField!
  
  @IBOutlet       weak var        ADC_DataFeld:NSTextField!
  
  @IBOutlet       weak var     ADC_Level:NSLevelIndicator!
  
  @IBOutlet       weak var     Pot0_Level:NSLevelIndicator!
  //@IBOutlet       weak var           Pot0_Slider: NSSlider!
  @IBOutlet      weak var         Pot0_DataFeld:NSTextField!
  
  @IBOutlet        weak var    Pot1_Level:NSLevelIndicator!
  //@IBOutlet        weak var          Pot1_Slider:NSSlider!
  @IBOutlet        weak var       Pot1_DataFeld:NSTextField!

  @IBOutlet        weak var          Pot0_SliderInt:NSSlider!
  @IBOutlet        weak var          Pot1_SliderInt:NSSlider!

  @IBOutlet         weak var         Pot2_SliderInt:NSSlider!
  @IBOutlet         weak var         Pot3_SliderInt:NSSlider!
   
  
  @IBOutlet         weak var         Pot4_SliderInt:NSSlider!
  @IBOutlet         weak var         Pot5_SliderInt:NSSlider!

   @IBOutlet   weak var     Halt_Taste:NSButton!

   @IBOutlet  weak var      Write_1_Byte_Taste:NSButton!
   @IBOutlet weak var        Read_1_Byte_Taste:NSButton!
   @IBOutlet weak var        Write_Part_Taste:NSButton!
   @IBOutlet weak var        Read_Part_Taste:NSButton!
   
   @IBOutlet weak var       Write_Stufe_Taste:NSButton!
   @IBOutlet weak var        StufeFeld:NSTextField!
   @IBOutlet weak var        PartnummerFeld:NSTextField!
   
   @IBOutlet weak var        PPMFeldA:NSTextField!
   @IBOutlet weak var        PPMFeldB:NSTextField!
   
  // @IBOutlet weak var   USB_OK_Feld:NSImageView!
   
   @IBOutlet      weak var     Taskwahl:NSTextField!
   @IBOutlet      weak var     EE_StartadresseFeld:NSTextField!
   @IBOutlet      weak var     EE_StartadresseFeldHexLO:NSTextField!
   @IBOutlet      weak var     EE_StartadresseFeldHexHI:NSTextField!
   @IBOutlet      weak var     EE_startadresselo:NSTextField!
   @IBOutlet      weak var     EE_startadressehi:NSTextField!
   @IBOutlet      weak var     EE_DataFeld:NSTextField!
   @IBOutlet      weak var     EE_datalo:NSTextField!
   @IBOutlet      weak var     EE_datahi:NSTextField!
   @IBOutlet      weak var     EE_datalohex:NSTextField!
   @IBOutlet      weak var     EE_datahihex:NSTextField!
   @IBOutlet      weak var     EE_databin:NSTextField!
   @IBOutlet    weak var      EE_dataview:NSTextView!
   @IBOutlet    weak var     PPM_testdatafeld:NSTextField!
    
   @IBOutlet    weak var     readsetting_mark:NSTextField!
   @IBOutlet    weak var     readsender_mark:NSTextField!
   @IBOutlet    weak var     readfunktion_mark:NSTextField!
   @IBOutlet    weak var     refreshmaster_mark:NSTextField!

   @IBOutlet   weak var      SettingTab:NSTabView!
   
   @IBOutlet   weak var      KanalTable:NSTableView!
  @IBOutlet      weak var   ExpoTabel:NSTableView!

   @IBOutlet      weak var   FunktionTable:NSTableView!
   @IBOutlet      weak var   MixingTable:NSTableView!

   
   @IBOutlet      weak var  FixSettingTaste:NSButton!
   @IBOutlet      weak var  FixMixingTaste:NSButton!
   @IBOutlet      weak var  FixFunktionTaste:NSButton!
   @IBOutlet      weak var  FixAusagangTaste:NSButton!
   @IBOutlet      weak var  MasterRefreshTaste:NSButton!
   @IBOutlet      weak var  AdresseIncrement:NSButton!
   @IBOutlet      weak var      ReadSettingTaste:NSButton!
   @IBOutlet      weak var      ReadSenderTaste:NSButton!
   @IBOutlet      weak var       ReadFunktionTaste:NSButton!
}// end class rRC

