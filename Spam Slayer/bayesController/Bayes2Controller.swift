//
//  Bayes2Controller.swift
//  Spam Slayer
//
//  Created by Hexagram on 2024/5/12.
//

import Foundation
import SwiftCSV
import NaturalLanguage
import ThisKit

class Bayes2Controller {
  public static var `default` = Bayes2Controller()
  
  public var classifier1: BayesianClassifier = BayesianClassifier<String, String>()
  public var classifier2: BayesianClassifier = BayesianClassifier<String, String>()
  public let tokenizer = NLTokenizer(unit: .word)
  public var eventSpace1 = EventSpace<String, String>()
  public var eventSpace2 = EventSpace<String, String>()
  public var stopwords: Set<String> = .init()
  public let path1 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("classifier2-1.json")
  public let path2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("classifier2-2.json")
  
  init() {
    
  }
  
  public func prepare() throws {
    guard let path = Bundle.main.url(forResource: "classifier2-1", withExtension: "json") else {
      throw TKErrorHandler.AnyError.any("classifer2-1.json not exist in main bundle")
    }
    let jsonData = try Data(contentsOf: path)
    let decoder = JSONDecoder()
    self.classifier1 = try decoder.decode(BayesianClassifier<String, String>.self, from: jsonData)
    
    guard let path2 = Bundle.main.url(forResource: "classifier2-2", withExtension: "json") else {
      throw TKErrorHandler.AnyError.any("classifer2-1.json not exist in main bundle")
    }
    let jsonData2 = try Data(contentsOf: path2)
    self.classifier2 = try decoder.decode(BayesianClassifier<String, String>.self, from: jsonData2)
  }
  
  public func train() async throws {
    try await prepare1()
    try await prepare2()
  }
  
  public func prepare2() async throws {
    if FileManager.default.fileExists(atPath: path2.path()) {
      let jsonData = try Data(contentsOf: path2)
      let decoder = JSONDecoder()
      self.classifier2 = try decoder.decode(BayesianClassifier<String, String>.self, from: jsonData)
      return
    }
    
    dealStopword1()
    dealStopword2()
    try await dealSecond()
    
    self.classifier2 = BayesianClassifier(eventSpace: eventSpace2)
    
    let jsonData = try JSONEncoder().encode(classifier2)
    
    try jsonData.write(to: path2, options: .atomic)
  }
  
  public func prepare1() async throws {
    if FileManager.default.fileExists(atPath: path1.path()) {
      let jsonData = try Data(contentsOf: path1)
      let decoder = JSONDecoder()
      self.classifier1 = try decoder.decode(BayesianClassifier<String, String>.self, from: jsonData)
      return
    }
    
    dealStopword1()
    dealStopword2()
    try await dealFirst()
    
    self.classifier1 = BayesianClassifier(eventSpace: eventSpace1)
    
    let jsonData = try JSONEncoder().encode(classifier1)
    
    try jsonData.write(to: path1, options: .atomic)
  }
  
  func delete() throws {
    try FileManager.default.removeItem(at: path1)
    try FileManager.default.removeItem(at: path2)
  }
  
  func dealStopword1() {
    guard let url = Bundle.main.url(forResource: "stopword_1", withExtension: "txt") else {
      return
    }
    stopwords = stopwords.union(Set(try! String(contentsOf: url).components(separatedBy: .newlines)))
  }
  
  func dealStopword2() {
    guard let url = Bundle.main.url(forResource: "stopword_2", withExtension: "txt") else {
      return
    }
    stopwords = stopwords.union(Set(try! String(contentsOf: url).components(separatedBy: .newlines)))
  }
  
  func dealFirst() async throws {
    guard let AD = Bundle.main.url(forResource: "ad_combined", withExtension: "txt") else {
      return
    }
    guard let FR = Bundle.main.url(forResource: "fr_combined", withExtension: "txt") else {
      return
    }
    guard let IL = Bundle.main.url(forResource: "il_combined", withExtension: "txt") else {
      return
    }
    guard let sms1 = Bundle.main.url(forResource: "text.sms_3.label1.part1", withExtension: "txt") else {
      return
    }
    
    try await dealURL1(label: "1", AD)
    
    try await dealURL1(label: "1", FR)
    
    try await dealURL1(label: "1", IL)
    
    try await dealURL1(label: "1", sms1)
    
    guard let sms1 = Bundle.main.url(forResource: "text.sms_3.label0.part1", withExtension: "txt") else {
      return
    }
    
    try await dealURL1(label: "0", sms1)
  }
  
  func dealSecond() async throws {
    guard let AD = Bundle.main.url(forResource: "ad_combined", withExtension: "txt") else {
      return
    }
    guard let FR = Bundle.main.url(forResource: "fr_combined", withExtension: "txt") else {
      return
    }
    guard let IL = Bundle.main.url(forResource: "il_combined", withExtension: "txt") else {
      return
    }
    
    try await dealURL2(label: "AD", AD)
    
    try await dealURL2(label: "FR", FR)
    
    try await dealURL2(label: "IL", IL)
  }
  
  
  func dealURL1(label: String, _ url: URL) async throws {
    var i = 0
    for try await line in url.lines {
      let tokenizedLine = self.tokenize(line)
      self.eventSpace1.observe(label, features: tokenizedLine)
      i += 1
      print(i)
    }
  }
  
  func dealURL2(label: String, _ url: URL) async throws {
    var i = 0
    for try await line in url.lines {
      let tokenizedLine = self.tokenize(line)
      self.eventSpace2.observe(label, features: tokenizedLine)
      i += 1
      print(i)
    }
  }
  
  public func classify(_ text: String) -> (String?, String?) {
    let tokenizedText = tokenize(text)
    guard let T = self.classifier1.classify(tokenizedText) else {
      return (nil, nil)
    }
    if T == "0" {
      return ("0", nil)
    }
    return ("1", self.classifier2.classify(tokenizedText))
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
