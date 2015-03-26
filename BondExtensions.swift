//
//  BondExtensions.swift
//  BondPlayground
//
//  Created by Nikita Arkhipov on 20.03.15.
//  Copyright (c) 2015 Anvix. All rights reserved.
//

import Foundation
import Realm

func find<T where T:Equatable>(array: DynamicArray<T>, object: T) -> Int?{
   for i in 0..<array.count{
      if object == array[i] { return i }
   }   
   return nil
}