//
//  PilarteApp.swift
//  Pilarte
//
//  Created by Alumno on 30/04/25.

import SwiftUI

@main
struct Pilarte: App {
    @StateObject var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if authManager.isLoggedIn {
                    ContentView()
                        .navigationBarBackButtonHidden(true)
                } else {
                    LoginView()
                }
            }
        }
    }
    
}
