//
//  Settings.swift
//  Spam Slayer
//
//  Created by Hexagram on 2024/5/14.
//

import SwiftUI
import ThisKit
import UniformTypeIdentifiers

struct Settings: View {
  @State private var isShowAdvancedSetting = false
  @State private var isShowExporter = false
  @State private var document = JSONDocument(text: "")
  @State private var filename = ""
  
  var body: some View {
    List {
      //        Section("Advanced Setting", isExpanded: $isShowAdvancedSetting) {
      Section {
        Button("Delete Bayes Model") {
          TKErrorHandler.default.handle {
            try BayesController.default.delete()
          }
        }
        Button("Train Bayes Model") {
          Task {
            TKErrorHandler.default.handle {
              try BayesController.default.train()
            }
          }
        }
        Button("Export Bayes Model") {
          TKErrorHandler.default.handle {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("classifier.json")
            document = try JSONDocument(text: String(contentsOf: url))
            filename = "BayesModel.json"
            isShowExporter = true
          }
        }
      }
      Section {
        Button("Delete Bayes2 Model") {
          TKErrorHandler.default.handle {
            try Bayes2Controller.default.delete()
          }
        }
        Button("Train Bayes2 Model") {
          Task {
            await TKErrorHandler.default.handle {
              try await Bayes2Controller.default.train()
            }
          }
        }
        Button("Export Bayes2-1 Model") {
          TKErrorHandler.default.handle {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("classifier2-1.json")
            document = try JSONDocument(text: String(contentsOf: url))
            filename = "BayesMode2-1.json"
            isShowExporter = true
          }
        }
        Button("Export Bayes2-2 Model") {
          TKErrorHandler.default.handle {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("classifier2-2.json")
            document = try JSONDocument(text: String(contentsOf: url))
            filename = "BayesModel2-2.json"
            isShowExporter = true
          }
        }
      }
      .navigationTitle("Advanced Settings")
      .fileExporter(isPresented: $isShowExporter, document: document, contentType: .json, defaultFilename: filename, onCompletion: { result in
        return
      })
      
    }
    
  }
  
  /// https://swiftwithmajid.com/2023/05/10/file-importing-and-exporting-in-swiftui/
  struct JSONDocument: FileDocument {
    static var readableContentTypes: [UTType] {
      [.json]
    }
    
    var text = ""
    
    init(text: String) {
      self.text = text
    }
    
    init(configuration: ReadConfiguration) throws {
      if let data = configuration.file.regularFileContents {
        text = String(decoding: data, as: UTF8.self)
      } else {
        text = ""
      }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
      FileWrapper(regularFileWithContents: Data(text.utf8))
    }
  }
}

//#Preview {
//    Settings()
//}
