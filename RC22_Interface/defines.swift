//
//  defines.swift
//  Robot_Interface
//
//  Created by Ruedi Heimlicher on 28.07.2019.
//  Copyright © 2019 Ruedi Heimlicher. All rights reserved.
//

import Foundation


let columnfunktion = 2
let columndevice = 1
let columnon = 3
let columnrichtung = 4
let columnlevela = 5
let columnlevelb = 6
let columnexpoa = 7
let columnexpob = 8

// mixing
let mixingcolumnnummer = 0
let mixingcolumnart = 1
let mixingcolumnkanala = 2
let mixingcolumnkanalb = 3
let mixingcolumnon = 4


let GOTO_0:UInt8  =  0xA7
let SET_RING:UInt8  =  0xA3
let CLEAR_RING:UInt8  =  0xA4
let END_RING: UInt8 = 0xA5

let SET_WEG:UInt8  =  0xA6
let CLEAR_WEG:UInt8  =  0xA7
let END_WEG:UInt8  =  0xA8

let DREHKNOPF:UInt8 = 0xAA

let ACHSE0_START:UInt16 = 0x7FF // Startwert low
let ACHSE0_MAX:UInt16 = 0xFFF // Startwert high
let FAKTOR0:Float = 1.6


let ACHSE1_START:UInt16 = 600 // Startwert low
let ACHSE1_MAX:UInt16 = 2100 // Startwert high
let FAKTOR1:Float = 1.6


let ACHSE2_START:UInt16 = 300 // Startwert low
let ACHSE2_MAX:UInt16 = 1800 // Startwert high
let FAKTOR2:Float = 1.6


let ACHSE3_START:UInt16 = 0x7FF // Startwert low
let ACHSE3_MAX:UInt16 = 0xFFF // Startwert high
let FAKTOR3:Float = 1.6

let DREHKNOPF_START:UInt16 = 0x7FF
let DREHKNOPF_FAKTOR:Float = 18.1 // Anpassen auf Mitte bei 3272


// Trigo
//let ACHSE1_MAX:Double = 1800
//let ACHSE1_START:Double = 600
//let ACHSE2_START:Double = 1800
//let ACHSE2_MAX:Double = 300


let funktion0:String = "Seite "
let funktion1:String = "Hoehe "
let funktion2:String = "Quer  "
let funktion3:String = "Motor "
let funktion4:String = "Quer L"
let funktion5:String = "Quer R"
let funktion6:String = "Lande "
let funktion7:String = "Aux   "
