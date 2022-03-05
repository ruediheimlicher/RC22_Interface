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

class rPopUpZelle:NSTableCellView, NSMenuDelegate,NSTableViewDataSource
{
   @IBOutlet weak var PopUp:NSPopUpButton?
   var poptag:Int = 0
   var itemindex:Int = 0
   var tablezeile:Int = 0
   var tablekolonne:Int = 0
    
   @IBAction func popupAction(_ sender: NSPopUpButton)
   {
     // print("popupAction tag: \(sender.tag)    itemindex: \(sender.indexOfSelectedItem) titel: \(sender.titleOfSelectedItem)")
      let sup = self.superview?.superview as! NSTableView
      let zeile = sup.row(for: self)
      let kolonne = sup.column(for: self)
      let tabletag = sup.tag
      itemindex = sender.indexOfSelectedItem
      print("popupAction tag: \(sender.tag)  itemindex: \(sender.indexOfSelectedItem) ***    zeile: \(zeile) kolonne: \(kolonne)  tabletag: \(tabletag)")
      //print("sup: \(sup)")
      
      var notDic = [String:Int]()
      notDic["itemindex"] = itemindex
      notDic["zeile"] = zeile
      notDic["kolonne"] = kolonne
      notDic["tabletag"] = tabletag
      let nc = NotificationCenter.default
      nc.post(name:Notification.Name(rawValue:"tablepop"),
              object: nil,
              userInfo: notDic)

   }
   @objc func popUpButtonUsed(_ sender: NSPopUpButton) 
   {
       print("popUpButtonUsed \(sender.indexOfSelectedItem)")
   }
   required init?(coder  aDecoder : NSCoder) 
   {
      super.init(coder: aDecoder)
      self.PopUp?.target = self
      self.PopUp?.action = #selector(popUpButtonUsed(_:))
    }
   override init(frame: CGRect) 
   {
         super.init(frame: frame)
        // initialize what is needed
     }
  
}

class rDevicePopUpZelle:rPopUpZelle
{
   @IBOutlet weak var DevicePopUp:NSPopUpButton?
   override init(frame: CGRect) 
   {
         super.init(frame: frame)
        // initialize what is needed
     }

   required init?(coder  aDecoder : NSCoder) 
   {
      super.init(coder: aDecoder)
      self.PopUp?.target = self
      self.PopUp?.action = #selector(popUpButtonUsed(_:))
    }

}


class rRC: rViewController, NSTabViewDelegate, NSTableViewDataSource,NSTableViewDelegate,NSComboBoxDataSource,NSComboBoxDelegate
{

   
 //  var popup:rPopUpZelle! 
   var hintergrundfarbe = NSColor()
 
   override func viewDidAppear() 
   {
      print ("RC viewDidAppear selectedDevice: \(selectedDevice)")
      KanalTable.dataSource = self
      KanalTable.delegate = self
 //     FunktionTable.dataSource = self
 //     FunktionTable.delegate = self
      MixingTable.dataSource = self
      MixingTable.delegate = self
 
      artpop.removeAllItems()
      levelapop.removeAllItems()
      levelbpop.removeAllItems()
      expoapop.removeAllItems()
      expobpop.removeAllItems()
      
      default_ONArray = [okimage, notokimage]
      default_RichtungArray = [[pfeillinksimage, pfeilrechtsimage],[pfeilupimage, pfeildownimage]]
      // https://stackoverflow.com/questions/43510646/how-to-change-font-size-of-nstableheadercell
 //     DispatchTable.tableColumns.forEach { (column) in column.headerCell.attributedStringValue = NSAttributedString(string: column.title, attributes: [NSAttributedStringKey.font: //NSFont.boldSystemFont(ofSize: 12)])
          // Optional: you can change title color also jsut by adding NSForegroundColorAttributeName
  //    }  
      

      DispatchTable.tableColumns.forEach { (column) in column.headerCell.attributedStringValue = NSAttributedString(string: column.title, attributes: [NSAttributedStringKey.font: NSFont.boldSystemFont(ofSize: 11)])
         // Optional: you can change title color also jsut by adding NSForegroundColorAttributeName
     }
      
      KanalTable.tableColumns.forEach { (column) in column.headerCell.attributedStringValue = NSAttributedString(string: column.title, attributes: [NSAttributedStringKey.font: NSFont.boldSystemFont(ofSize: 12)])
         // Optional: you can change title color also jsut by adding NSForegroundColorAttributeName
     }
      
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
         
         var   KanalSettingArray = [[String:UInt8]]()
         
         artpop.addItems(withTitles: default_ArtArray)
         levelapop.addItems(withTitles: default_LevelArray)
         levelbpop.addItems(withTitles: default_LevelArray)
         expoapop.addItems(withTitles: default_ExpoArray)
         expobpop.addItems(withTitles: default_ExpoArray)
         
         for kanal:UInt8 in 0..<8
         {
            var kanaldic = [String:UInt8]()
            kanaldic["kanalnummer"] = kanal
            kanaldic["art"] = kanal & 0x03
           
            kanaldic["richtung"] = 1
            kanaldic["levela"]  = kanal & 0x03
            kanaldic["levelb"]  = 3
            kanaldic["expoa"]  = 7-kanal & 0x03
            kanaldic["expob"]  = kanal & 0x03
            kanaldic["mix"]  = 1
            kanaldic["mixkanal"]  = kanal
            kanaldic["kanalonimage"]  = kanal%2
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
         for dispatchindex:UInt8 in 0..<8
         {
            let deveicedefault = Int(dispatchindex) // standardwert
            var dispatchdic = [String:UInt8]()
            
            dispatchdic["dispatchnummer"] = dispatchindex
            
            dispatchdic["dispatchfunktion"] = (dispatchindex ) & 0x07 // ausgesuchte funktion
            dispatchdic["dispatchkanal"] = dispatchindex 
            dispatchdic["dispatchdevice"] = (dispatchindex ) & 0x07
            dispatchdic["dispatchgo"] = 1 // verwendet 
            dispatchdic["dispatchonimage"] = dispatchindex%2 // verwendet
            dispatchdic["dispatchpopup"] = dispatchindex & 0x03 
            
            // von kanal
            dispatchdic["dispatchrichtung"] = 1
            dispatchdic["dispatchlevela"]  = dispatchindex & 0x03
            dispatchdic["dispatchlevelb"]  = 3
            dispatchdic["dispatchexpoa"]  = 7-dispatchindex & 0x03
            dispatchdic["dispatchexpob"]  = dispatchindex & 0x03
            dispatchdic["dispatchmix"]  = 1
            dispatchdic["dispatchmixkanal"]  = dispatchindex
            dispatchdic["dispatchmodelnummer"]  = model
            dispatchdic["dispatchmodel"]  = model
            DispatchSettingArray.append(dispatchdic)
         }
         DispatchArray.append(DispatchSettingArray)

       }// for model
      
      
      DispatchTable.target = self      
      DispatchTable.dataSource = self
      DispatchTable.delegate = self
      
      
      KanalTable.dataSource = self
      KanalTable.delegate = self
      //FunktionTable.reloadData()
      KanalTable.reloadData()
      MixingTable.reloadData()
      DispatchTable.reloadData()
      


      
   
      //var            FunktionArray = [UInt8]()
      
      (SettingTab.selectedTabViewItem?.view?.viewWithTag(100) as! NSTextField).stringValue =  "Mod 0"

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
   
      NotificationCenter.default.addObserver(self, selector:#selector(tablePopAktion(_:)),name:NSNotification.Name(rawValue: "tablepop"),object:nil)

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
   
   
    @IBAction func report_artPop(_ sender: NSPopUpButton) 
   {
      print("report_artPop item: \(sender.indexOfSelectedItem)")
      if (clickedkanalarrayrow >= 0)
      {
      let itemstring = sender.titleOfSelectedItem
      KanalArray[0][clickedkanalarrayrow]["art"] = UInt8(sender.indexOfSelectedItem) 
      KanalTable.reloadData()
      }
   }


 
   var     default_DeviceArray:[String] = ["Pitch_L_H","Pitch_L_V","Pitch_R_H","Pitch_R_V","Schieber_L","Schieber_R","Schalter","leer"]
   var     default_FunktionArray:[String] = ["Seite","Hoehe","Quer","Motor","Quer L","Quer R","Lande","Aux"]
   var     default_KanalArray:[String] = ["0","1","2","3","4","5","6","7"]

   var default_ArtArray = ["Stick","Schieber","Schalter","-"]
   
   var default_LevelArray = ["1/1","7/8","3/4","5/8","1/2"]
   var default_ExpoArray = ["1/1","7/8","3/4","5/8","1/2"]
 
   var default_RichtungArray:[[NSImage]] = [[NSImage]]()//[pfeilup pfeildown], [pfeillinks pfeilrechts]
   
   var default_ONArray:[NSImage] = [NSImage]()//[okimage, notokimage]
   @objc func usbstatusAktion(_ notification:Notification) 
  {
     let info = notification.userInfo
     let status = info?["usbstatus"] as! Int32 // 
     print("Trigo usbstatusAktion:\t \(status) ")
     usbstatus = Int32(status)
  }

   @objc func  tablePopAktion(_ notification:Notification) 
   {
      let info = notification.userInfo
      let itemindex = info?["itemindex"] as! Int // 
      let zeile = info?["zeile"] as! Int 
      let kolonne = info?["kolonne"] as! Int 
      var tabletag = info?["tabletag"] as! Int 
      tabletag/=100
      print("\n* * * * RC tablePopAktion itemindex:\t \(itemindex) zeile: \(zeile) kolonne: \(kolonne) tabletag: \(tabletag)")
      switch tabletag
      {
         case 4: // Kanal
         DispatchArray[0][zeile]["dispatchkanal"]  = UInt8(itemindex)
         DispatchTable.reloadData()
         /*
         for ident in 0..<DispatchArray[0].count-1
         {
         printArray(DispatchArray[0],index: ident)
         }
        */
         
         break
      case 5: // Mixing
         break
      case 6: // Dispatch
         print("case 6 dispatch kolonne: \(kolonne)")
         switch kolonne
         {
         case columnfunktion: // funktion
            DispatchArray[0][zeile]["dispatchfunktion"]  = UInt8(itemindex)
            DispatchTable.reloadData()
            print("dispatchfunktion")
            
            //printArray(DispatchArray[0],index:2)
            /*
             for ident in 0..<DispatchArray[0].count-1
             {
             printArray(DispatchArray[0],index: ident)
             }
             */
            break
            
         case columndevice: // device(Steuerelement)
            DispatchArray[0][zeile]["dispatchdevice"]  = UInt8(itemindex)
            DispatchTable.reloadData()
            print("dispatchdevice")
            
            //printArray(DispatchArray[0],index:2)
            /*
             for ident in 0..<DispatchArray[0].count-1
             {
             printArray(DispatchArray[0],index: ident)
             }
             */
            break
            
         case columnon: // onimage
            let onwert = UInt8(DispatchArray[0][zeile]["dispatchonimage"] ?? 0)
            
            DispatchArray[0][zeile]["dispatchonimage"]  = 1 - onwert
            DispatchTable.reloadData()
            print("dispatchonimage")
            

            
           /* 
         case 4: // Kanal
            DispatchArray[0][zeile]["dispatchkanal"]  = UInt8(itemindex)
            DispatchTable.reloadData()
            print("dispatchkanal")
            
            //printArray(DispatchArray[0],index:2)
            /*
             for ident in 0..<DispatchArray[0].count-1
             {
             printArray(DispatchArray[0],index: ident)
             }
             */
            break
            */
            
        /*    
         case 5: // dispatchpopup
            DispatchArray[0][zeile]["dispatchpopup"]  = UInt8(itemindex)
            DispatchTable.reloadData()
            print("dispatchpopup")
            //printArray(DispatchArray[0],index:5)
            
             for ident in 0..<DispatchArray[0].count-1
             {
             printArray(DispatchArray[0],index: ident)
             }
             
            break
           */ 
         case columnlevela:
            DispatchArray[0][zeile]["dispatchlevela"]  = UInt8(itemindex)
            DispatchTable.reloadData()
            print("dispatchlevela")
            
         case columnlevelb:
            DispatchArray[0][zeile]["dispatchlevelb"]  = UInt8(itemindex)
            DispatchTable.reloadData()
            print("dispatchlevelb")
            
         case columnexpob:
            DispatchArray[0][zeile]["dispatchexpoa"]  = UInt8(itemindex)
            DispatchTable.reloadData()
            print("columnexpoa")
            
         case columnexpob:
            DispatchArray[0][zeile]["dispatchexpob"]  = UInt8(itemindex)
            DispatchTable.reloadData()
            print("columnexpob")
         
         case columnrichtung:
            DispatchArray[0][zeile]["dispatchrichtung"]  = UInt8(itemindex)
            DispatchTable.reloadData()
            print("columnrichtung")
            
            
            
         default: break
         }// switch kolonne
         DispatchArray[0][zeile]["dispatchpopup"]  = UInt8(itemindex)
         DispatchTable.reloadData()
         /*
         for ident in 0..<DispatchArray[0].count-1
         {
         printArray(DispatchArray[0],index: ident)
         }
          */
         break
      default:
         break
      }// switch tabletag
      
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
      
      print("*** report_tableRowWasClicked row \(zeile), col \(kolonne) ident: \(ident)")
      switch identstring
      {
      case "dispatch":
         print("*********  ******  table dispatch clicked  zeile: \(zeile)")
         clickeddispacharrayrow = Int(zeile)
         if (kolonne == 3) // ON
         {
            let wert = UInt8(DispatchArray[0][zeile]["dispatchonimage"] ?? 0 )
            DispatchArray[0][zeile]["dispatchonimage"]  = 1 - wert
            DispatchTable.reloadData()
         }
         /*
         let row = DispatchTable.rowView(atRow: kolonne, makeIfNecessary: false)
         let popident = NSUserInterfaceItemIdentifier(rawValue:"popup")
         guard let pop = row?.view(atColumn: columnon) as? rPopUpZelle else 
         {
            print("clicked: dispatchpop ist nil")
            return 
            
         }
          
        // let pop = row?.view(atColumn: 5) as? rPopUpZelle
         let popindex = pop.PopUp?.indexOfSelectedItem
         let titel = pop.PopUp?.titleOfSelectedItem
         let ind = pop.itemindex
         print("dispatch popindex: \(popindex) titel: \(titel) itemindex: \(ind)")
          */
         
      case "kanal":
         print("*********  ******  table kanal clicked zeile: \(zeile)")
         clickedkanalarrayrow = Int(zeile)
         if (kolonne == 7) // ON
         {
            let wert = UInt8(KanalArray[0][zeile]["kanalonimage"] ?? 0 )
            print("table kanal wert vor: \(wert)")
            KanalArray[0][zeile]["kanalonimage"]  = 1 - wert
            //rundeFeld.intValue = Int32(KanalArray[0][zeile]["kanalonimage"] ?? 0)
            //print("table kanal wert nach: \(KanalArray[0][zeile]["kanalonimage"])")
            KanalTable.reloadData()
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
   func printTable(_ tableview:NSTableView)
   {
      let identarray = tableview.tableColumns
      let zeilen = tableview.numberOfRows
      for z in 0..<zeilen-1
      {
         for k in 0..<identarray.count-1
         {
         let ident = identarray[k].title
         print("z: \(z) col: \(ident) ")
         }
      }
      
   }
   func printArray(_ data:[[String:UInt8]] , index:Int)
   {
   
      let zeilen = data.count
      //let keys = Array(data.keys)
      //var arr = [String]()

      let keys = data[0].map {$0.key}
      
      for z in 0..<data[0].count-1
      {
         
         let d:Int = Int(data[z][keys[index]] ?? 0)
         print("\t\(keys[index]) \t \t\(d)")
      }
      var z = index
        //print("Zeile: \(z)")
      
      for k in keys
      {
         let d:Int = Int(data[z][k] ?? 0)
 //        print("\t\(k) \t \t\(d)")
      }
 //     }
   }
   
   //func numberOfRowsInTableView(tableView: NSTableView) -> Int
   func numberOfRows(in tableView: NSTableView) -> Int
   {
      // PopUp: https://www.appcoda.com/macos-programming-tableview/
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
         
         return DispatchArray[0].count
         
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
      //let ident = tableColumn?.identifier.rawValue
      //print ("viewFor row: \(row) ident: \(ident)")
      //if ident == "dispatchdevice"
      //let defaultwert = NSUserInterfaceItemIdentifier(rawValue:"dispatchdevice")
      
      // no arrow: https://stackoverflow.com/questions/4376393/how-can-i-create-a-nspopupbutton-that-uses-a-fixed-image-and-no-arrows
      
      if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"dispatchdevice") )
      {
         
         let popident = NSUserInterfaceItemIdentifier(rawValue:"devicepopup")
         guard var result = tableView.makeView(withIdentifier: popident, owner: self) as? rPopUpZelle else 
         {
            print("viewFor dispatchdevice ist nil")
            return nil 
         }
         
         var wert = Int(DispatchArray[0][row]["dispatchdevice"] ?? 0)
         if wert > default_DeviceArray.count - 1
         {
            wert = 4
         }
         result.poptag = row
         result.tablezeile = row
         result.tablekolonne = tableView.column(for: result)
         result.PopUp?.removeAllItems()
         result.PopUp?.addItems(withTitles: default_DeviceArray)
         result.PopUp?.selectItem(at: wert)
  //       let popupCell = result.PopUp?.cell as! NSPopUpButtonCell
  //       popupCell.arrowPosition = NSPopUpButton.ArrowPosition.noArrow
         
         return result

        
      }

      
      else  if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"dispatchlevela") )
      {
         let popident = NSUserInterfaceItemIdentifier(rawValue:"levelpopup")
         guard let result = tableView.makeView(withIdentifier: popident, owner: self) as? rPopUpZelle else 
         {
            print("dispatchlevela ist nil")
            return nil 
         }
         var wert = Int(DispatchArray[0][row]["dispatchlevela"] ?? 0)
         if wert > default_LevelArray.count - 1
         {
            wert = 4
         }
         result.poptag = row
         result.tablezeile = row
         result.tablekolonne = tableView.column(for: result)
         result.PopUp?.removeAllItems()
         result.PopUp?.addItems(withTitles: default_LevelArray)
         result.PopUp?.selectItem(at: wert)
         return result

         }

      else  if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"dispatchlevelb") )
      {
         let popident = NSUserInterfaceItemIdentifier(rawValue:"levelpopup")
         guard let result = tableView.makeView(withIdentifier: popident, owner: self) as? rPopUpZelle else 
         {
            print("dispatchlevelb ist nil")
            return nil 
         }
         var wert = Int(DispatchArray[0][row]["dispatchlevelb"] ?? 0)
         if wert > default_LevelArray.count - 1
         {
            wert = 4
         }
         result.poptag = row
         result.tablezeile = row
         result.tablekolonne = tableView.column(for: result)
         result.PopUp?.removeAllItems()
         result.PopUp?.addItems(withTitles: default_LevelArray)
         result.PopUp?.selectItem(at: wert)
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
         //print("dispatchnummer nummer: \(nummer)")
         result.textField?.intValue = Int32(nummer) 
         
         return result
      }
  
      else  if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"dispatchfunktion") )
      {
         let popident = NSUserInterfaceItemIdentifier(rawValue:"funktionpopup")
         guard let result = tableView.makeView(withIdentifier: popident, owner: self) as? rPopUpZelle else 
         {
            print("dispatchfunktion ist nil")
            return nil 
         }
         var wert = Int(DispatchArray[0][row]["dispatchfunktion"] ?? 0)
         if wert > default_FunktionArray.count - 1
         {
            wert = 4
         }
         result.poptag = row
         result.tablezeile = row
         result.tablekolonne = tableView.column(for: result)
         result.PopUp?.removeAllItems()
         result.PopUp?.addItems(withTitles: default_FunktionArray)
         result.PopUp?.selectItem(at: wert)
      //   let popupCell = result.PopUp?.cell as! NSPopUpButtonCell
       //  popupCell.arrowPosition = NSPopUpButton.ArrowPosition.noArrow
         return result
      } // funktion

      else  if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"dispatchonimage") )
      {
         guard let result = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else 
         {
            print("dispatchonimage ist nil")
            return nil 
            
         }
         let nummer = Int(DispatchArray[0][row]["dispatchonimage"] ?? 0)
         let wert:Int = nummer
         //print("dispatchnummer onimage: \(wert)")
         //https://stackoverflow.com/questions/37100846/osx-swift-add-image-into-nstableview
         // Image muss mit TableCellView verlinkt sein!!! S. Screenshot TableView Image
         result.imageView?.image = default_ONArray[wert]
         return result

      } // onimage
      
      else  if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"dispatchrichtung") )

      {
         let popident = NSUserInterfaceItemIdentifier(rawValue:"popup")
         guard let result = tableView.makeView(withIdentifier: popident, owner: self) as? rPopUpZelle else 
         {
            print("dispatchrichtung ist nil")
            return nil 
            
         }
         var wert = Int(DispatchArray[0][row]["dispatchrichtung"] ?? 0)
          if wert > default_RichtungArray[0].count - 1
          {
             wert = 4
          }
         result.poptag = row
         result.tablezeile = row
         result.tablekolonne = tableView.column(for: result)
         result.PopUp?.removeAllItems()
         for zeile in 0..<default_RichtungArray[0].count
         {
         result.PopUp?.addItem(withTitle: "")
         var item = result.PopUp?.lastItem
             item?.image = default_RichtungArray[0][zeile]
         }
         result.PopUp?.selectItem(at: wert)
  //       print("dispatchpop row: \(row) kolonne: \(tableView.column(for: result))")
   //      let popupCell = result.PopUp?.cell as! NSPopUpButtonCell
  //       popupCell.arrowPosition = NSPopUpButton.ArrowPosition.noArrow

         return result
      }//

      /*
      else  if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"dispatchpopup") )
      {
         let popident = NSUserInterfaceItemIdentifier(rawValue:"richtungpopup")
         guard let result = tableView.makeView(withIdentifier: popident, owner: self) as? rPopUpZelle else 
         {
            print("richtungpop ist nil")
            return nil 
            
         }
         var wert = Int(DispatchArray[0][row]["dispatchrichtung"] ?? 0)
          if wert > default_RichtungArray.count - 1
          {
             wert = 4
          }
         result.poptag = row
         result.tablezeile = row
         var pfeilrichtung = 0
         // index von funktion checken
         let funktionindex = Int(DispatchArray[0][row]["dispatchfunktion"] ?? 0)
         if funktionindex == 1 // Hoehe
         {
            pfeilrichtung = 1
         }
         result.tablekolonne = tableView.column(for: result)
         result.PopUp?.removeAllItems()
         for zeile in 0..<default_RichtungArray[0].count
         {
         result.PopUp?.addItem(withTitle: "")
         var item = result.PopUp?.lastItem
             item?.image = default_RichtungArray[pfeilrichtung][zeile]
         }
         result.PopUp?.selectItem(at: wert)
  //       print("dispatchpop row: \(row) kolonne: \(tableView.column(for: result))")
         let popupCell = result.PopUp?.cell as! NSPopUpButtonCell
         popupCell.arrowPosition = NSPopUpButton.ArrowPosition.noArrow

         return result
      }//
     */ 

  // Kanal
      if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"kanalnummer") )
      {
         guard let result = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else 
         {
            print("kanal kanalnummer ist nil")
            return nil 
            
         }
         let wert = Int(KanalArray[0][row]["kanalnummer"] ?? 0)
         //print("kanalnummer wert: \(wert)")
         result.textField?.integerValue = wert
         return result
      } // kanalnummer
     //default_ArtArray
      else if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"art") )
      {
         guard let result = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else 
         {
            print("kanal art ist nil")
            return nil 
            
         }
        var wert = Int(KanalArray[0][row]["art"] ?? 0)
         if wert > default_ArtArray.count - 1
         {
            wert = 3
         }
         //print("kanalnummer wert: \(wert)")
         result.textField?.stringValue = default_ArtArray[wert]
         return result
      } // kanalnummer
      else  if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"richtung") )
      {
         let popident = NSUserInterfaceItemIdentifier(rawValue:"popup")
         guard let result = tableView.makeView(withIdentifier: popident, owner: self) as? rPopUpZelle else 
         {
            print("richtungpop ist nil")
            return nil 
            
         }
         var wert = Int(KanalArray[0][row]["richtung"] ?? 0)
          if wert > default_ArtArray.count - 1
          {
             wert = 4
          }
         result.poptag = row
         result.tablezeile = row
         result.tablekolonne = tableView.column(for: result)
         result.PopUp?.removeAllItems()
         for zeile in 0..<default_RichtungArray[0].count
         {
         result.PopUp?.addItem(withTitle: "")
         var item = result.PopUp?.lastItem
             item?.image = default_RichtungArray[0][zeile]
        // result.PopUp?.addItems(withTitles: default_RichtungArray[0])
         }
         result.PopUp?.selectItem(at: wert)
  //       print("dispatchpop row: \(row) kolonne: \(tableView.column(for: result))")
         let popupCell = result.PopUp?.cell as! NSPopUpButtonCell
         popupCell.arrowPosition = NSPopUpButton.ArrowPosition.noArrow

         return result
      }//

      else if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"levela") )
      {
         guard let result = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else 
         {
            print("kanal levela ist nil")
            return nil 
         }
        var wert = Int(KanalArray[0][row]["levela"] ?? 0)
         if wert > default_LevelArray.count - 1
         {
            wert = 4
         }
         //print("levela wert: \(wert)")
         result.textField?.stringValue = default_LevelArray[wert]
         return result
      } // levela
      else if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"levelb") )
      {
         guard let result = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else 
         {
            print("kanal levelb ist nil")
            return nil 
         }
        var wert = Int(KanalArray[0][row]["levelb"] ?? 0)
         if wert > default_LevelArray.count - 1
         {
            wert = 4
         }
         //print("levelb wert: \(wert)")
         result.textField?.stringValue = default_LevelArray[wert]
         return result
      } // levelb
      else if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"expoa") )
      {
         guard let result = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else 
         {
            print("kanal expoa ist nil")
            return nil 
         }
        var wert = Int(KanalArray[0][row]["expoa"] ?? 0)
         if wert > default_LevelArray.count - 1
         {
            wert = 4
         }
         //print("expoa wert: \(wert)")
         result.textField?.stringValue = default_ExpoArray[wert]
         return result
      } // expoa
      else if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"expob") )
      {
         guard let result = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else 
         {
            print("kanal expoa ist nil")
            return nil 
         }
        var wert = Int(KanalArray[0][row]["expob"] ?? 0)
         if wert > default_LevelArray.count - 1
         {
            wert = 4
         }
         //print("expob wert: \(wert)")
         result.textField?.stringValue = default_ExpoArray[wert]
         return result
      } // expoa
      
      else  if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"kanalonimage") )
      {
         
         guard let result = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else 
         {
            print("kanalon ist nil")
            return nil 
         }
         let nummer = Int(KanalArray[0][row]["kanalonimage"] ?? 0)
         let wert:Int = nummer
   //      print("kanal on row: \(row) wert: \(wert)")
         //https://stackoverflow.com/questions/37100846/osx-swift-add-image-into-nstableview
         let bild:NSImage = default_ONArray[wert]
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
         let popident = NSUserInterfaceItemIdentifier(rawValue:"devicepopup")
         guard var result = tableView.makeView(withIdentifier: popident, owner: self) as? rPopUpZelle else 
         {
            print("viewFor dispatchdevice ist nil")
            return nil 
         }

         /*
         guard let result = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else 
         {
            print("objVal dispatchdevice ist nil")
            return nil 
            
         }
         */
         let nummer = Int(DispatchArray[0][row]["dispatchdevice"] ?? 0)
         let wert:Int = nummer
         //print("dispatchdevice device: \(nummer)")
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
         //print("dispatchkanal kanal: \(nummer)")
         
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
         //print("dispatchnummer nummer: \(nummer)")
         result.textField?.intValue = Int32(nummer) 
         
         return result
      }
     
      // Kanal
      if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"kanalnummer") )
      {
         guard let result = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else 
         {
            print("kanalnummer ist nil")
            return nil 
         }

         let nummer = Int(KanalArray[0][row]["kanalnummer"] ?? 0)
         let wert:Int = nummer
         //print("kanalnummer nummer: \(nummer)")
         result.textField?.intValue = Int32(nummer) 
         
         return result
      }
      else if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"kanalonimage") )
      {
         guard let result = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else 
         {
            print("kanalonimage ist nil")
            return nil 
         }

         let nummer = Int(KanalArray[0][row]["kanalonimage"] ?? 0)
         let wert:Int = nummer
         //print("kanalonimage nummer: \(nummer)")
         result.imageView?.image = default_ONArray[wert]
         
         return result
      }

      
      
      return nil
   } //objectValueFor
   
   
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

   var            clickedkanalarrayrow:Int = -1 // angeklickte Zeile
   
   var data: [[String: String]] = [[:]]
   
   
    
// MARK: outlets
   // @IBOutlet weak var Pot1_Feld_raw: NSTextField!
   @IBOutlet  weak var     dumpTable: NSTableView!
  
   @IBOutlet   weak var          logTable:NSTableView!
   @IBOutlet   weak var          window:NSWindow!
   @IBOutlet   weak var          macroPopup:NSPopUpButton!
   @IBOutlet   weak var          readButton:NSButton!

   @IBOutlet    var     richtungpoppop:NSPopUpButton!
   @IBOutlet    var     artpop:NSPopUpButton!
   @IBOutlet    var     levelapop:NSPopUpButton!
   @IBOutlet    var     levelbpop:NSPopUpButton!
   @IBOutlet    var     expoapop:NSPopUpButton!
   @IBOutlet    var     expobpop:NSPopUpButton!
  
   
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

//   @IBOutlet      weak var   FunktionTable:NSTableView!
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

