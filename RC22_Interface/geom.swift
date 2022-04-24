//
//  geom.swift
//  Robot_Interface
//
//  Created by Ruedi Heimlicher on 15.08.2019.
//  Copyright © 2019 Ruedi Heimlicher. All rights reserved.
//

import Foundation
import Cocoa
import Darwin

/*
// center and radius of 1st circle
*                                double x0, double y0, double r0,
*                                // center and radius of 2nd circle
*                                double x1, double y1, double r1,
*                                // 1st intersection point
*                                double *xi, double *yi,              
*                                // 2nd intersection point
*                                double *xi_prime, double *yi_prime)
*/




open class geom: NSObject
{

   override init()
   {
      super.init()
   }

   open func armwinkel(absz0:Double, ord0:Double, rad0:Double, absz1:Double, ord1:Double, rad1:Double )->(Double,Double)
   {
      
      // Berechnung fuer 2-teiligen Arm. absz0, ord00: Koord Startpunkt, absz1, ord1: Endpunkte in Ebene des Arms
     
      // Gelenk des Arms
      // erster Schnittpunkt 
      var absz_s0:Double = 0 
      var ord_s0:Double = 0 

      // zweiter Schnittpunkt
      var absz_s1:Double = 0 
      var ord_s1:Double = 0 
      
      //kreispunkte()
      //var xx = kreispunkte()
      var result = circle_circle_intersection(absz0,ord0,rad0,absz1,ord1,rad1,&absz_s0, &ord_s0, &absz_s1, &ord_s1)
      if (result == 0)
      {
         return (0,0)
      }
      // Koord oberer Punkt:
      var xs:Double = absz_s0
      var ys:Double = ord_s0
      if (ord_s1 > ord_s0)
      {
         xs = absz_s1
         ys = ord_s1
         Swift.print("**** ord_s1 > ord_s0")
      }
      
      // Winkel:
      var phi0:Double = asin((xs-absz0)/rad0) * 180/Double.pi
      var phi10:Double = acos((ord1-ys)/rad1) * 180/Double.pi
      
      var phi11:Double = asin((absz1-xs )/rad1) * 180/Double.pi
      
 //     Swift.print("phi0: \(phi0) phi10: \(phi10)")
      
      //var phi1 = (90 - phi0) + phi10
      
      var phi1 = phi10 - phi0 // neu: Winkel 0 ist verlängerung des Arms0
      var phi12 =  (180 - phi0) - phi11
      
      return (phi0,phi12)
   }
   
} // class 
