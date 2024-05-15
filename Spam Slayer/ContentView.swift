//
//  ContentView.swift
//  Spam Slayer
//
//  Created by Hexagram on 2024/5/14.
//

import SwiftUI
import SwiftData
import ThisKit

struct ContentView: View {
  @State private var text: String = ""
  @State private var model: Model = .bayes
  
  @State private var result = ""
  
  enum Model: String, CaseIterable, Identifiable {
    case bayes
    case bayes2
    case bert
    case maxEntropy
    
    var id: String { rawValue }
  }
  
  var body: some View {
    NavigationView {
      List {
        Section("Try it!") {
          Picker("Choose Model", selection: $model) {
                 Text("Bayes").tag(Model.bayes)
                 Text("Bayes2").tag(Model.bayes2)
                 Text("BERT").tag(Model.bert)
                 Text("Max Entropy").tag(Model.maxEntropy)
             }
          TextField("Text", text: $text, prompt: Text("Text"), axis: .vertical)
            .lineLimit(1...10)
            .overlay(alignment: .trailing) {
              PasteButton(payloadType: String.self) { strings in
                  text = strings[0]
              }
            }
          Button {
            result = ""
            switch model {
            case .bayes:
              result = BayesController.default.classify(text) ?? "Error"
            case .bayes2:
              result = "\(Bayes2Controller.default.classify(text))"
            case .bert:
              fatalError()
            case .maxEntropy:
              TKErrorHandler.default.handle {
                result = "\(try ModelController.default.callMaxEntropy(text))"
              }
            }
          } label: {
            Text("Submit")
          }
        }
        
        if result != "" {
          Section {
            Text(result)
          }
          .animation(.default, value: result)
        }
        
        NavigationLink(destination: Settings()) {
          Label("Advanced Settings", systemImage: "gearshape")
        }
        
      }
      .navigationTitle("Spam Slayer")
      .modifier(GlobalErrorHandlerModifier())
      .task {
        TKErrorHandler.default.handle {
          try BayesController.default.prepare()
          try Bayes2Controller.default.prepare()
        }
      }
    }
  }
}
