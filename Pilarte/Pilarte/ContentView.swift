//
//  ContentView.swift
//  Pilarte App
//
//  Created by Alumno on 25/04/25.
//
import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    init() {
        UITabBar.appearance().unselectedItemTintColor = UIColor.systemGray
        UITabBar.appearance().tintColor = UIColor(named: "GreenDark")
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Inicio")
                }
                .tag(0)
            
            PilatesPlansView()
                .tabItem {
                    Image(systemName: "dollarsign")
                    Text("Paquetes")
                }
                .tag(1)
            
            ReservaView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Reserva")
                }
                .tag(2)
            
            AccountView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Cuenta")
                }
                .tag(3)
        }
        .tint(Color("Green"))
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ContentView()
}
