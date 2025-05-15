//
//  SettingsView.swift
//  Pilarte App
//
//  Created by Alumno on 25/04/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var profileViewModel: ProfileViewModel 
    @State var isPrivate: Bool = true
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @State private var navigateToLogin: Bool = false

    let countries = countryList
    let countries1 = countryList1
    let countries2 = countryList2
    let countries4 = countryList3

    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(countries4, id: \.self) { country in
                        NavigationLink(destination: ProfileView(profileViewModel: profileViewModel)) {
                            Text(country)
                        }
                    }

                    ForEach(countries1, id: \.self) { country in
                        NavigationLink(destination: Text(country)) {
                            Text(country)
                        }
                    }
                } header: {
                    Text("Cuenta")
                }

                Section {
                    ForEach(countries, id: \.self) { country in
                        NavigationLink(destination: Text(country)) {
                            Text(country)
                        }
                    }

                    Toggle("Modo oscuro", isOn: $isDarkMode)
                        .onChange(of: isDarkMode) { _ in
                            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
                        }
                } header: {
                    Text("Contenido y pantalla")
                }

                Section {
                    ForEach(countries2, id: \.self) { country in
                        NavigationLink(destination: Text(country)) {
                            Text(country)
                        }
                    }

                    Button {
                        navigateToLogin = true
                    } label: {
                        Text("Cerrar sesión")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                } header: {
                    Text("Inicio de sesión")
                }
            }
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView()
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#Preview {
    SettingsView(profileViewModel: ProfileViewModel())
}
