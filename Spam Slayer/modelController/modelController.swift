//
//  modelController.swift
//  Spam Slayer
//
//  Created by Hexagram on 2024/5/16.
//

import Foundation
import IdentityLookup

struct ModelController {
  public static let `default` = Self.init()
  
  func callMaxEntropy(_ text: String) throws -> (String?,String?) {
    let model1 = try MaxEntropy1(configuration: .init())
    let label = try model1.prediction(text: text).label
    if label == "0" {
      return (label, nil)
    }
    let model2 = try MaxEntropy2(configuration: .init())
    let label2 = try model2.prediction(text: text).label
    return (label,label2)
  }
}

func formatModelResult(_ input: (String?,String?)) -> (ILMessageFilterAction, ILMessageFilterSubAction){
  let (res1,res2) = input
  if res1 == "0" {
    return (.allow, .none)
  }
  guard let res2 else {
    return (.junk, .none)
  }
  if res2 == "AD" {
    return (.promotion, .none)
  }
  if res2 == "IL" {
    return (.junk, .none)
  }
  if res2 == "FR" {
    return (.transaction, .none)
  }
  return (.junk, .none)
}
