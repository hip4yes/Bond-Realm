//
//  RLMExtensions.swift
//  BondPlayground
//
//  Created by Nikita Arkhipov on 20.03.15.
//  Copyright (c) 2015 Anvix. All rights reserved.
//

import Foundation
import Realm

extension RLMRealm{
   class func allObjects<T: RLMObject>(ofType: T.Type) -> [T]{
      return T.allObjects()?.map { $0 as T } ?? []
   }   
}

extension RLMResults{   
   func map<U>(transform: AnyObject -> U) -> [U]{
      var array: [U] = []
      for obj in self{
         array.append(transform(obj))
      }
      return array
   }
}

extension RLMArray{   
   func map<T>(transform: RLMObject -> T) -> [T]{
      var array: [T] = []
      for obj in self{
         array.append(transform(obj))
      }
      return array
   }
}

