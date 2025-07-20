//
//  ZueriApp.swift
//  Züri
//
//  Created by Erik Schnell on 12.03.2025.
//

import SwiftUI
import FirebaseCore
import FirebaseAppCheck


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      
      // App check for simulator, remove in prod
      let providerFactory = AppCheckDebugProviderFactory()
      AppCheck.setAppCheckProviderFactory(providerFactory)
      
      
    FirebaseApp.configure()

    return true
  }
}

@main
struct ZueriApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate


  var body: some Scene {
    WindowGroup {
//      NavigationView {
        ContentView()
//      }
    }
  }
}
