//
//  SwiftUIView.swift
//  Pilarte App
//
//  Created by Alumno on 25/04/25.
//

import SwiftUI

import Foundation


    class AuthManager: ObservableObject {
        @Published var isLoggedIn: Bool = false
        
        func login() {
            isLoggedIn = true
        }
        
        func logout() {
            isLoggedIn = false
            UserDefaults.standard.removeObject(forKey: "userSession")
        }
    }

