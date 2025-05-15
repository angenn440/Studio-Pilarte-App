//
//  ProfileView.swift
//  Pilarte App
//
//  Created by Alumno on 25/04/25.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @ObservedObject var profileViewModel: ProfileViewModel 
    @State private var selectedItem: PhotosPickerItem? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color("Principal").ignoresSafeArea()

                VStack(spacing: 20) {
                    if let image = profileViewModel.profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color("Green"), lineWidth: 2))
                            .shadow(radius: 5)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .foregroundColor(Color("Text"))
                            .shadow(radius: 5)
                    }

                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Text("Seleccionar imagen de perfil")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("POPUP"))
                            .foregroundColor(Color("Text"))
                            .cornerRadius(10)
                            .shadow(radius: 2)
                    }
                    .padding(.horizontal)
                    .onChange(of: selectedItem) { newItem in
                        loadImage(from: newItem)
                    }

                    Spacer()
                }
                .padding()
            }
        }
    }

    private func loadImage(from item: PhotosPickerItem?) {
        guard let item = item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    profileViewModel.profileImage = uiImage
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(profileViewModel: ProfileViewModel())
    }
}

