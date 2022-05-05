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
   @IBOutlet weak var ImageButton:NSButton?
   
   var poptag:Int = 0
   var itemindex:Int = 0
   var tablezeile:Int = 0
   var tablekolonne:Int = 0
    
   @IBAction func popupAction(_ sender: NSPopUpButton)
   {
      print("popupAction tag: \(sender.tag)    itemindex: \(sender.indexOfSelectedItem) titel: \(sender.titleOfSelectedItem)")
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
   
   @IBAction func imageAction(_ sender: NSButton)
   {
      print("imageAction tag: \(sender.tag)")
      let sup = self.superview?.superview as! NSTableView
      let zeile = sup.row(for: self)
      let kolonne = sup.column(for: self)
      let tabletag = sup.tag
      
      print("imageAction tag: \(sender.tag)      zeile: \(zeile) kolonne: \(kolonne)  tabletag: \(tabletag)")
      //print("sup: \(sup)")
      
      var notDic = [String:Int]()
      notDic["itemindex"] = 0
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

class rBox:NSView
{
   var hintergrundfarbe = NSColor()
   override init(frame: CGRect) 
   {
         super.init(frame: frame)
        // initialize what is needed
     }

   required init?(coder  aDecoder : NSCoder) 
   {
      hintergrundfarbe  = NSColor.init(red: 0.45, 
                                    green: 0.95, 
                                    blue: 0.55, 
                                    alpha: 0.15)

      super.init(coder: aDecoder)
      self.wantsLayer = true
      self.layer?.backgroundColor = hintergrundfarbe.cgColor

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

// MARK: Konstanten


let USB_DATA_OFFSET = 4
let ANZAHLMODELLE = 3
let KANALSETTINGBREITE = 4
let MODELSETTINGBREITE = 32// nur Kanalsettings. Anschliessend MixingSettings
let EEPROM_MODELSETTINGBREITE  = 64 //Kanalsettings und MixingSettings


let MIXINGSETTINGBREITE = 2

let USB_DATENBREITE = 64

let ADCOFFSET  = 48



class rRC: rViewController, NSTabViewDelegate, NSTableViewDataSource,NSTableViewDelegate,NSComboBoxDataSource,NSComboBoxDelegate
{
   
   var teensysettingarray = [[[UInt8]]](repeating:[[UInt8]](repeating:[UInt8](repeating: 0,count:4), count:8)  , count:ANZAHLMODELLE)
  
   var teensymixingarray = [[[UInt8]]](repeating:[[UInt8]](repeating:[UInt8](repeating: 0,count:2), count:4)  , count:ANZAHLMODELLE)

 //  var popup:rPopUpZelle! 
   var hintergrundfarbe = NSColor()
   var modelnummer = 0
   
   var usbcounter = 0
   
   
   
    override func viewDidAppear() 
   {
      print ("RC viewDidAppear selectedDevice: \(selectedDevice)")
  
      SettingTab.drawsBackground = true
      //SettingTab.wantsLayer = true
      //SettingTab.layer?.backgroundColor = NSColor.blue.cgColor

      MixingTable.dataSource = self
      MixingTable.delegate = self
 
      
      default_ONArray = [notokimage, okimage]
      default_RichtungArray = [[pfeillinksimage, pfeilrechtsimage],[pfeilupimage, pfeildownimage]]
      // https://stackoverflow.com/questions/43510646/how-to-change-font-size-of-nstableheadercell
      MixingTable.tableColumns.forEach { (column) in
         column.headerCell.attributedStringValue = NSAttributedString(string: column.title, attributes: [NSAttributedStringKey.font: NSFont.boldSystemFont(ofSize: 11)])
      }      

      DispatchTable.tableColumns.forEach { (column) in column.headerCell.attributedStringValue = NSAttributedString(string: column.title, attributes: [NSAttributedStringKey.font: NSFont.boldSystemFont(ofSize: 11)])
         // Optional: you can change title color also jsut by adding NSForegroundColorAttributeName
     }
      
      
      for model:UInt8 in 0..<UInt8(ANZAHLMODELLE)
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
           // kanaldic["mix"]  = 1
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
            mixingdic["mixonimage"] = 0
            mixingdic["mixart"] = 1
            mixingdic["mixkanala"] = 0x00
            mixingdic["mixkanalb"] = 0x01
            mixingdic["mixing"] = 0 // verwendet als Mix xy
            MixingSettingArray.append(mixingdic)
         }
         MixingSettingArray[0]["mixart"] = 0x01
         MixingSettingArray[1]["mixart"] = 0x02
         MixingSettingArray[2]["mixart"] = 0x00
         MixingSettingArray[3]["mixart"] = 0x00
         
  //       MixingSettingArray[0]["mixonimage"] = 1 // mixing 0
         
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
            //dispatchdic["dispatchgo"] = 1 // verwendet 
            dispatchdic["dispatchonimage"] = 1 //dispatchindex%2 // verwendet
            // von kanal
            dispatchdic["dispatchrichtung"] = 1
            dispatchdic["dispatchlevela"]  = dispatchindex & 0x03
            dispatchdic["dispatchlevelb"]  = 4-dispatchindex & 0x03
            dispatchdic["dispatchexpoa"]  = 4-dispatchindex & 0x03
            dispatchdic["dispatchexpob"]  = dispatchindex & 0x03
            
            dispatchdic["dispatchlevela"]  = 0
            dispatchdic["dispatchlevelb"]  = 0
            dispatchdic["dispatchexpoa"]  = 0
            dispatchdic["dispatchexpob"]  = 0
            
            
            
            
            
            //dispatchdic["dispatchmix"]  = 1
            //dispatchdic["dispatchmixkanal"]  = dispatchindex
            dispatchdic["dispatchmodelnummer"]  = model
            dispatchdic["dispatchmodel"]  = model
            DispatchSettingArray.append(dispatchdic)
         }
         DispatchArray.append(DispatchSettingArray)
         
      }// for model
      
      
      DispatchTable.target = self      
      DispatchTable.dataSource = self
      DispatchTable.delegate = self
      
      
      MixingTable.reloadData()
      DispatchTable.reloadData()
      
      
//      (SettingTab.selectedTabViewItem?.view?.viewWithTag(100) as! NSTextField).stringValue =  "Mod 0"

      eepromwritestatus = 0
      Halt_Taste.toolTip = "HALT vor Aenderungen im EEPROM"
      
     // model.selectSegment(withTag: 0)
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
                                    green: 0.95, 
                                    blue: 0.45, 
                                    alpha: 0.25)
      self.view.layer?.backgroundColor =  hintergrundfarbe.cgColor
      formatter.maximumFractionDigits = 1
      formatter.minimumFractionDigits = 2
      formatter.minimumIntegerDigits = 1
      //formatter.roundingMode = .down
      
 // teensysettingarray[model][kanal].append(data)
      //USB_OK.backgroundColor = NSColor.greenColor()
      // Do any additional setup after loading the view.
      let newdataname = Notification.Name("newdata")
      NotificationCenter.default.addObserver(self, selector:#selector(newRCDataAktion(_:)),name:newdataname,object:nil)
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
   // MARK: newDataAktion
   @objc  func newRCDataAktion(_ notification:Notification) 
   {
       let info = notification.userInfo
      
     // print("new DataAktion info: \(String(describing: info))")
      //print("new DataAktion")
      let data = notification.userInfo?["data"] as! [UInt8]

      let code = data[0]
      if (code > 0)
      {
        // print("new data: \(String(describing: data)) \n") // data: Optional([0, 9, 51, 0,....

         switch code
         {
         case 0xA0: // idle
            
               let pot0 = ((Int32(data[ADCOFFSET + 1])<<8) + Int32(data[ADCOFFSET]))
               //print("stick 0: hb: \(data[9]) lb: \(data[8]) u: \(u)")
               Pot0_SliderInt.intValue = pot0
               Pot0_DataFeld.intValue = pot0
               let pot1 = ((Int32(data[ADCOFFSET + 2 + 1])<<8) + Int32(data[ADCOFFSET + 2]))
               //print("stick 1: hb: \(data[9]) lb: \(data[8]) u: \(u)")
               Pot1_SliderInt.intValue = pot1
               Pot1_DataFeld.intValue = pot1

           
            
         case 0xF5:
            // MARK: F5
            print("newDataAktion 0xF5")
            let modelindex = Int((data[USB_DATA_OFFSET]) & 0x07)
            
            let kanalindex = Int((data[USB_DATA_OFFSET]) & 0x70)
            let ON = ((data[USB_DATA_OFFSET]) & 0x08) >> 3 // bit 4
            let richtung = ((data[USB_DATA_OFFSET]) & 0x80) >> 7 // bit 7
            print("newDataAktion data5: \(data[USB_DATA_OFFSET]) modelindex: \(modelindex) ON: \(ON) richtung: \(richtung)")
            /*
             NSMutableDictionary* mixingdic = [[NSMutableDictionary dictionaryWithObjectsAndKeys:
             [NSNumber numberWithInt:settingindex],@"mixnummer",
             [NSNumber numberWithInt:0],@"mixart",
             [NSNumber numberWithInt:0xFF],@"canala",
             [NSNumber numberWithInt:0xFF],@"canalb",
             [NSString stringWithFormat:@"Mix %d",0],@"mixing",

             */
            /*
             for z in 0..<USB_DATENBREITE
             {
             print("\(z) \t\(data[z])")
             }
             */
            
           // decodeUSBChannelSettings(_ buffer:[UInt8], model:UInt8) -> [[UInt8]] 
            let newdata:[[UInt8]]  = decodeUSBChannelSettings(data, model:0) // 8 array mit settings
       
            
            //importCurrentTableData(newdata, kanal:kanalindex, model: modelindex)
           
     //       importTableData(newdata,  model: modelindex)

            
            let pot0 = ((Int32(data[ADCOFFSET + 1])<<8) + Int32(data[ADCOFFSET]))
            //print("stick 0: hb: \(data[9]) lb: \(data[8]) u: \(u)")
            Pot0_SliderInt.intValue = pot0
            Pot0_DataFeld.intValue = pot0
            let pot1 = ((Int32(data[ADCOFFSET + 2 + 1])<<8) + Int32(data[ADCOFFSET + 2]))
            //print("stick 1: hb: \(data[9]) lb: \(data[8]) u: \(u)")
            Pot1_SliderInt.intValue = pot1
            Pot1_DataFeld.intValue = pot1
            print("newDataAktion data5 end\n\n")
            break
            
         case 0xF7: // antwort auf report_getTeensySettings
            // MARK: F7
            print("newDataAktion 0xF7")
            
            let modelindex = Int((data[USB_DATA_OFFSET]) & 0x07)
            
           // let kanalindex = Int((data[USB_DATA_OFFSET]) & 0x70) >> 4
            
   //         decodeTeensySettings(data, model: modelindex)
            
            let ON = ((data[USB_DATA_OFFSET]) & 0x08) >> 3 // bit 4
            let richtung = ((data[USB_DATA_OFFSET]) & 0x80) >> 7 // bit 7
            //print("newDataAktion data status(4): \(data[USB_DATA_OFFSET]) modelindex: \(modelindex) ON: \(ON) kanalindex: \(kanalindex)  richtung: \(richtung)")
            
            var currentdata = [UInt8]()
            for kanalindex in 0..<8
            {
               for pos in 0..<4
               {
                  
                  //let d = data[USB_DATA_OFFSET + pos]
                  //currentdata.append(data[USB_DATA_OFFSET + pos])
                  //print("kanalindex: \(kanalindex) pos: \(pos) data: \(data[USB_DATA_OFFSET + pos])")
                  teensysettingarray[modelindex][kanalindex][pos] = data[USB_DATA_OFFSET + kanalindex * KANALSETTINGBREITE + pos]
               }
            }
    //        [[136, 64, 4, 0], [152, 49, 19, 17], [168, 34, 34, 34], [184, 19, 49, 51], [200, 64, 4, 68], [216, 49, 19, 85], //[232, 34, 34, 102], [248, 19, 49, 119]]
            print("F7 modelindex: \(modelindex)  \n teensysettingarray: \(teensysettingarray[modelindex ])")
            importTableData(teensysettingarray[modelindex], model:0)
  
            // import Mixing : 
            //   teensymixingarray = [[[UInt8]]](repeating:[[UInt8]](repeating:[UInt8](repeating: 0,count:2), count:4)  , count:ANZAHLMODELLE)
            for mixindex in 0..<4
            {
               for pos in 0..<2
               {
                  teensymixingarray[modelindex][mixindex][pos] = data[USB_DATA_OFFSET + MODELSETTINGBREITE + mixindex * MIXINGSETTINGBREITE + pos]
               }
            }
            // [[24, 16], [96, 16], [128, 16], [255, 255]]
            print("F7 modelindex: \(modelindex)  \n teensymixingarray: \(teensymixingarray[modelindex ])")
            importMixingData(teensymixingarray[modelindex], model: 0)
            
            
            break
         default:
            break
         }// switch code
         
         //let dic = notification.userInfo as? [String:[UInt8]]
         //print("dic: \(dic ?? ["a":[123]])\n")
      } // if code
   }
   
   @IBAction func report_Model(_ sender: NSSegmentedControl) 
  {
   print("report_Model model: \(sender.indexOfSelectedItem)")
     //modelFeld.integerValue = sender.indexOfSelectedItem
  }
   
    @IBAction func report_artPop(_ sender: NSPopUpButton) 
   {
      print("report_artPop item: \(sender.indexOfSelectedItem)")
      if (clickedkanalarrayrow >= 0)
      {
      let itemstring = sender.titleOfSelectedItem
      KanalArray[0][clickedkanalarrayrow]["art"] = UInt8(sender.indexOfSelectedItem) 
      }
   }

   func decodeUSBChannelSettings(_ buffer:[UInt8], model:UInt8) -> [[UInt8]] // daten fuer Modellnummer aus USB
   {
     var data = [[UInt8]]()
      let code = buffer[0]
      let hexcode = String(format: "%02X", code)
      print("decodeUSBSettings code: \(code) hex: \(hexcode)")
      var pos:Int = USB_DATA_OFFSET
      
      for kanal in 0..<8
      {
         var kanalarray = [UInt8]()
         
         for dataindex in 0..<4
         {
            //print("pos: \(pos) dataindex: \(dataindex)")
            kanalarray.append(buffer[pos + dataindex]) // status, level, expo, funktion
              
         } // for dataindex
         pos += KANALSETTINGBREITE
         data.append(kanalarray)
      
      }
   
       
      return data
   }
   
   func decodeTeensySettings(_ buffer:[UInt8], model:Int) 
   {
      let code = buffer[0]
      let hexcode = String(format: "%02X", code)
      print("decodeUSBSettings code: \(code) hex: \(hexcode)")
      var pos:Int = USB_DATA_OFFSET
      
      for kanal in 0..<8
      {
         //var kanalarray = [UInt8]()
         
         for dataindex in 0..<4
         {
            //print("pos: \(pos) dataindex: \(dataindex)")
            //kanalarray.append(buffer[pos + dataindex]) // status, level, expo, funktion
            teensysettingarray[model][kanal][dataindex] = buffer[pos + dataindex]
         } // for dataindex
         pos += KANALSETTINGBREITE
      
      }
      

   }

   func importCurrentTableData(_ kanaldata:[UInt8], kanal:Int, model: Int)// daten pro kanal
   {
      //let kanaldata:[UInt8] = indata[(kanal)]
      /*
       dispatchdic["dispatchnummer"] = dispatchindex
       dispatchdic["dispatchfunktion"] = (dispatchindex ) & 0x07 // ausgesuchte funktion
       dispatchdic["dispatchkanal"] = dispatchindex 
       dispatchdic["dispatchdevice"] = (dispatchindex ) & 0x07
       dispatchdic["dispatchgo"] = 1 // verwendet 
       dispatchdic["dispatchonimage"] = 1 //dispatchindex%2 // verwendet
       // von kanal
       dispatchdic["dispatchrichtung"] = 1
       dispatchdic["dispatchlevela"]  = dispatchindex & 0x03
       dispatchdic["dispatchlevelb"]  = 4-dispatchindex & 0x03
       dispatchdic["dispatchexpoa"]  = 4-dispatchindex & 0x03
       dispatchdic["dispatchexpob"]  = dispatchindex & 0x03
       dispatchdic["dispatchmix"]  = 1
       dispatchdic["dispatchmixkanal"]  = dispatchindex
       dispatchdic["dispatchmodelnummer"]  = model
       dispatchdic["dispatchmodel"]  = model

       */
      let dispatchkanal = UInt8(kanal)
    
      let dispatchonimage = (kanaldata[0] & 0x08) >> 3 // Bit 3
      let dispatchrichtung = (kanaldata[0] & 0x80) >> 7 // Bit 7
      let dispatchlevela = (kanaldata[1] & 0x07) 
      let dispatchlevelb = (kanaldata[1] & 0x70) >> 4 
      let dispatchexpoa = (kanaldata[2] & 0x07)
      let dispatchexpob = (kanaldata[2] & 0x70) >> 4 
      let dispatchdevice =  kanaldata[3] & 0x70  >> 4 
      let dispatchfunktion = (kanaldata[3] & 0x07)
      /*
      print("dispatchkanal: \(dispatchkanal)")
      print("dispatchonimage: \(dispatchonimage)")
      print("dispatchlevela: \(dispatchlevela)")
      print("dispatchlevelb: \(dispatchlevelb)")
      print("dispatchexpoa: \(dispatchexpoa)")
      print("dispatchexpob: \(dispatchexpob)")
      print("dispatchdevice: \(dispatchdevice)")
      print("dispatchfunktion: \(dispatchfunktion)")
      */
      DispatchArray[(model)][(kanal)]["dispatchkanal"]  = UInt8(kanal)
      DispatchArray[(model)][(kanal)]["dispatchonimage"]  = (kanaldata[0] & 0x08) >> 3 // Bit 3
      DispatchArray[(model)][(kanal)]["dispatchrichtung"]  = (kanaldata[0] & 0x80) >> 7 // Bit 7
      DispatchArray[(model)][(kanal)]["dispatchlevela"]  = (kanaldata[1] & 0x07) 
      DispatchArray[(model)][(kanal)]["dispatchlevelb"]  = (kanaldata[1] & 0x70) >> 4 
      DispatchArray[(model)][(kanal)]["dispatchexpoa"]  = (kanaldata[2] & 0x07) 
      DispatchArray[(model)][(kanal)]["dispatchexpob"]  = (kanaldata[2] & 0x70) >> 4 
      DispatchArray[(model)][(kanal)]["dispatchdevice"] = kanaldata[3] & 0x70 >> 4                     
      DispatchArray[(model)][(kanal)]["dispatchfunktion"]  = (kanaldata[3] & 0x07) >> 4
   
      DispatchTable.reloadData()
   }   
   
   func importMixingData(_ indata:[[UInt8]],  model: Int)// daten pro mixing 
   {
      print("importMixingData")
      for mixindex in 0..<4
      {
         let mixdata:[UInt8] = indata[(mixindex)]
         let mix0 = mixdata[0]
         let mix1 = mixdata[1]
         print("mixindex: \(mixindex) mix0: \(mix0)  mix1: \(mix1) ")
         
         /*
          uint8_t modelindex = mix0 & 0x03; // bit 0,1
          Serial.printf("modelindex: %d \n",modelindex);
          uint8_t mixart = (mix0 & 0x30) >> 4; // bit 4,5
          Serial.printf("mixart: %d \n",mixart);
          uint8_t mixnummer = (mix0 & 0xC0) >> 6; // bit 6,7
          Serial.printf("mixnummer: %d \n",mixnummer);
          uint8_t mixon = (mix0 & 0x08) >> 3; // Bit 3
          Serial.printf("mixon: %d \n",mixon);
          */
         let modelindex = mix0 & 0x03 // bit 0,1
         let mixart = (mix0 & 0x30) >> 4 // bit 4,5
         let mixnummer = (mix0 & 0xC0) >> 6 // bit 6,7
         let mixon = (mix0 & 0x08) >> 3 // Bit 3
         print("modelindex: \(modelindex) mixart: \(mixart)  mixnummer: \(mixnummer) mixon: \(mixon)")
         /*
          uint8_t mixkanala = mix1 & 0x07 ; // Bit 0-3
          Serial.printf("mixkanala: %d \n",mixkanala);
          uint8_t mixkanalb = (mix1 & 0x70) >> 4; // Bit 4-6
          Serial.printf("mixkanalb: %d \n", mixkanalb);
          */
         let mixkanala = mix1 & 0x07  // Bit 0-3
         let mixkanalb = (mix1 & 0x70) >> 4 // Bit 4-6
         print("mixkanala: \(mixkanala) mixkanalb: \(mixkanalb)   ")
         /*
          mixingdic["mixnummer"] = mixingindex
          mixingdic["mixonimage"] = 0
          mixingdic["mixart"] = 2
          mixingdic["mixkanala"] = 0x00
          mixingdic["mixkanalb"] = 0x01
          mixingdic["mixing"] = 0 // verwendet als Mix xy
          */
         MixingArray[model][mixindex]["mixnummer"] = UInt8(mixindex)
         MixingArray[model][mixindex]["mixonimage"] = mixon
         MixingArray[model][mixindex]["mixart"] = mixart
         MixingArray[model][mixindex]["mixkanala"] = mixkanala
         MixingArray[model][mixindex]["mixkanalb"] = mixkanalb
         
      }// for mixindex
      MixingTable.reloadData()
   }
   
   func importTableData(_ indata:[[UInt8]],  model: Int)// daten pro kanal
   {
      for kanalindex in 0..<8
      {
         let kanaldata:[UInt8] = indata[(kanalindex)]
         /*
          dispatchdic["dispatchnummer"] = dispatchindex
          dispatchdic["dispatchfunktion"] = (dispatchindex ) & 0x07 // ausgesuchte funktion
          dispatchdic["dispatchkanal"] = dispatchindex 
          dispatchdic["dispatchdevice"] = (dispatchindex ) & 0x07
          dispatchdic["dispatchgo"] = 1 // verwendet 
          dispatchdic["dispatchonimage"] = 1 //dispatchindex%2 // verwendet
          // von kanal
          dispatchdic["dispatchrichtung"] = 1
          dispatchdic["dispatchlevela"]  = dispatchindex & 0x03
          dispatchdic["dispatchlevelb"]  = 4-dispatchindex & 0x03
          dispatchdic["dispatchexpoa"]  = 4-dispatchindex & 0x03
          dispatchdic["dispatchexpob"]  = dispatchindex & 0x03
          dispatchdic["dispatchmix"]  = 1
          dispatchdic["dispatchmixkanal"]  = dispatchindex
          dispatchdic["dispatchmodelnummer"]  = model
          dispatchdic["dispatchmodel"]  = model
          
          */
         let dispatchkanal = UInt8(kanalindex)
         
         let dispatchonimage = (kanaldata[0] & 0x08) >> 3 // Bit 3
         let dispatchrichtung = (kanaldata[0] & 0x80) >> 7 // Bit 7
         let dispatchlevela = (kanaldata[1] & 0x07) 
         let dispatchlevelb = (kanaldata[1] & 0x70) >> 4 
         let dispatchexpoa = (kanaldata[2] & 0x07)
         let dispatchexpob = (kanaldata[2] & 0x70) >> 4 
         let dispatchdevice =  kanaldata[3] & 0x70  >> 4 
         let dispatchfunktion = (kanaldata[3] & 0x07)
         /*
         print("dispatchkanal: \(dispatchkanal)")
         print("dispatchonimage: \(dispatchonimage)")
         print("dispatchlevela: \(dispatchlevela)")
         print("dispatchlevelb: \(dispatchlevelb)")
         print("dispatchexpoa: \(dispatchexpoa)")
         print("dispatchexpob: \(dispatchexpob)")
         print("dispatchdevice: \(dispatchdevice)")
         print("dispatchfunktion: \(dispatchfunktion)")
         */
         DispatchArray[(model)][(kanalindex)]["dispatchkanal"]  = UInt8(kanalindex)
         DispatchArray[(model)][(kanalindex)]["dispatchonimage"]  = (kanaldata[0] & 0x08) >> 3 // Bit 3
         DispatchArray[(model)][(kanalindex)]["dispatchrichtung"]  = (kanaldata[0] & 0x80) >> 7 // Bit 7
         DispatchArray[(model)][(kanalindex)]["dispatchlevela"]  = (kanaldata[1] & 0x07) 
         DispatchArray[(model)][(kanalindex)]["dispatchlevelb"]  = (kanaldata[1] & 0x70) >> 4 
         DispatchArray[(model)][(kanalindex)]["dispatchexpoa"]  = (kanaldata[2] & 0x07) 
         DispatchArray[(model)][(kanalindex)]["dispatchexpob"]  = (kanaldata[2] & 0x70) >> 4 
         DispatchArray[(model)][(kanalindex)]["dispatchdevice"] = kanaldata[3] & 0x70 >> 4                     
         DispatchArray[(model)][(kanalindex)]["dispatchfunktion"]  = (kanaldata[3] & 0x07) 
      }
      DispatchTable.reloadData()
      
      for mixindex in 0..<4
      {
         
      }// mixindex
   }
   
   
   
   
   func importCurrentTableData(_ indata:[[UInt8]], kanal:Int, model: Int)// daten pro kanal
   {
      let kanaldata:[UInt8] = indata[(kanal)]
      /*
       dispatchdic["dispatchnummer"] = dispatchindex
       dispatchdic["dispatchfunktion"] = (dispatchindex ) & 0x07 // ausgesuchte funktion
       dispatchdic["dispatchkanal"] = dispatchindex 
       dispatchdic["dispatchdevice"] = (dispatchindex ) & 0x07
       dispatchdic["dispatchgo"] = 1 // verwendet 
       dispatchdic["dispatchonimage"] = 1 //dispatchindex%2 // verwendet
       // von kanal
       dispatchdic["dispatchrichtung"] = 1
       dispatchdic["dispatchlevela"]  = dispatchindex & 0x03
       dispatchdic["dispatchlevelb"]  = 4-dispatchindex & 0x03
       dispatchdic["dispatchexpoa"]  = 4-dispatchindex & 0x03
       dispatchdic["dispatchexpob"]  = dispatchindex & 0x03
       dispatchdic["dispatchmix"]  = 1
       dispatchdic["dispatchmixkanal"]  = dispatchindex
       dispatchdic["dispatchmodelnummer"]  = model
       dispatchdic["dispatchmodel"]  = model

       */
      let dispatchkanal = UInt8(kanal)
    
      let dispatchonimage = (kanaldata[0] & 0x08) >> 3 // Bit 3
      let dispatchrichtung = (kanaldata[0] & 0x80) >> 7 // Bit 7
      let dispatchlevela = (kanaldata[1] & 0x07) 
      let dispatchlevelb = (kanaldata[1] & 0x70) >> 4 
      let dispatchexpoa = (kanaldata[2] & 0x07)
      let dispatchexpob = (kanaldata[2] & 0x70) >> 4 
      let dispatchdevice =  kanaldata[3] & 0x70  >> 4 
      let dispatchfunktion = (kanaldata[3] & 0x07)
      
      /*
      print("dispatchkanal: \(dispatchkanal)")
      print("dispatchonimage: \(dispatchonimage)")
      print("dispatchlevela: \(dispatchlevela)")
      print("dispatchlevelb: \(dispatchlevelb)")
      print("dispatchexpoa: \(dispatchexpoa)")
      print("dispatchexpob: \(dispatchexpob)")
      print("dispatchdevice: \(dispatchdevice)")
      print("dispatchfunktion: \(dispatchfunktion)")
      */
      DispatchArray[(model)][(kanal)]["dispatchkanal"]  = UInt8(kanal)
      DispatchArray[(model)][(kanal)]["dispatchonimage"]  = (kanaldata[0] & 0x08) >> 3 // Bit 3
      DispatchArray[(model)][(kanal)]["dispatchrichtung"]  = (kanaldata[0] & 0x80) >> 7 // Bit 7
      DispatchArray[(model)][(kanal)]["dispatchlevela"]  = (kanaldata[1] & 0x07) 
      DispatchArray[(model)][(kanal)]["dispatchlevelb"]  = (kanaldata[1] & 0x70) >> 4 
      DispatchArray[(model)][(kanal)]["dispatchexpoa"]  = (kanaldata[2] & 0x07) 
      DispatchArray[(model)][(kanal)]["dispatchexpob"]  = (kanaldata[2] & 0x70) >> 4 
      DispatchArray[(model)][(kanal)]["dispatchdevice"] = kanaldata[3] & 0x70 >> 4                     
      DispatchArray[(model)][(kanal)]["dispatchfunktion"]  = (kanaldata[3] & 0x07) 
   
      DispatchTable.reloadData()
   }
   
   func decodeUSBSettings(_ buffer:[UInt8]) -> [String:[UInt8]] // dictionary aus USB
   {
      var data =  [String:[UInt8]]()
()
      let code = buffer[0]
      let hexcode = String(format: "%02X", code)
      print("decodeUSBSettings code: \(code) hex: \(hexcode)")
      var pos:Int = USB_DATA_OFFSET
      var statusarray = [UInt8]()
      // status
      for kanal in 0..<8
      {
         statusarray.append(buffer[pos + kanal])
      }//status
      data["status"] = statusarray
      
      // level
      pos += 8
      var levelarray = [UInt8]()
      for kanal in 0..<8
      {
         levelarray.append(buffer[pos + kanal])
      }//level
      data["level"] = levelarray 

      // expo
      pos += 8
      var expoarray = [UInt8]()
      for kanal in 0..<8
      {
         expoarray.append(buffer[pos + kanal])
      }//expo
      data["expo"] = expoarray 
      
      // funktion & device
      pos += 8
      var funktionarray = [UInt8]()
      for kanal in 0..<8
      {
         funktionarray.append(buffer[pos + kanal])
      }//expo
      data["funktion"] = funktionarray 
      
      
      return data                           
   }
   
   @IBAction func report_sendSettingChannels(_ sender: NSButton)  // USB-Daten von aktuellem modell
  {
     let mixingarray = readSettingMixingArray() //  [[uint8]]
     //print("report_sendSettings mixingarray: \(mixingarray)")
 
     print("report_sendSettingChannels start")
     let kanaldataarray = readSettingKanalArray() // [[uint8]]
     teensy.write_byteArray[0] = 0xF4
     //for modelindex in 0..<ANZAHLMODELLE
     
     for modelindex in 0..<1 // teensy.write_byteArray fuer ein Model aufbauen
     {
        var pos:Int = 0
        let modeldataarray = kanaldataarray[modelindex]
        /*
         pro model
         32 bytes
         > 4 bytes pro kanal
            status   (model, ON, Kanal, RI)
            level    (levela, levelb)
            expo     (expoa, expob)
            device   /(fkt, device)
         */
        for kanal in 0..<8
        {
           for dataindex in 0..<4
           {
              // daten pro kanal hintereinander: status, level, expo, device
              teensy.write_byteArray[USB_DATA_OFFSET + pos + dataindex] = modeldataarray[kanal][dataindex]
           }
            pos += KANALSETTINGBREITE
                
           //print("status kanal: \(kanal) tempbuffer: \(tempbuffer)")
           
        }// for kanal
        //print("model: \(modelindex) pos: \(pos)  sendbuffer vor: \(teensy.write_byteArray)")
        
        //print("model: \(modelindex) MixingArray: \(MixingArray) ")
        // mixing anfuegen: 2 bytes pro model
        
        let mixpos = USB_DATA_OFFSET + (8 * KANALSETTINGBREITE)  // aktelle position in write_byteArray
        
        for mixindex in 0..<3 // 4 * 2 bytes
        {
        teensy.write_byteArray[ mixpos + 2*mixindex] = mixingarray[modelindex][mixindex][0] // byte 0
        teensy.write_byteArray[ mixpos + 2*mixindex + 1] = mixingarray[modelindex][mixindex][1] // byte 1
        }
   
       let controlarrayy = decodeUSBChannelSettings(teensy.write_byteArray, model:0)
       
        print("model: \(modelindex) sendbuffer nach: \(teensy.write_byteArray)") // 32 bytes kanal, 8 bytes mixing
        if (usbstatus > 0)
        {
           let senderfolg = teensy.send_USB()
           usbcounter += 1
           print("model: \(modelindex) usbcounter: \(usbcounter) report_sendSettingChannels senderfolg: \(senderfolg)")
        }
        
      if self.teensy.readtimervalid() == true
      {
         print("PCB readtimer valid vor")
      }
      else 
      {
         print("PCB readtimer not valid bevor")
         self.teensy.start_read_USB(true)
      }

        

     }//model
  
  }// report_sendSettingChannels
   
   @IBAction func report_saveSettings(_ sender: NSButton) 
  {
     
     print("report_saveSettings ")

  }
   
   @IBAction func report_loadSettings(_ sender: NSButton) 
  {
     
     print("report_loadSettings ")

  }

   
   @IBAction func report_sendSettings(_ sender: NSButton) 
  {
     
     print("report_sendSettings ")
     let kanaldataarray = readSettingKanalArray()
     
      
     sendbuffer[0] = 0xF4
     var pos = 0
     for modelindex in 0..<ANZAHLMODELLE
     {
        pos = USB_DATA_OFFSET + modelindex * KANALSETTINGBREITE
        // status
        for kanal in 0..<8
        {
           var tempbuffer = UInt8(modelindex)
           if (DispatchArray[modelindex][kanal]["dispatchonimage"] == 1)
           {
              tempbuffer |= 1<<3 // ON
           }

           //tempbuffer |= ((DispatchArray[modelindex][kanal]["kanal"] ?? 0) & 0x07) << 4
           tempbuffer |=  (UInt8(kanal) & 0x07)<<4
           
           if (DispatchArray[modelindex][kanal]["dispatchrichtung"] == 1)
           {
              tempbuffer |= 1<<7 // richtung
           }

           var temp = 0
           
           sendbuffer[pos + kanal] = tempbuffer
           print("status kanal: \(kanal) tempbuffer: \(tempbuffer)")
           
        }
         // level
        print("level")
        pos += 8
        for kanal in 0..<8
        {
           var tempbuffer:UInt8 = 0
           tempbuffer |= (DispatchArray[modelindex][kanal]["dispatchlevela"] ?? 0) & 0x07
           tempbuffer |= ((DispatchArray[modelindex][kanal]["dispatchlevelb"] ?? 0) & 0x07) << 4
           sendbuffer[pos + kanal] = tempbuffer
           print("level kanal: \(kanal) tempbuffer: \(tempbuffer)")
        }// level
        
        print("expo")
        pos += 8
        for kanal in 0..<8
        {
           var tempbuffer:UInt8 = 0
           tempbuffer |= (DispatchArray[modelindex][kanal]["dispatchexpoa"] ?? 0) & 0x07
           tempbuffer |= ((DispatchArray[modelindex][kanal]["dispatchexpob"] ?? 0) & 0x07) << 4
           sendbuffer[pos + kanal] = tempbuffer
           print("expo kanal: \(kanal) tempbuffer: \(tempbuffer)")
        }// level
        
        // funktion & device
        print("funktion & device")
        pos += 8
        for kanal in 0..<8
        {
           var tempbuffer:UInt8 = 0
           tempbuffer |= (DispatchArray[modelindex][kanal]["dispatchfunktion"] ?? 0) & 0x07
           tempbuffer |= ((DispatchArray[modelindex][kanal]["dispatchdevice"] ?? 0) & 0x07) << 4
           sendbuffer[pos + kanal] = tempbuffer
           print("funktion&device kanal: \(kanal) tempbuffer: \(tempbuffer)")
        }// level
        
        
        
      
    //    let a = decodeUSBSettings(sendbuffer)
        if (usbstatus > 0)
        {
           let senderfolg = teensy.send_USB()
           print("report_sendSettings senderfolg: \(senderfolg)")
        }

        
        
     }// for mod
     
     
  }
   
   @IBAction func report_getTeensySettings(_ sender: NSButton)
   {
      print("report_sendTeensySettings ")
      /*
      let alert = NSAlert()
      alert.messageText = "get TeensySettings"
      alert.informativeText = "Welcher Kanal"
      alert.alertStyle = .warning
      alert.addButton(withTitle: "Current")
      alert.addButton(withTitle: "Kanalfeld")
      alert.addButton(withTitle: "Alle")
      alert.addButton(withTitle: "OK")
     alert.addButton(withTitle: "Cancel")
      let antwort =  alert.runModal() //== .alertFirstButtonReturn
*/
      
      var teensykanal:UInt8 = 0
      var teensymodel:UInt8 = 0
      
      teensy.write_byteArray[0] = 0xF6
      teensy.write_byteArray[USB_DATA_OFFSET] = teensymodel | (teensykanal>>4)
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         print("report_sendTeensySettings senderfolg: \(senderfolg)")
      }
      if self.teensy.readtimervalid() == true
      {
         print("PCB readtimer valid vor")
      }
      else 
      {
         print("PCB readtimer not valid bevor")
         self.teensy.start_read_USB(true)
      }


   }
   

func readSettingKanalArray() -> [[[UInt8]]] // Array aus Dispatcharray: modell> Kanal> device
   {
      print("readSettingKanalArray ")
      sendbuffer[0] = 0xF4
      var data = [[[UInt8]]]()
      //var pos = 0
      for modelindex in 0..<ANZAHLMODELLE
      {
         //pos = USB_DATA_OFFSET + modelindex * KANALSETTINGBREITE
         var modeldata = [[UInt8]]()
         for kanal in 0..<8
         {
            var kanaldata = [UInt8]()
            // status
            var tempbuffer = UInt8(modelindex)
            if (DispatchArray[modelindex][kanal]["dispatchonimage"] == 1)
            {
               tempbuffer |= 1<<3 // ON
            }

            //tempbuffer |= ((DispatchArray[modelindex][kanal]["kanal"] ?? 0) & 0x07) << 4
            tempbuffer |=  (UInt8(kanal) & 0x07)<<4
            
            if (DispatchArray[modelindex][kanal]["dispatchrichtung"] == 1)
            {
               tempbuffer |= 1<<7 // richtung
            }
            kanaldata.append(tempbuffer)
            
            // level
            tempbuffer = 0
            tempbuffer |= (DispatchArray[modelindex][kanal]["dispatchlevela"] ?? 0) & 0x07
            tempbuffer |= ((DispatchArray[modelindex][kanal]["dispatchlevelb"] ?? 0) & 0x07) << 4
            kanaldata.append(tempbuffer)
            
            // expo
            tempbuffer = 0
            tempbuffer |= (DispatchArray[modelindex][kanal]["dispatchexpoa"] ?? 0) & 0x07
            tempbuffer |= ((DispatchArray[modelindex][kanal]["dispatchexpob"] ?? 0) & 0x07) << 4
            kanaldata.append(tempbuffer)
            
            // funktion & device
            tempbuffer = 0
            tempbuffer |= (DispatchArray[modelindex][kanal]["dispatchfunktion"] ?? 0) & 0x07
            tempbuffer |= ((DispatchArray[modelindex][kanal]["dispatchdevice"] ?? 0) & 0x07) << 4
            kanaldata.append(tempbuffer)
           
            
            

            modeldata.append(kanaldata)
         } // for kanal
         data.append(modeldata)
      }// for modell
      return data
   }
   
   func readSettingMixingArray() -> [[[UInt8]]] // Array aus MixingArray, 2 bytes pro mix
   {
      /*
       mixingdic["mixnummer"] = mixingindex
       mixingdic["mixonimage"] = 0
       mixingdic["mixart"] = 2
       mixingdic["mixkanala"] = 0x00
       mixingdic["mixkanalb"] = 0x01
       mixingdic["mixing"] = 0 // verwendet als Mix xy

       */
      var data = [[[UInt8]]]()
      //var pos = 0
      for modelindex in 0..<ANZAHLMODELLE
      {
         var modeldata = [[UInt8]]() // 4 mixings pro model, je 2 bytes
         for mixingindex in 0..<4
         {
            var kanaldata = [UInt8]() // 2 bytes: mixstatus, mixkanal
            var tempbuffer = UInt8(modelindex) // Modellnummer, bit 0-2
            if (MixingArray[modelindex][mixingindex]["mixonimage"] == 1)
            {
               tempbuffer |= 1<<3 // ON
            }
            let mixart = MixingArray[modelindex][mixingindex]["mixart"] ?? 0
            tempbuffer |=  (UInt8(mixart) & 0x03) << 4
            let mixnummer = MixingArray[modelindex][mixingindex]["mixnummer"] ?? 0
            tempbuffer |= (UInt8(mixnummer) & 0x03) << 6
            
            kanaldata.append(tempbuffer)
            tempbuffer = 0
            
            let mixkanala = MixingArray[modelindex][mixingindex]["mixkanala"] ?? 0
            tempbuffer = UInt8(mixkanala)
            let mixkanalb = MixingArray[modelindex][mixingindex]["mixkanalb"] ?? 0
            tempbuffer |= (UInt8(mixkanalb) << 4)
            kanaldata.append(tempbuffer)
            
            modeldata.append(kanaldata)
         } // for mixingindex
         data.append(modeldata)
      } // for modelindex
      return data
   } // readSettingMixingArray
   
   
 
   var     default_DeviceArray:[String] = ["Pitch_L_H","Pitch_L_V","Pitch_R_H","Pitch_R_V","Schieber_L","Schieber_R","Schalter","leer"]
   var     default_FunktionArray:[String] = ["Seite","Hoehe","Quer","Motor","Quer L","Quer R","Lande","Aux"]
   var     default_KanalArray:[String] = ["0","1","2","3","4","5","6","7"]

   var default_ArtArray = ["Stick","Schieber","Schalter","--"]
   var default_LevelArray = ["1/1","7/8","3/4","5/8","1/2"]
   var default_ExpoArray = ["1/1","7/8","3/4","5/8","1/2"]
 
   var default_RichtungArray:[[NSImage]] = [[NSImage]]()//[pfeilup pfeildown], [pfeillinks pfeilrechts]
   
   var default_ONArray:[NSImage] = [NSImage]()//[okimage, notokimage]
   
   var default_MixingArtArray = ["--","V-Mix","Butterfly"]
   
   @objc func usbstatusAktion(_ notification:Notification) 
  {
     let info = notification.userInfo
     let status = info?["usbstatus"]  // 
     print("Trigo usbstatusAktion:\t \(status) ")
     usbstatus = status as! Int
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
         print("case 5 Mixing kolonne: \(kolonne)")
         /*
          let mixingcolumnnummer = 0
          let mixingcolumnart = 1
          let mixingcolumnkanala = 2
          let mixingcolumnkanalb = 3
          let mixingcolumnon = 4

          */
         switch kolonne
         {
         case mixingcolumnon:
            let onwert = UInt8(MixingArray[0][zeile]["mixonimage"] ?? 0)
            
            MixingArray[0][zeile]["mixonimage"]  = 1 - onwert
            MixingTable.reloadData()
            print("mixonimage")
 
         case mixingcolumnart:
            MixingArray[0][zeile]["mixart"]  = UInt8(itemindex)
            MixingTable.reloadData()
            print("mixart")
           
            
         case mixingcolumnkanala:
            MixingArray[0][zeile]["mixkanala"]  = UInt8(itemindex)
            MixingTable.reloadData()
            print("mixkanala")
            
         case mixingcolumnkanalb:
            MixingArray[0][zeile]["mixkanalb"]  = UInt8(itemindex)
            MixingTable.reloadData()
            print("mixkanalb")  
         default: break
         }// switch
         
         break
         
      case 6: // Dispatch
         print("case 6 dispatch kolonne: \(kolonne)")
         switch kolonne
         {
         case columnfunktion: // funktion
            DispatchArray[0][zeile]["dispatchfunktion"]  = UInt8(itemindex)
            DispatchTable.reloadData()
            print("dispatchfunktion")
            
         case columndevice: // device(Steuerelement)
            DispatchArray[0][zeile]["dispatchdevice"]  = UInt8(itemindex)
            DispatchTable.reloadData()
            print("dispatchdevice")
            
         case columnon: // onimage
            let onwert = UInt8(DispatchArray[0][zeile]["dispatchonimage"] ?? 0)
            
            DispatchArray[0][zeile]["dispatchonimage"]  = 1 - onwert
            DispatchTable.reloadData()
            print("dispatchonimage")
            
         case columnlevela:
            DispatchArray[0][zeile]["dispatchlevela"]  = UInt8(itemindex)
            DispatchTable.reloadData()
            print("dispatchlevela")
            
         case columnlevelb:
            DispatchArray[0][zeile]["dispatchlevelb"]  = UInt8(itemindex)
            DispatchTable.reloadData()
            print("dispatchlevelb")
            
         case columnexpoa:
            DispatchArray[0][zeile]["dispatchexpoa"]  = UInt8(itemindex)
            DispatchTable.reloadData()
            print("columnexpoa")
            
         case columnexpob:
            DispatchArray[0][zeile]["dispatchexpob"]  = UInt8(itemindex)
            DispatchTable.reloadData()
            print("columnexpob")
            
         case columnrichtung:
            let richtungwert = UInt8(DispatchArray[0][zeile]["dispatchrichtung"] ?? 0)
            
            DispatchArray[0][zeile]["dispatchrichtung"]  = 1-richtungwert
            DispatchTable.reloadData()
            print("columnrichtung")
            
            
         default: break
         }// switch kolonne
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
   
   @IBAction func report_TableView(_ sender: NSTableView)
   {
      print("reportTableView clicked: \(DispatchTable.clickedRow) \(DispatchTable.clickedColumn)")
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
         if (kolonne == columnon) // ON
         {
            let wert = UInt8(DispatchArray[0][zeile]["dispatchonimage"] ?? 0 )
            DispatchArray[0][zeile]["dispatchonimage"]  = 1 - wert
            tableView.reloadData()
            tableView.deselectRow(kolonne)
         }
         if (kolonne == columnrichtung)
         {
            let wert = UInt8(DispatchArray[0][zeile]["dispatchrichtung"] ?? 0 )
            DispatchArray[0][zeile]["dispatchrichtung"]  = 1 - wert
            tableView.reloadData()
            tableView.deselectRow(kolonne)
         }
      case "mixing":
         print("*********  ******  table mixing clicked  zeile: \(zeile)")
         clickedmixingarrayrow = Int(zeile)
         if (kolonne == mixingcolumnon) // ON
         {
            
            let wert = UInt8(MixingArray[0][zeile]["mixonimage"] ?? 0 )
            MixingArray[0][zeile]["mixonimage"]  = 1 - wert
            tableView.reloadData()
            tableView.deselectRow(kolonne)
         }

      default:
         break
      }
   }

   @IBAction private func report_mixingtableRowWasClicked(_ tableView: NSTableView)
   {
      // https://stackoverflow.com/questions/18560509/nstableview-detecting-a-mouse-click-together-with-the-row-and-column
      let identstring = tableView.identifier?.rawValue ?? "x"
      let ident = NSUserInterfaceItemIdentifier(tableView.identifier?.rawValue ?? "x")
      let zeile = (tableView.clickedRow)
      let kolonne = tableView.clickedColumn
      
      print("*** report_mixingtableRowWasClicked row \(zeile), col \(kolonne) ident: \(ident)")
      switch identstring
      {
      case "dispatch":
         print("*********  ******  table dispatch clicked  zeile: \(zeile)")
         clickeddispacharrayrow = Int(zeile)
         if (kolonne == columnon) // ON
         {
            let wert = UInt8(DispatchArray[0][zeile]["dispatchonimage"] ?? 0 )
            DispatchArray[0][zeile]["dispatchonimage"]  = 1 - wert
            tableView.reloadData()
            tableView.deselectRow(kolonne)
         }
         if (kolonne == columnrichtung)
         {
            let wert = UInt8(DispatchArray[0][zeile]["dispatchrichtung"] ?? 0 )
            DispatchArray[0][zeile]["dispatchrichtung"]  = 1 - wert
            tableView.reloadData()
            tableView.deselectRow(kolonne)
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
         let popident = NSUserInterfaceItemIdentifier(rawValue:"levelpopupa")
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
         let popident = NSUserInterfaceItemIdentifier(rawValue:"levelpopupb")
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
      else  if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"dispatchexpoa") )
      {
         let popident = NSUserInterfaceItemIdentifier(rawValue:"expopopupa")
         guard let result = tableView.makeView(withIdentifier: popident, owner: self) as? rPopUpZelle else 
         {
            print("dispatchexpoa ist nil")
            return nil 
         }
         var wert = Int(DispatchArray[0][row]["dispatchexpoa"] ?? 0)
         if wert > default_ExpoArray.count - 1
         {
            wert = 4
         }
         result.poptag = row
         result.tablezeile = row
         result.tablekolonne = tableView.column(for: result)
         result.PopUp?.removeAllItems()
         result.PopUp?.addItems(withTitles: default_ExpoArray)
         result.PopUp?.selectItem(at: wert)
         return result

         }
      
      else  if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"dispatchexpob") )
      {
         let popident = NSUserInterfaceItemIdentifier(rawValue:"expopopupb")
         guard let result = tableView.makeView(withIdentifier: popident, owner: self) as? rPopUpZelle else 
         {
            print("dispatchexpob ist nil")
            return nil 
         }
         var wert = Int(DispatchArray[0][row]["dispatchexpob"] ?? 0)
         if wert > default_ExpoArray.count - 1
         {
            wert = 4
         }
         result.poptag = row
         result.tablezeile = row
         result.tablekolonne = tableView.column(for: result)
         result.PopUp?.removeAllItems()
         result.PopUp?.addItems(withTitles: default_ExpoArray)
         result.PopUp?.selectItem(at: wert)
         return result

         }
   
      
   
      else  if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"dispatchkanal") )
      {
         guard let result = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else 
         {
            print("dispatkanal ist nil")
            return nil 
            
         }

         //let result = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "dispatchnummer") , owner: self) as? NSTableCellView
         let nummer = Int(DispatchArray[0][row]["dispatchkanal"] ?? 0)
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
         let onident = NSUserInterfaceItemIdentifier(rawValue:"onimagebutton")
         guard let result = tableView.makeView(withIdentifier: onident, owner: self) as? rPopUpZelle else 
         {
            print("richtungident ist nil")
            return nil 
         }
         var wert = Int(DispatchArray[0][row]["dispatchonimage"] ?? 0)
         result.poptag = row
         result.tablezeile = row
         result.ImageButton?.image = default_ONArray[wert]
         //print("dispatchnummer onimage: \(wert)")
         //https://stackoverflow.com/questions/37100846/osx-swift-add-image-into-nstableview
         // Image muss mit TableCellView verlinkt sein!!! S. Screenshot TableView Image
         return result

      } // onimage
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
      
      else  if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"dispatchrichtung") )
      {
         let richtungident = NSUserInterfaceItemIdentifier(rawValue:"richtungimage")
         guard let result = tableView.makeView(withIdentifier: richtungident, owner: self) as? rPopUpZelle else 
         {
            print("richtungident ist nil")
            return nil 
         }
         var wert = Int(DispatchArray[0][row]["dispatchrichtung"] ?? 0)
 
         result.poptag = row
         result.tablezeile = row
         //result.tablekolonne = tableView.column(for: result)
         var pfeilrichtung = 0
         // index von funktion checken
         let funktionindex = Int(DispatchArray[0][row]["dispatchfunktion"] ?? 0)
         if funktionindex == 1 // Hoehe
         {
            pfeilrichtung = 1
         }

         result.ImageButton?.image = default_RichtungArray[pfeilrichtung][wert]
          return result
      }//dispatchrichtung

      // MARK: Level A
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
         //print("kanal on row: \(row) wert: \(wert)")
         //https://stackoverflow.com/questions/37100846/osx-swift-add-image-into-nstableview
         let bild:NSImage = default_ONArray[wert]
         result.imageView?.image = default_ONArray[wert]
         
         return result

      } // onimage

      // MARK: Mixing     
      // Mixing
      
      if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"mixnummer") )
      {
         guard let result = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else 
         {
            print("mixingnummer ist nil")
            return nil 
            
         }
         let wert = Int(MixingArray[0][row]["mixnummer"] ?? 0)
         //print("kanalnummer wert: \(wert)")
         result.textField?.integerValue = wert
         return result
      } // kanalnummer

      else  if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"mixonimage") )
      {
         
         guard let result = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else 
         {
            print("mixonimage ist nil")
            return nil 
         }
         print("mixonimage ist ok")
         let nummer = Int(MixingArray[0][row]["mixonimage"] ?? 0)
         let wert:Int = nummer
         print("mixing on row: \(row) wert: \(wert)")
         //https://stackoverflow.com/questions/37100846/osx-swift-add-image-into-nstableview
         let bild:NSImage = default_ONArray[wert]
         result.imageView?.image = default_ONArray[wert]
         
         return result

      } // onimage

      else  if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"mixzeileonimage") )
      {
         let imageident = NSUserInterfaceItemIdentifier(rawValue:"mixzeileimage")
         guard let result = tableView.makeView(withIdentifier: imageident, owner: self) as? rPopUpZelle else 
         {
            print("mixzeileonimage ist nil")
            return nil 
         }
         //print("mixzeileonimage ist ok")
         let nummer = Int(MixingArray[0][row]["mixonimage"] ?? 0)
         let wert:Int = nummer
         print("mixzeile  on row: \(row) wert: \(wert)")
         //https://stackoverflow.com/questions/37100846/osx-swift-add-image-into-nstableview
         let bild:NSImage = default_ONArray[wert]
         //result.imageView?.image = default_ONArray[wert]
         result.ImageButton?.image = default_ONArray[wert]
         
         return result

      } // onimage

      
      
      // mixkanala
      else  if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"mixkanala") )
      {
         let popident = NSUserInterfaceItemIdentifier(rawValue:"mixkanalapopup")
         guard let result = tableView.makeView(withIdentifier: popident, owner: self) as? rPopUpZelle else 
         {
            print("mixkanalapopup ist nil")
            return nil 
         }
         var wert = Int(MixingArray[0][row]["mixkanala"] ?? 0)
         if wert > default_KanalArray.count - 1
         {
            wert = 7
         }
         result.poptag = row
         result.tablezeile = row
         result.tablekolonne = tableView.column(for: result)
         result.PopUp?.removeAllItems()
         result.PopUp?.addItems(withTitles: default_KanalArray)
         result.PopUp?.selectItem(at: wert)
         return result

         }
      // mixkanalb
      else  if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"mixkanalb") )
      {
         let popident = NSUserInterfaceItemIdentifier(rawValue:"mixkanalbpopup")
         guard let result = tableView.makeView(withIdentifier: popident, owner: self) as? rPopUpZelle else 
         {
            print("mixkanalbpopup ist nil")
            return nil 
         }
         var wert = Int(MixingArray[0][row]["mixkanalb"] ?? 0)
         if wert > default_KanalArray.count - 1
         {
            wert = 7
         }
         result.poptag = row
         result.tablezeile = row
         result.tablekolonne = tableView.column(for: result)
         result.PopUp?.removeAllItems()
         result.PopUp?.addItems(withTitles: default_KanalArray)
         result.PopUp?.selectItem(at: wert)
         return result

         }  
      
      else  if (tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue:"mixart") )
      {
         let popident = NSUserInterfaceItemIdentifier(rawValue:"mixartpopup")
         guard let result = tableView.makeView(withIdentifier: popident, owner: self) as? rPopUpZelle else 
         {
            print("mixartpopup ist nil")
            return nil 
         }
         var wert = Int(MixingArray[0][row]["mixart"] ?? 0)
         if wert > default_MixingArtArray.count - 1
         {
            wert = 7
         }
         result.poptag = row
         result.tablezeile = row
         result.tablekolonne = tableView.column(for: result)
         result.PopUp?.removeAllItems()
         result.PopUp?.addItems(withTitles: default_MixingArtArray)
         result.PopUp?.selectItem(at: wert)
         return result

         }  
      
 
      
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
      default:
         break
      }
    
     
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
   var            buffer = [UInt8](repeating: 0,count: USB_DATENBREITE)
   var            sendbuffer = [UInt8](repeating: 0,count: USB_DATENBREITE)

   var            outbuffer = [UInt8](repeating: 0,count: USB_DATENBREITE)

   var            inbuffer = [UInt8](repeating: 0,count: USB_DATENBREITE)
   
 
   
   
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
   
   
   var            clickedmixingarrayrow:Int = -1 // angeklickte Zeile in MixTable
   
   var data: [[String: String]] = [[:]]
   
   
    
// MARK: outlets
   // @IBOutlet weak var Pot1_Feld_raw: NSTextField!
   @IBOutlet  weak var     dumpTable: NSTableView!
  
   @IBOutlet   weak var          logTable:NSTableView!
   @IBOutlet   weak var          window:NSWindow!
   @IBOutlet   weak var          macroPopup:NSPopUpButton!
   @IBOutlet   weak var          readButton:NSButton!
   
   @IBOutlet   weak var          sendSettingsButton:NSButton!
   

   @IBOutlet      weak var       modelFeld:NSTextField! 
   
   @IBOutlet      weak var        AdressPop:NSPopUpButton!
   @IBOutlet        weak var      modelSeg:NSSegmentedControl!
   
   
  @IBOutlet        weak var          readUSB:NSButton!
   @IBOutlet        weak var          sendSettingsTaste:NSButton!
  
   
   
   
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

   @IBOutlet   weak var             Halt_Taste:NSButton!
   
   @IBOutlet   weak var             saveSettings_Taste:NSButton!
   @IBOutlet   weak var             loadSettings_Taste:NSButton!

   @IBOutlet  weak var              Write_1_Byte_Taste:NSButton!
   @IBOutlet weak var               Read_1_Byte_Taste:NSButton!
   @IBOutlet weak var               Write_Part_Taste:NSButton!
   @IBOutlet weak var               Read_Part_Taste:NSButton!
   
   @IBOutlet weak var               StufeFeld:NSTextField!
   @IBOutlet weak var               PartnummerFeld:NSTextField!
   
   @IBOutlet weak var               PPMFeldA:NSTextField!
   @IBOutlet weak var               PPMFeldB:NSTextField!
   
  // @IBOutlet weak var   USB_OK_Feld:NSImageView!
   
   @IBOutlet      weak var     Taskwahl:NSTextField!
    @IBOutlet    weak var      EE_dataview:NSTextView!
   @IBOutlet    weak var     PPM_testdatafeld:NSTextField!
    

   @IBOutlet   weak var      SettingTab:NSTabView!
   
  

//   @IBOutlet      weak var   FunktionTable:NSTableView!
   @IBOutlet      weak var   MixingTable:NSTableView!
   @IBOutlet      weak var   DispatchTable:NSTableView!

   
   
   @IBOutlet   var      DataTable:NSTableView!
}// end class rRC

