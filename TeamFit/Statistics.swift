//
//  Statistics.swift
//  TeamFit
//
//  Created by Louis Chatta on 1/11/15.
//  Copyright (c) 2015 TeamFit. All rights reserved.
//

import Foundation
class Statistics{
    var speedSum  = Float()
    var speedIndex = Float()
    var topSpeed   = Float()

    func average (speedStack:NSMutableArray) -> Float{
      for element in speedStack{
         var elm = Float(element as NSNumber)
         print("current speed is")
         print(element)
         if(topSpeed<elm){
            topSpeed = elm
         }
        
         speedSum += elm
         speedIndex++
       }
       var average = speedSum/speedIndex
       print("avg: ")
       print(average)
       print("fastest speed")
       print(topSpeed)
    
       return average
     }
    
}