
//  LoginView.swift
//  Pilarte App
//
//  Created by Alumno on 25/04/25.
//

import SwiftUI

class UserManager {
    static let shared = UserManager()
    private let defaults = UserDefaults.standard
    private let usersKey = "pilarteAppUsers"
    
    func registerUser(name: String, email: String, password: String) -> Bool {
        var users = getAllUsers()
        
        if users.contains(where: { $0["email"]?.lowercased() == email.lowercased() }) {
            return false
        }
        
        let newUser = [
            "name": name,
            "email": email.lowercased(),
            "password": password
        ]
        
        users.append(newUser)
        defaults.set(users, forKey: usersKey)
        return true
    }
    
    func loginUser(email: String, password: String) -> Bool {
        let users = getAllUsers()
        return users.contains {
            $0["email"]?.lowercased() == email.lowercased() &&
            $0["password"] == password
        }
    }
    
    private func getAllUsers() -> [[String: String]] {
        return defaults.array(forKey: usersKey) as? [[String: String]] ?? []
    }
}

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var isLoginMode = true
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isLoggedIn = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color("LightGreen"), Color("Green")]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    // Logo y título
                    VStack(spacing: 8) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                        
                        VStack(spacing: 4) {
                            Text("EL ARTE")
                                .font(.system(size: 28, weight: .light))
                                .foregroundColor(.white)
                            
                            Text("DE")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("REFORMAR")
                                .font(.system(size: 28, weight: .light))
                                .foregroundColor(.white)
                            
                            Text("TU CUERPO")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 40)
                    
                    VStack(spacing: 20) {
                        if !isLoginMode {
                            CustomTextField(icon: "person.fill",
                                           placeholder: "Nombre completo",
                                           text: $name)
                        }
                        
                        CustomTextField(icon: "envelope.fill",
                                       placeholder: "Email",
                                       text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        CustomTextField(icon: "lock.fill",
                                       placeholder: "Contraseña",
                                       text: $password,
                                       isSecure: true)
                        
                        Button(action: handleAuthAction) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text(isLoginMode ? "INICIAR SESIÓN" : "REGISTRARME")
                                        .fontWeight(.bold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("DarkGreen"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        .disabled(isLoading)
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                isLoginMode.toggle()
                            }
                        }) {
                            Text(isLoginMode ? "¿No tienes cuenta? Regístrate" : "¿Ya tienes cuenta? Inicia sesión")
                                .foregroundColor(.white)
                                .font(.subheadline)
                                .underline()
                        }
                    }
                    .padding(25)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(20)
                    .padding(.horizontal, 30)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    Spacer()
                    
                    Text("© 2025 El Arte de Reformar Tu Cuerpo")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.bottom, 20)
                }
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .navigationDestination(isPresented: $isLoggedIn) {
                ContentView()
            }
            .navigationBarHidden(true)
        }
    }
    
    struct CustomTextField: View {
        let icon: String
        let placeholder: String
        @Binding var text: String
        var isSecure: Bool = false
        
        var body: some View {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color("DarkGreen"))
                    .frame(width: 20)
                
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color("DarkGreen").opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private func handleAuthAction() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        withAnimation {
            isLoading = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if isLoginMode {
                handleLogin()
            } else {
                handleRegistration()
            }
            
            isLoading = false
        }
    }
    
    private func handleLogin() {
        guard !email.isEmpty, !password.isEmpty else {
            showAlert(title: "Error", message: "Por favor completa todos los campos")
            return
        }
        
        if UserManager.shared.loginUser(email: email, password: password) {
            isLoggedIn = true
        } else {
            showAlert(title: "Error", message: "Email o contraseña incorrectos")
        }
    }
    
    private func handleRegistration() {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            showAlert(title: "Error", message: "Por favor completa todos los campos")
            return
        }
        
        guard email.contains("@") && email.contains(".") else {
            showAlert(title: "Error", message: "Por favor ingresa un email válido")
            return
        }
        
        guard password.count >= 6 else {
            showAlert(title: "Error", message: "La contraseña debe tener al menos 6 caracteres")
            return
        }
        
        if UserManager.shared.registerUser(name: name, email: email, password: password) {
            showAlert(
                title: "Registro exitoso",
                message: "Tu cuenta ha sido creada. Ahora puedes iniciar sesión."
            )
            name = ""
            email = ""
            password = ""
            isLoginMode = true
        } else {
            showAlert(title: "Error", message: "Este email ya está registrado")
        }
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
