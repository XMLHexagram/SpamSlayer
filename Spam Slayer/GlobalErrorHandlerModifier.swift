//
//  ExtragramGlobalErrorHandler.swift
//  ExtragramApp
//
//  Created by Hexagram on 2023/12/30.
//

import SwiftUI
import ThisKit
import AlertToast

public struct GlobalErrorHandlerModifier: ViewModifier {
  @EnvironmentObject private var errorHandler: TKErrorHandler
  @State private var showErrorToast = false
  @State private var description: String = ""
  @State private var showWarningToast = false
  
  public func body(content: Content) -> some View {
    content
      .toast(isPresenting: $showWarningToast) {
        AlertToast(displayMode: .banner(.pop), type: .regular, title: "Warning", subTitle: description)
      }
      .toast(isPresenting: $showErrorToast) {
        AlertToast(displayMode: .banner(.pop), type: .error(.red), title: "Error", subTitle: description)
      }
      .task {
        for await err in self.errorHandler.errorQueue {
          TKLog(err.debugDescription)
          switch err {
          default:
            description = err.description
            showErrorToast = true
          }
        }
      }
  }
}
  

