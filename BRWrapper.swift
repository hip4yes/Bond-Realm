//
//  BRWrapper.swift
//  BondPlayground
//
//  Created by Nikita Arkhipov on 20.03.15.
//  Copyright (c) 2015 Anvix. All rights reserved.
//

import Foundation
import Realm

protocol BRWrappable{
   init()
   init(realmModel: RLMObject)
   
   var backingModel: RLMObject! { get }
   class func realmModelType() -> RLMObject.Type
}

class BRWrapper: BRWrappable {
   
   let backingModel: RLMObject!
   private let realm = RLMRealm.defaultRealm()
   private let bonds = NSMutableArray()
   
   required init() {
      let T = self.dynamicType.realmModelType()
      backingModel = T()
      realm.beginWriteTransaction()
      realm.addObject(self.backingModel)
      realm.commitWriteTransaction()
      createBonds()
   }
   
   required init(realmModel: RLMObject){
      self.backingModel = realmModel
      createBonds()
   }
   
   final func createBondFrom<T>(from: Dynamic<T>, toModelKeyPath keyPath: String){
      createBondFrom(from,
         toModelKeyPath: keyPath,
         toRealmTransform: { $0 as NSObject },
         fromRealmTransform: { $0 as T })
   }

   final func createObjectBondFrom<T: BRWrappable>(from: Dynamic<T!>, toModelKeyPath keyPath: String){
      createBondFrom(from,
         toModelKeyPath: keyPath,
         toRealmTransform: { $0.backingModel },
         fromRealmTransform: { T(realmModel: $0 as RLMObject) })
   }

   final func createBondFrom<T>(from: Dynamic<T>, toModelKeyPath keyPath: String, toRealmTransform: T -> AnyObject, fromRealmTransform: AnyObject -> T){
      from.value = fromRealmTransform(backingModel.valueForKeyPath(keyPath)!)
      let bond = Bond<T>() { [unowned self] value in
         self.realm.beginWriteTransaction()
         self.backingModel.setValue(toRealmTransform(value), forKey: keyPath)
         self.realm.commitWriteTransaction()
      }
      from ->| bond
      bonds.addObject(bond)
   }
   
   final func staticObjectBondFor<T: BRWrappable>(type: T.Type, modelKeyPath keyPath: String) -> T{
      let model = backingModel.valueForKey(keyPath) as RLMObject
      return T(realmModel: model)
   }

   final func createArrayBondFrom<T: BRWrappable>(from: DynamicArray<T>, toModelKeyPath keyPath: String){
      createArrayBondFrom(from,
         toModelKeyPath: keyPath,
         toRealmTransform: { $0.backingModel },
         fromRealmTransform: { T(realmModel: $0) })
   }
   
   final func createArrayBondFrom<T>(from: DynamicArray<T>, toModelKeyPath keyPath: String, toRealmTransform: T -> RLMObject, fromRealmTransform: RLMObject -> T){
      let rlmarray = backingModel.valueForKey(keyPath) as RLMArray
      from.append(rlmarray.map(fromRealmTransform))
      
      let bond = ArrayBond<T>()
      bond.insertListener = { [unowned self] array, indices in
         self.realm.beginWriteTransaction()
         for index in indices.reverse(){
            rlmarray.addObject(toRealmTransform(array[index]))
         }
         self.realm.commitWriteTransaction()
      }
      
      bond.removeListener = { [unowned self] _, indices, _ in
         self.realm.beginWriteTransaction()
         for index in indices.reverse(){
            rlmarray.removeObjectAtIndex(UInt(index))
         }
         self.realm.commitWriteTransaction()
      }

      from ->| bond
      bonds.addObject(bond)
   }
   
   func delete(){
      realm.beginWriteTransaction()
      realm.deleteObject(backingModel)
      realm.commitWriteTransaction()
   }

   //MARK: - Implement
   class func realmModelType() -> RLMObject.Type{ fatalError("realmModelType() should be implemented in supreclass") }
   func createBonds(){ fatalError("createBonds() should be implemented in supreclass") }
}

extension RLMRealm{
   class func allBondedObjects<T: BRWrappable>(ofType: T.Type) -> [T]{
      return T.realmModelType().allObjects().map { T(realmModel: $0 as RLMObject) }
   }
}

func DynamicArrayFromAllObjectsOf<T: BRWrappable>(ofType: T.Type) -> DynamicArray<T>{
   return DynamicArray(RLMRealm.allBondedObjects(ofType))
}

