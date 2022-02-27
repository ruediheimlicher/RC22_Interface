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
      
      dispatchkanalpop.removeAllItems()
      dispatchdevicepop.removeAllItems()

      default_ONArray = [okimage, notokimage]
      
      for model:UInt8 in 0..<3
      { 
         var    FunktionSettingArray = [[String:UInt8]]()
         for funktionindex:UInt8 in 0..<8
         {
            
            var devicenummer:UInt8 = funktionindex
            var funktionnummer:UInt8 = 7 - funktionindex
            
            var funktiondic = [String:UInt8]()
            funktiondic["funktionnummer"] = funktionindex
            funktiondic["funktiondevice"] = funktionindex // default_DeviceArray  objectAtIndex:deviceindex
            funktiondic["funktion"] = funktionnummer         // default_FunktionArray objectAtIndex:funktionindex
            funktiondic["device_funktion"] = ((funktionnummer & 0xFF) | ((devicenummer & 0xFF)<<4))
            FunktionSettingArray.append(funktiondic)
         }
         FunktionArray.append(FunktionSettingArray)
         FunktionTable.reloadData()
         
         var   KanalSettingArray = [[String:UInt8]]()
         
         for kanal:UInt8 in 0..<8
         {
            var kanaldic = [String:UInt8]()
            kanaldic["nummer"] = kanal
            kanaldic["art"] = 0
            kanaldic["richtung"] = 1
            kanaldic["levela"]  = 2
            kanaldic["levelb"]  = 3
            kanaldic["expoa"]  = 4
            kanaldic["expob"]  = 2
            kanaldic["mix"]  = 1
            kanaldic["mixkanal"]  = kanal
            kanaldic["go"]  = 0
            kanaldic["state"]  = 0
            kanaldic["modelnummer"]  = model
            kanaldic["model"]  = model
            KanalSettingArray.append(kanaldic)
         }// for kanal
         
         KanalArray.append(KanalSettingArray)   // Daten aller Modelle
         
         
         var   MixingSettingArray = [[String:UInt8]]()
         for mixingindex:UInt8 in 0..<4
         {
            var mixingdic = [String:UInt8]()
            mixingdic["mixnummer"] = mixingindex
            mixingdic["mixart"] = 2
            mixingdic["canala"] = 0x08
            mixingdic["canalb"] = 0x08
            mixingdic["mixing"] = 0 // verwendet als Mix xy
            MixingSettingArray.append(mixingdic)
         }
         MixingSettingArray[0]["mixart"] = 0x01
         MixingSettingArray[1]["mixart"] = 0x02
         MixingSettingArray[2]["mixart"] = 0x00
         MixingSettingArray[3]["mixart"] = 0x00
         MixingArray.append(MixingSettingArray)
      
         
         
         var   DispatchSettingArray = [[String:UInt8]]()
         for dispatchindex:UInt8 in 0..<4
         {
            var dispatchdic = [String:UInt8]()
            dispatchdic["dispatchnummer"] = 7-dispatchindex
            dispatchdic["dispatchfunktion"] = 2
            let deveicedefault = Int(dispatchindex)
            let devicestring = default_DeviceArray[deveicedefault]
            dispatchdic["dispatchkanal"] = dispatchindex + 2
            dispatchdevicepop.addItem(withTitle: devicestring)
            dispatchdic["dispatchdevice"] = dispatchindex + 5
            dispatchdic["dispatchgo"] = 1 // verwendet 
            dispatchdic["dispatchonimage"] = 1 // verwendet
            
            DispatchSettingArray.append(dispatchdic)
         }
         DispatchArray.append(DispatchSettingArray)

       }// for model
      
      
      DispatchTable.target = self      
      DispatchTable.dataSource = self
      DispatchTable.delegate = self
      
      
      KanalTable.dataSource = self
      KanalTable.delegate = self
      FunktionTable.reloadData()
      KanalTable.reloadData()
      MixingTable.reloadData()
      DispatchTable.reloadData()
      

      
      
   
      //var            FunktionArray = [UInt8]()
      
      (SettingTab.selectedTabViewItem?.view?.viewWithTag(100) as! NSTextField).stringValue =  "M 0"

      eepromwritestatus = 0
      Halt_Taste.toolTip = "HALT vor Aenderungen im EEPROM"
      
      var    container:NSTextContainer = EE_dataview.textContainer ?? NSTextContainer()
      /*
      var z:Int = 0
      print("KanalArray count: \(KanalArray.count)")
      print("KanalArray0  count: \(KanalArray[0].count)")
      for zeile in KanalArray
      {
         print("zeile: \(z)")
         var k:Int = 0
         for element in zeile
         {
            print("element \(k) \(element)")
            k += 1
         }
         z += 1
      }
       */
      print("end viewDidAppear")  
   } // end viewDidAppear

   override func viewDidLoad() 
   {
      print("viewDidLoad")
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
      
      //var views:[NSView] = SettingTab.selectedTabViewItem?.view?.subviews ?? [NSView]()
      /*
      var index:Int = 0
      for element in views
      {
         let t = element.tag
         print("index: \(index) tag: \(t)")
         index += 1
      }
   */
      print("end viewDidLoad")
   
   } // end viewDidLoad
   
   
   
   @IBAction func report_dispatchkanalpop(_ sender: NSPopUpButton) 
   {
      print("report_dispatchkanalpop item: \(sender.indexOfSelectedItem)")
   }
   
   @IBAction func report_dispatchdevicepop(_ sender: NSPopUpButton) 
   {
      print("report_dispatchdevicepop item: \(sender.indexOfSelectedItem)")
      if (clickeddispacharrayrow >= 0)
      {
      let itemstring = sender.titleOfSelectedItem
      DispatchArray[0][clickeddispacharrayrow]["dispatchdevice"] = UInt8(sender.indexOfSelectedItem) 
      DispatchTable.reloadData()
      }
   }
   
   @IBAction func report_dispatchPop(_ sender: NSPopUpButton) 
   {
      print("report_dispatchdevicepop item: \(sender.indexOfSelectedItem)")
   }


 
   var     default_DeviceArray:[String] = ["L_H","L_V","R_H","R_V","S_L","Schieber_R","Schalter","-"]
   var     default_FunktionArray:[String] = ["Seite","Hoehe","Quer","Motor","Quer L","Quer R","Lande","Aux"]

   var default_ONArray:[NSImage] = [NSImage]()//[okimage, notokimage]
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
   
   
   
   // MARK: Actions
   @IBAction func report_TableView(_ sender: NSPopUpButtonCell)
   {
      print("reportTableView clicked: \(KanalTable.clickedRow) \(KanalTable.clickedColumn)")
      let ident = sender.identifier
   print("sender ident \( ident)")
   }
   
   @IBAction private func report_tableRowWasClicked(_ tableView: NSTableView)
   {
      // https://stackoverflow.com/questions/18560509/nstableview-detecting-a-mouse-click-together-with-the-row-and-column
      let identstring = tableView.identifier?.rawValue ?? "x"
      let ident = NSUserInterfaceItemIdentifier(tableView.identifier?.rawValue ?? "x")
      let zeile = (tableView.clickedRow)
      let kolonne = tableView.clickedColumn
      
      print("row \(zeile), col \(kolonne) ident: \(ident)")
      switch identstring
      {
      case "dispatch":
         print("table dispatch")
         clickeddispacharrayrow = Int(zeile)
         if (kolonne == 4) // ON
         {
            let wert = UInt8(DispatchArray[0][zeile]["dispatchonimage"] ?? 0 )
            DispatchArray[0][zeile]["dispatchonimage"]  = 1 - wert
            DispatchTable.reloadData()
         }
      default:
         break
      }
   }

   
   // MARK: TableView
   // http://stackoverflow.com/questions/36365242/cocoa-nspopupbuttoncell-not-displaying-selected-value
   
  /* 
   func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? 
   {
      
       return SubView(text: items[row])
   }
*/
   //func numberOfRowsInTableView(tableView: NSTableView) -> Int
   func numberOfRows(in tableView: NSTableView) -> Int
   {
      
      var tagindex:Int = (tableView.tag);
      tagindex /= 100
      //var tabindex:Int = SettingTab.indexOfTabViewItem(SettingTab.selectedTabViewItem ?? NSTabViewItem())
      var ident = tableView.identifier
      switch tagindex
      {
      case 4: // Kanal
         //print("numberOfRowsInTableView: kanal \(KanalArray.count)")
         if (KanalArray.count > 0)
         {
            return KanalArray[0].count
         }
         else
         {
            return 4
         }
      case 5: // Mixing   
         //print("numberOfRowsInTableView: mixing")
         if (MixingArray.count > 0)
         {
            //print("numberOfRowsInTableView: mixing count \(MixingArray[0].count)")
            return MixingArray[0].count
         }
         else
         {
            //print("numberOfRowsInTableView: mixing anz 0")
            return 1
         }

         //return MixingArray.count
      case 6:// Dispatch
         //print("numberOfRowsInTableView: dispatch count: \(DispatchArray.count)")
         
         return DispatchArray.count
         
      case 7:// Funktion
         //print("numberOfRowsInTableView: funktion")
         if (FunktionArray.count > 0)
         {
            return FunktionArray[0].count
         }
         else
         {
            return 4
         }
         //return FunktionArray.count
    default:
         break
      }
      

     return 0 
   }// numberOfRowsInTableView

   
   func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
   {
      
      //let ident = convertFromNSUserInterfaceItemIdentifier(tableColumn?.identifier)
      let ident = tableColumn?.identifier.rawValue
      //print ("viewFor row: \(row) ident: \(ident)")
      //if ident == "dispatchdevice"
      let defaultwert = NSUserInterfaceItemIdentifier(rawValue:"dispatchdevice")
      
      if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"dispatchdevice") )
      {
         //let result = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "dispatchdevice") , owner: self) as! NSTableCellView 
         guard let result = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else 
         {
            print("dispatchdevice ist nil")
            return nil 
            
         }
         let nummer = Int(DispatchArray[0][row]["dispatchdevice"] ?? 0)
         let wert:Int = nummer
         print("dispatchdevice device: \(nummer)")
         //result.textField?.intValue = Int32(nummer) 
         result.textField?.stringValue = default_DeviceArray[wert]
         return result
      }
      else  if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"dispatchkanal") )
      {
         //let result = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "dispatchkanal") , owner: self) as! NSTableCellView
         guard let result = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else 
         {
            print("dispatchkanal ist nil")
            return nil 
            
         }
         let nummer = Int(DispatchArray[0][row]["dispatchkanal"] ?? 0)
         let wert:Int = nummer
         print("dispatchkanal kanal: \(nummer)")
         
         result.textField?.intValue = Int32(nummer) 
 
         
         return result
      }
      else  if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"dispatchnummer") )
      {
         guard let result = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else 
         {
            print("dispatchnummer ist nil")
            return nil 
            
         }

         //let result = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "dispatchnummer") , owner: self) as? NSTableCellView
         let nummer = Int(DispatchArray[0][row]["dispatchnummer"] ?? 0)
         let wert:Int = nummer
         print("dispatchnummer nummer: \(nummer)")
         result.textField?.intValue = Int32(nummer) 
         
         return result
      }
   
      else  if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"dispatchonimage") )
      {
         guard let result = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else 
         {
            print("dispatchonimage ist nil")
            return nil 
            
         }
         let nummer = Int(DispatchArray[0][row]["dispatchonimage"] ?? 0)
         let wert:Int = nummer
         print("dispatchnummer onimage: \(wert)")
         //https://stackoverflow.com/questions/37100846/osx-swift-add-image-into-nstableview
         result.imageView?.image = default_ONArray[wert]
         return result

      } // onimage
      return nil
   }
   
func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any?

   {
      
      //let ident = convertFromNSUserInterfaceItemIdentifier(tableColumn?.identifier)
      let ident = tableColumn?.identifier.rawValue
      //print ("viewFor row: \(row) ident: \(ident)")
      //if ident == "dispatchdevice"
      let defaultwert = NSUserInterfaceItemIdentifier(rawValue:"dispatchdevice")
      
      if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"dispatchdevice") )
      {
         //let result = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "dispatchdevice") , owner: self) as! NSTableCellView 
         guard let result = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else 
         {
            print("dispatchdevice ist nil")
            return nil 
            
         }
         let nummer = Int(DispatchArray[0][row]["dispatchdevice"] ?? 0)
         let wert:Int = nummer
         print("dispatchdevice device: \(nummer)")
         //result.textField?.intValue = Int32(nummer) 
         result.textField?.stringValue = default_DeviceArray[wert]
         return result
      }
      else  if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"dispatchkanal") )
      {
         //let result = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "dispatchkanal") , owner: self) as! NSTableCellView
         guard let result = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else 
         {
            print("dispatchkanal ist nil")
            return nil 
            
         }
         let nummer = Int(DispatchArray[0][row]["dispatchkanal"] ?? 0)
         let wert:Int = nummer
         print("dispatchkanal kanal: \(nummer)")
         
         result.textField?.intValue = Int32(nummer) 
 
         
         return result
      }
      else  if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"dispatchnummer") )
      {
         guard let result = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else 
         {
            print("dispatchnummer ist nil")
            return nil 
            
         }

         //let result = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "dispatchnummer") , owner: self) as? NSTableCellView
         let nummer = Int(DispatchArray[0][row]["dispatchnummer"] ?? 0)
         let wert:Int = nummer
         print("dispatchnummer nummer: \(nummer)")
         result.textField?.intValue = Int32(nummer) 
         
         return result
      }
     
      
      return nil
   } //objectValueFor
   
   
   /*
    
    - (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
    {
      [[self.data objectAtIndex:row] setValue:object forKey:tableColumn.identifier];
    }

    */
   /*
   func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
     //let person = people[row]
      let tagindex:Int = tableView.tag/100;
      let colident = tableColumn?.identifier.rawValue

   //  print("tableView viewFor ident: \(colident) tag: \(tagindex)")
     guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else { return nil }
     if (tagindex == 4)
      {
     if (tableColumn?.identifier)!.rawValue == "nummer" 
      {
        print("tableView viewFor nummer da")
        
     //    cell.textField?.stringValue = person.firstName
     }
     }
      /*
      else if (tableColumn?.identifier)!.rawValue == "lastName" {
         cell.textField?.stringValue = person.lastName
     } else {
         cell.textField?.stringValue = person.mobileNumber
     }
     */
     return nil
   }
   */
   private func tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int) 
   {
      let tagindex:Int = (tableView.tag/100);
      let colident = tableColumn?.identifier.rawValue
      print("setObjectValue colident: \(colident) object: \(object)")
      switch tagindex
      {
      case 4: // Kanal
         KanalArray[0][row][colident! ] = UInt8(object as! Int)
         print("setObjectValueFor: kanal colident: \(colident) object: \(object)")
         
      case 500: // Mixing   
         print("objectValueFor: mixing")
         //return MixingArray[row]
      case 600:// Device
         print("objectValueFor: device")
         //return DeviceArray[tagindex]
      case 700:// Funktion
         print("objectValueFor: funktion")
         //return FunktionArray[row]
      default:
         break
      }
    
     
      KanalTable.reloadData()  
   }//setObjectValue
   
  func tableViewSelectionDidChange(_ notification: Notification)
   {
      print("tableViewSelectionDidChange")
   }
   
   
   
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
   var            KanalArray = [[[String:UInt8]]]()
   var            FunktionArray = [[[String:UInt8]]]()
   var            clickedfunktionarrayrow:Int = -1
   var            MixingArray = [[[String:UInt8]]]()
   var            DispatchArray = [[[String:UInt8]]]()
   var            DeviceArray = [[[String:UInt8]]]()
   var            ONImageArray = [[[String:UInt8]]]()
   var            Math = rMath()
   var            checksumme:Int = 0
   var            clickeddispacharrayrow:Int = -1 // angeklickte Zeile

   
   var data: [[String: String]] = [[:]]
   
   
    
// MARK: outlets
   // @IBOutlet weak var Pot1_Feld_raw: NSTextField!
   @IBOutlet  weak var     dumpTable: NSTableView!
  
   @IBOutlet   weak var          logTable:NSTableView!
   @IBOutlet   weak var          window:NSWindow!
   @IBOutlet   weak var          macroPopup:NSPopUpButton!
   @IBOutlet   weak var          readButton:NSButton!

   @IBOutlet    var     dispatchkanalpop:NSPopUpButton!
   @IBOutlet    var     dispatchdevicepop:NSPopUpButton!
   @IBOutlet    var     dispatchpop:NSPopUpButton!
   
  
   
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
   @IBOutlet      weak var   DispatchTable:NSTableView!

   
   @IBOutlet      weak var  FixSettingTaste:NSButton!
   @IBOutlet      weak var  FixMixingTaste:NSButton!
   @IBOutlet      weak var  FixFunktionTaste:NSButton!
   @IBOutlet      weak var  FixAusagangTaste:NSButton!
   @IBOutlet      weak var  MasterRefreshTaste:NSButton!
   @IBOutlet      weak var  AdresseIncrement:NSButton!
   @IBOutlet      weak var  ReadSettingTaste:NSButton!
   @IBOutlet      weak var  ReadSenderTaste:NSButton!
   @IBOutlet      weak var  ReadFunktionTaste:NSButton!
   
   @IBOutlet   var      DataTable:NSTableView!
}// end class rRC

