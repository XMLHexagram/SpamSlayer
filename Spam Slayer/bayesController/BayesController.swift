//
//  BayesController.swift
//  Spam Slayer
//
//  Created by Hexagram on 2024/5/12.
//

import Foundation
import SwiftCSV
import NaturalLanguage
import ThisKit

class BayesController {
  public static var `default` = BayesController()
  
  public var classifier: BayesianClassifier = BayesianClassifier<String, String>()
  public let tokenizer = NLTokenizer(unit: .word)
  public var eventSpace = EventSpace<String, String>()
  public var stopwords: Set<String> = .init()
  public let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("classifier.json")
  
  init() {
    
  }
  
  public func prepare() throws {
    guard let path = Bundle.main.url(forResource: "classifier", withExtension: "json") else {
      throw TKErrorHandler.AnyError.any("classifer.json not exist in main bundle")
    }
    let jsonData = try Data(contentsOf: path)
    let decoder = JSONDecoder()
    self.classifier = try decoder.decode(BayesianClassifier<String, String>.self, from: jsonData)
  }
  
  public func train() throws {
    if FileManager.default.fileExists(atPath: path.path()) {
      let jsonData = try Data(contentsOf: path)
      let decoder = JSONDecoder()
      self.classifier = try decoder.decode(BayesianClassifier<String, String>.self, from: jsonData)
      return
    }
    
    try dealStopword1()
    try dealStopword2()
    try dealSMS3()
    
    self.classifier = BayesianClassifier(eventSpace: eventSpace)
    
    let jsonData = try JSONEncoder().encode(classifier)
    
    try jsonData.write(to: path, options: .atomic)
  }
  
  func delete() throws {
    try FileManager.default.removeItem(at: path)
  }
  
  func dealStopword1() throws {
    guard let url = Bundle.main.url(forResource: "stopword_1", withExtension: "txt") else {
      throw TKErrorHandler.AnyError.any("stopword_1.txt not exist in main bundle")
    }
    stopwords = stopwords.union(Set(try! String(contentsOf: url).components(separatedBy: .newlines)))
  }
  
  func dealStopword2() throws {
    guard let url = Bundle.main.url(forResource: "stopword_2", withExtension: "txt") else {
      throw TKErrorHandler.AnyError.any("stopword_2.txt not exist in main bundle")
    }
    stopwords = stopwords.union(Set(try! String(contentsOf: url).components(separatedBy: .newlines)))
  }
  
  func dealSMS3() throws {
    guard let csv: CSV<Named> = try CSV<Named>(
      name: "sms_3",
      extension: "csv",
      bundle: .main,
      delimiter: .comma,  // Any character works!
      encoding: .utf8) else {
      print("sms_3 not exists")
      return
    }
    print("sms_3 exists")
    
    var i = 0
    try csv.enumerateAsDict { dict in
      guard let label = dict["label"] else {
        return
      }
      guard let msg_new = dict["text"] else {
        return
      }
      
      let splitedMsg = self.tokenize(msg_new)
      let a = splitedMsg.filter { s in
        if self.stopwords.contains(s) {
          return false
        }
        return true
      }
      i += 1
      print("sms3 \(i)")
      self.eventSpace.observe(label, features: a)
    }
  }
  
  public func classify(_ text: String) -> String? {
    return self.classifier.classify(tokenize(text))
  }
  
  public func tokenize(_ text: String) -> [String] {
    tokenizer.string = text
    tokenizer.setLanguage(.simplifiedChinese)
    let tokenRange = tokenizer.tokens(for: text.startIndex..<text.endIndex)
    return tokenRange.map { range in
      String(text[range])
    }
  }
}
