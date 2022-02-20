//
//  r$Robotarm.swift
//  Robot_Interface
//
//  Created by Ruedi Heimlicher on 22.09.2019.
//  Copyright © 2019 Ruedi Heimlicher. All rights reserved.
//

import Cocoa
let rad2deg:Double = 180.0/Double.pi


class rRobotarm: NSView {
   var arm: NSBezierPath = NSBezierPath()
   var achsen: NSBezierPath = NSBezierPath()
   var waagrechtelinien: NSBezierPath = NSBezierPath()
   var senkrechtelinien: NSBezierPath = NSBezierPath()
   var rahmen: NSBezierPath = NSBezierPath()
   var startpunkt:NSPoint = NSPoint()
   var fixpunkt0:NSPoint = NSPoint()
   var fixpunkt1:NSPoint = NSPoint()
   var fixpunkt2:NSPoint = NSPoint()
   var fixpunkt3:NSPoint = NSPoint()
     
   required init?(coder  aDecoder : NSCoder) 
   {
      super.init(coder: aDecoder)
      //Swift.print("rRobotarmView init")
      //   NSColor.blue.set() // choose color
      // let achsen = NSBezierPath() // container for line(s)
      
      rahmen.appendRect(bounds)
      let w:CGFloat = bounds.size.width
      let h:CGFloat = bounds.size.height
      fixpunkt0 = NSMakePoint(bounds.origin.x + w/8, bounds.origin.y + h/4)
      arm.move(to: fixpunkt0)
      achsen.move(to: NSMakePoint(fixpunkt0.x,0))
      achsen.line(to:NSMakePoint(fixpunkt0.x,h))
      achsen.move(to: NSMakePoint(0,fixpunkt0.y))
      achsen.line(to:NSMakePoint(w,fixpunkt0.y))
      
      waagrechtelinienzeichnen(schritt:20)
      senkrechtelinienzeichnen(schritt:20)
      let d:CGFloat = 2.0
      let mitterect:NSRect = NSMakeRect(fixpunkt0.x-2, fixpunkt0.y-2, 2*d, 2*d)
      arm.appendOval(in: mitterect)
      
      
      arm.move(to: fixpunkt0)
      arm.relativeLine(to: NSMakePoint(fixpunkt0.x + 10, fixpunkt0.y + 10)) // destination
      //arm.relativeLine(to: NSMakePoint(arm.currentPoint.x + 20, arm.currentPoint.y - 10)) // destination
      
   }
   
   func waagrechtelinienzeichnen(schritt:Int)
   {
      let anzneg = Int(fixpunkt0.y / CGFloat(schritt))
      var y:CGFloat = CGFloat(schritt)
      for index in 1...anzneg
      {
         waagrechtelinien.move(to: NSMakePoint(0,fixpunkt0.y - y * CGFloat(index)))
         waagrechtelinien.line(to: NSMakePoint(bounds.size.width,fixpunkt0.y - y * CGFloat(index)))
      }
      let anzpos = Int(bounds.size.height - fixpunkt0.y / CGFloat(schritt))
      for index in 1...anzpos
      {
         waagrechtelinien.move(to: NSMakePoint(0,fixpunkt0.y + y * CGFloat(index)))
         waagrechtelinien.line(to: NSMakePoint(bounds.size.width,fixpunkt0.y + y * CGFloat(index)))
      }
   }
 
   func senkrechtelinienzeichnen(schritt:Int)
   {
      let anzneg = Int(fixpunkt0.x / CGFloat(schritt))
      var x:CGFloat = CGFloat(schritt)
      for index in 1...anzneg
      {
         senkrechtelinien.move(to: NSMakePoint(fixpunkt0.x - x * CGFloat(index),0))
         senkrechtelinien.line(to: NSMakePoint(fixpunkt0.x - x * CGFloat(index),bounds.size.height))
      }
      let anzpos = Int(bounds.size.height - fixpunkt0.y / CGFloat(schritt))
      for index in 1...anzpos
      {
         senkrechtelinien.move(to: NSMakePoint(fixpunkt0.x + x * CGFloat(index),0))
         senkrechtelinien.line(to: NSMakePoint(fixpunkt0.x + x * CGFloat(index),bounds.size.height))
      }
   }

   
   
   func setstartpunkt(punkt: NSPoint)
   {
      startpunkt.x = fixpunkt0.x + punkt.x
      startpunkt.y = fixpunkt0.y + punkt.y
   }
   
   func setkreis(punkt: NSPoint, radius: Float) ->NSBezierPath
   {
      let kreis:NSBezierPath = NSBezierPath()
      let r = CGFloat(radius)
      kreis.appendOval(in: NSMakeRect(punkt.x - r, punkt.y-r, 2*r, 2*r))
      return kreis
   }
   
   func setpath0(len: CGFloat, winkel: CGFloat)
   {  
      arm.removeAllPoints()
      arm.move(to: startpunkt)
      let d:CGFloat = 2.0
      let mitterect:NSRect = NSMakeRect(startpunkt.x-2, startpunkt.y-2, 2*d, 2*d)      
      arm.appendOval(in: mitterect)
      arm.move(to: startpunkt)

      let lenx:CGFloat = len * sin(winkel / CGFloat(rad2deg))
      let leny:CGFloat = len * cos(winkel / CGFloat(rad2deg))
      arm.relativeLine(to: NSMakePoint(lenx,leny))
      needsDisplay = true 
   }
   func setpath1(len: CGFloat, winkel: CGFloat)
   {  
      let d:CGFloat = 2.0
      let startpunkt1:NSPoint = arm.currentPoint
      let mitterect:NSRect = NSMakeRect(startpunkt1.x-2, startpunkt1.y-2, 2*d, 2*d)      

      arm.move(to: startpunkt1)
      arm.appendOval(in: mitterect)
      arm.move(to: startpunkt1)

      
      let lenx:CGFloat = len * sin(winkel / CGFloat(rad2deg))
      let leny = len * cos(winkel / CGFloat(rad2deg))
      arm.relativeLine(to: NSMakePoint(lenx,leny))
      needsDisplay = true 
   }
  
   
   override func draw(_ dirtyRect: NSRect) 
   {
      super.draw(dirtyRect)
      let hgfarbe  = NSColor.init(red: 0.25, 
                              green: 0.25, 
                              blue: 0.85, 
                              alpha: 0.25)
      
      let currentContext = NSGraphicsContext.current!.cgContext
      currentContext.setLineWidth(2)
      hgfarbe.set()
      rahmen.fill()
      NSColor.gray.set() // 
      achsen.stroke()
      
      let linienfarbe = NSColor.init(red: 0.85, 
                                     green: 0.85, 
                                     blue: 0.85, 
                                     alpha: 0.25)
      linienfarbe.set()
      waagrechtelinien.stroke()
      senkrechtelinien.stroke()
      NSColor.blue.set() // choose color
      
      arm.stroke()
      
      needsDisplay = true
   }
}
