//
//  AccountView.swift
//  Pilarte App
//
//  Created by Alumno on 25/04/25.
//

import SwiftUI
import PhotosUI


struct AccountView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = AccountViewModel()
    @State private var showingLogoutAlert = false
    @State private var showingDeleteAccountAlert = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isEditing = true
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ProfileHeaderView(
                        viewModel: viewModel,
                        isEditing: $isEditing,
                        selectedPhotoItem: $selectedPhotoItem
                    )
                    
                    PersonalInfoSection(
                        viewModel: viewModel,
                        isEditing: $isEditing
                    )
                    
                    SettingsSection(viewModel: viewModel)
                    
                    ActionButtons(
                        viewModel: viewModel,
                        isEditing: $isEditing,
                        showingLogoutAlert: $showingLogoutAlert,
                        showingDeleteAccountAlert: $showingDeleteAccountAlert
                    )
                }
                .padding(.bottom, 30)
            }
            .background(Color("Background").ignoresSafeArea())
            .navigationTitle("Mi Cuenta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton(
                        isEditing: $isEditing,
                        viewModel: viewModel
                    )
                }
            }
            .alerts(
                viewModel: viewModel,
                showingLogoutAlert: $showingLogoutAlert,
                showingDeleteAccountAlert: $showingDeleteAccountAlert
            )
        }
    }
}


struct ProfileHeaderView: View {
    @ObservedObject var viewModel: AccountViewModel
    @Binding var isEditing: Bool
    @Binding var selectedPhotoItem: PhotosPickerItem?
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                if let image = viewModel.profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(Color("Green"))
                }
                
                if isEditing {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Image(systemName: "pencil.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, Color("Text"))
                            .font(.system(size: 28))
                            .background(Circle().fill(.white))
                    }
                    .onChange(of: selectedPhotoItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                viewModel.profileImage = image
                            }
                        }
                    }
                }
            }
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            if isEditing {
                TextField("Nombre", text: $viewModel.userName)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            } else {
                Text(viewModel.userName)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 8)
            }
            
            Text(viewModel.userEmail)
                .font(.subheadline)
                .foregroundColor(.black)
        }
        .padding(.vertical, 20)
    }
}

struct PersonalInfoSection: View {
    @ObservedObject var viewModel: AccountViewModel
    @Binding var isEditing: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            SectionHeader(title: "Información Personal", icon: "person.text.rectangle")
            
            if isEditing {
                EditableInfoRow(icon: "phone", title: "Teléfono", value: $viewModel.userPhone)
                EditableInfoRow(icon: "calendar", title: "Fecha de Nacimiento", value: $viewModel.userBirthdate)
                EditableInfoRow(icon: "figure.pilates", title: "Nivel", value: $viewModel.userLevel)
            } else {
                InfoRow(icon: "envelope", title: "Correo", value: viewModel.userEmail)
                InfoRow(icon: "phone", title: "Teléfono", value: viewModel.userPhone)
                InfoRow(icon: "calendar", title: "Fecha de Nacimiento", value: viewModel.userBirthdate)
                InfoRow(icon: "figure.pilates", title: "Nivel", value: viewModel.userLevel)
            }
        }
        .modifier(SectionModifier())
    }
}

struct SettingsSection: View {
    @ObservedObject var viewModel: AccountViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            SectionHeader(title: "Configuración", icon: "gearshape")
            
            NavigationLink(destination: NotificationSettingsView()) {
                SettingsRow(icon: "bell", title: "Notificaciones", value: viewModel.notificationsEnabled ? "Activadas" : "Desactivadas")
                    .foregroundColor(Color("Text"))
            }
            
            NavigationLink(destination: PaymentMethods()) {
                SettingsRow(icon: "creditcard", title: "Métodos de Pago", value: "\(viewModel.paymentMethodsCount)")
                    .foregroundColor(Color("Text"))
            }
            
            NavigationLink(destination: MembershipView()) {
                SettingsRow(icon: "star", title: "Membresía", value: viewModel.membershipStatus)
                    .foregroundColor(Color("Text"))
            }
        }
        .modifier(SectionModifier())
    }
}

struct ActionButtons: View {
    @ObservedObject var viewModel: AccountViewModel
    @Binding var isEditing: Bool
    @Binding var showingLogoutAlert: Bool
    @Binding var showingDeleteAccountAlert: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            if isEditing {
                Button(action: {
                    viewModel.saveChanges()
                    isEditing = false
                }) {
                    ActionButton(title: "Guardar Cambios", icon: "checkmark.circle", color: Color("Green"))
                }
                
                Button(action: {
                    viewModel.discardChanges()
                    isEditing = false
                }) {
                    ActionButton(title: "Cancelar", icon: "xmark.circle", color: .gray)
                }
            }
            
            Button(action: {
                showingLogoutAlert = true
            }) {
                ActionButton(title: "Cerrar Sesión", icon: "rectangle.portrait.and.arrow.right", color: .gray)
            }
  
        }
        .padding(.top, 20)
        .padding(.horizontal)
    }
}

struct EditButton: View {
    @Binding var isEditing: Bool
    @ObservedObject var viewModel: AccountViewModel
    
    var body: some View {
        Button(action: {
            isEditing.toggle()
            if isEditing {
                viewModel.startEditing()
            }
        }) {
            Text(isEditing ? "Listo" : "Editar")
                .fontWeight(.medium)
        }
    }
}

struct SectionModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
    }
}

extension View {
    func alerts(viewModel: AccountViewModel,
                showingLogoutAlert: Binding<Bool>,
                showingDeleteAccountAlert: Binding<Bool>) -> some View {
        self
            .alert("¿Cerrar sesión?", isPresented: showingLogoutAlert) {
                Button("Cerrar Sesión", role: .destructive) {
                 
                    if let window = UIApplication.shared.connectedScenes
                        .filter({ $0.activationState == .foregroundActive })
                        .compactMap({ $0 as? UIWindowScene })
                        .first?.windows.first {
                        
                        window.rootViewController = UIHostingController(rootView: LoginView())
                        window.makeKeyAndVisible()
                    }
                }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("¿Estás seguro de que quieres cerrar tu sesión?")
            }
            .alert("Eliminar Cuenta", isPresented: showingDeleteAccountAlert) {
                Button("Eliminar", role: .destructive) {
                    viewModel.deleteAccount()
                }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("Esta acción eliminará permanentemente tu cuenta y todos tus datos. ¿Estás seguro?")
            }
    }
}
class AccountViewModel: ObservableObject {
    @Published var profileImage: UIImage?
    @Published var userName = "Angel Gadiel"
    @Published var userEmail = "angenn440@gmail.com"
    @Published var userPhone = ""
    @Published var userBirthdate = ""
    @Published var userLevel = "Intermedio"
    @Published var notificationsEnabled = true
    @Published var paymentMethodsCount = 2
    @Published var membershipStatus = "Premium"
    
    private var originalUserName = ""
    private var originalUserPhone = ""
    private var originalUserBirthdate = ""
    private var originalUserLevel = ""
    private var originalProfileImage: UIImage?
    
    func logout() {
        print("Usuario cerró sesión")
    }
    
    func deleteAccount() {
        print("Cuenta eliminada")
    }
    
    func startEditing() {
        originalUserName = userName
        originalUserPhone = userPhone
        originalUserBirthdate = userBirthdate
        originalUserLevel = userLevel
        originalProfileImage = profileImage
    }
    
    func saveChanges() {
        print("Cambios guardados:")
        print("Nombre: \(userName)")
        print("Teléfono: \(userPhone)")
        print("Fecha de Nacimiento: \(userBirthdate)")
        print("Nivel: \(userLevel)")
    }
    
    func discardChanges() {
        userName = originalUserName
        userPhone = originalUserPhone
        userBirthdate = originalUserBirthdate
        userLevel = originalUserLevel
        profileImage = originalProfileImage
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundColor(Color("Green"))
            Spacer()
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(Color("Green"))
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct EditableInfoRow: View {
    let icon: String
    let title: String
    @Binding var value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(Color("Green"))
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            TextField(title, text: $value)
                .multilineTextAlignment(.trailing)
                .fontWeight(.medium)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(Color("Green"))
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.gray)
            Image(systemName: "chevron.right")
                .foregroundColor(.gray.opacity(0.5))
        }
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(title)
            Spacer()
        }
        .padding()
        .foregroundColor(color)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

struct NotificationSettingsView: View {
    var body: some View {
        Text("Configuración de Notificaciones")
            .navigationTitle("Notificaciones")
    }
}

struct PaymentMethodsView: View {
    var body: some View {
        Text("Métodos de Pago")
            .navigationTitle("Pagos")
    }
}

struct MembershipView: View {
    var body: some View {
        Text("Detalles de Membresía")
            .navigationTitle("Membresía")
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
