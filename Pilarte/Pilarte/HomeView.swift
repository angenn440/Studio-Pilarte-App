//
//  HomeView.swift
//  Pilarte App
//
//  Created by Alumno on 25/04/25.
import SwiftUI

struct SesionPilates: Identifiable {
    let id: Int
    let tipo: String
    let instructor: String
    let fecha: String
    let hora: String
    let duracion: String
    let nivel: String
}

struct TipPilates: Identifiable {
    let id: Int
    let titulo: String
    let contenido: String
    let icono: String
    var detalle: String? = nil
}

struct TipDetailView: View {
    let tip: TipPilates
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: tip.icono)
                            .font(.largeTitle)
                            .foregroundColor(Color("DarkGreen"))
                        
                        Text(tip.titulo)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Consejo:")
                            .font(.headline)
                            .foregroundColor(Color("DarkGreen"))
                        
                        Text(tip.contenido)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    
                    if let detalle = tip.detalle {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Cómo aplicarlo:")
                                .font(.headline)
                                .foregroundColor(Color("DarkGreen"))
                            
                            Text(detalle)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Detalle del Consejo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { }
                }
            }
        }
    }
}

struct HomeView: View {
    @StateObject public var profileViewModel = ProfileViewModel()
    @State private var purchasedPlans: [[String: Any]] = []
    @State private var showProfile = false
    @State private var showTipDetail: TipPilates? = nil
    @State private var showingDeleteConfirmation = false
    @State private var planToDelete: Int? = nil
    @State private var ClaseAgendadaCard = false
    
    let proximasSesiones = [
        SesionPilates(id: 1, tipo: "Pilates Reformer", instructor: "Ana Martínez", fecha: "15 Mayo 2024", hora: "10:00 AM", duracion: "60 min", nivel: "Intermedio"),
        SesionPilates(id: 2, tipo: "Pilates Mat", instructor: "Carlos López", fecha: "20 Mayo 2024", hora: "4:30 PM", duracion: "45 min", nivel: "Principiante")
    ]
    
    let tipsPilates = [
        TipPilates(id: 1, titulo: "Respiración", contenido: "Coordina tu respiración con los movimientos. Inhala al preparar y exhala al ejecutar.", icono: "wind", detalle: "Practica la respiración torácica: coloca las manos en las costillas y siente cómo se expanden al inhalar."),
        TipPilates(id: 2, titulo: "Ropa adecuada", contenido: "Usa ropa cómoda que te permita moverte libremente pero no demasiado holgada.", icono: "tshirt", detalle: "Los leggings y tops ajustados son ideales. Evita cremalleras o botones que puedan molestar en los ejercicios."),
        TipPilates(id: 3, titulo: "Concentración", contenido: "Mantén tu mente enfocada en los músculos que estás trabajando.", icono: "brain.head.profile", detalle: "Visualiza el músculo que estás trabajando durante cada ejercicio para mejorar la conexión mente-cuerpo.")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color("DarkGreen"), Color("Green")]),
                               startPoint: .top,
                               endPoint: .bottom)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 8) {
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                            
                            Text("Bienvenido a Pilarte")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                        }
                        .padding(.top, 30)
                        .padding(.bottom, 20)
                        
                        VStack(spacing: 25) {
                            if !purchasedPlans.isEmpty {
                                VStack(alignment: .leading, spacing: 15) {
                                    HStack {
                                        SectionHeader(title: "Tus Planes", icon: "creditcard.fill")
                                        
                                        Spacer()
                                        
                                        if purchasedPlans.count > 1 {
                                            Button(action: {
                                                showingDeleteConfirmation = true
                                            }) {
                                                Text("Eliminar todos")
                                                    .font(.caption)
                                                    .foregroundColor(.white)
                                                    .padding(8)
                                                    .background(Color.red.opacity(0.7))
                                                    .cornerRadius(8)
                                            }
                                        }
                                    }
                                    
                                    ForEach(purchasedPlans.indices, id: \.self) { index in
                                        SolidCard {
                                            VStack {
                                                PlanCompradoCard(plan: purchasedPlans[index])
                                                
                                                Button(action: {
                                                    planToDelete = index
                                                    showingDeleteConfirmation = true
                                                }) {
                                                    HStack {
                                                        Image(systemName: "trash")
                                                        Text("Eliminar plan")
                                                    }
                                                    .font(.caption)
                                                    .foregroundColor(.red)
                                                    .padding(.top, 5)
                                                }
                                            }
                                            .padding(.bottom, 10)
                                        }
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 15) {
                                SectionHeader(title: "Próximas Sesiones", icon: "calendar")
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(proximasSesiones) { sesion in
                                            SolidCard {
                                                SesionCard(sesion: sesion)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 15)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 15) {
                                SectionHeader(title: "Consejos de Pilates", icon: "lightbulb.fill")
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(tipsPilates) { tip in
                                            SolidCard {
                                                TipCard(tip: tip)
                                                    .onTapGesture {
                                                        showTipDetail = tip
                                                    }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 15)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 15) {
                                SectionHeader(title: "Recordatorios", icon: "bell.fill")
                                
                                SolidCard {
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack {
                                            Image(systemName: "clock.badge.checkmark")
                                                .foregroundColor(Color("LightGreen"))
                                            Text("Lleva tu toalla personal")
                                                .font(.subheadline)
                                                .foregroundColor(.primary)
                                        }
                                        
                                        HStack {
                                            Image(systemName: "clock.badge.checkmark")
                                                .foregroundColor(Color("LightGreen"))
                                            Text("Llega 10 minutos antes")
                                                .font(.subheadline)
                                                .foregroundColor(.primary)
                                        }
                                        
                                        HStack {
                                            Image(systemName: "clock.badge.checkmark")
                                                .foregroundColor(Color("LightGreen"))
                                            Text("Evita comer 1 hora antes")
                                                .font(.subheadline)
                                                .foregroundColor(.primary)
                                        }
                                    }
                                    .padding()
                                }
                            }
                        }
                        .padding(.horizontal, 15)
                        .padding(.bottom, 30)
                    }
                }
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { showProfile.toggle() }) {
                            profileImage
                                .frame(width: 50, height: 50)
                                .background(Color("DarkGreen").opacity(0.8))
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(radius: 5)
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 10)
                    }
                    Spacer()
                }
            }
            .alert("Confirmar eliminación", isPresented: $showingDeleteConfirmation) {
                if let index = planToDelete {
                    Button("Eliminar", role: .destructive) {
                        PurchaseManager.shared.removePlan(at: index)
                        purchasedPlans.remove(at: index)
                        planToDelete = nil
                    }
                    Button("Cancelar", role: .cancel) {
                        planToDelete = nil
                    }
                } else {
                    Button("Eliminar todos", role: .destructive) {
                        removeAllPlans()
                    }
                    Button("Cancelar", role: .cancel) {}
                }
            } message: {
                if planToDelete != nil {
                    Text("¿Estás seguro de que quieres eliminar este plan?")
                } else {
                    Text("¿Estás seguro de que quieres eliminar todos tus planes?")
                }
            }
            .sheet(item: $showTipDetail) { tip in
                TipDetailView(tip: tip)
            }
            .onAppear {
                purchasedPlans = PurchaseManager.shared.getPlans()
            }
        }
    }
    
    private func removeAllPlans() {
        for index in purchasedPlans.indices.reversed() {
            PurchaseManager.shared.removePlan(at: index)
        }
        purchasedPlans = []
    }
    
    private var profileImage: some View {
        Group {
            if let image = profileViewModel.profileImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundColor(.white)
            }
        }
    }
    
    struct SectionHeader: View {
        let title: String
        let icon: String
        
        var body: some View {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(Color("LightGreen"))
                    .font(.title3)
                
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                
                Spacer()
            }
            .padding(.horizontal, 5)
        }
    }
    
    struct SolidCard<Content: View>: View {
        let content: Content
        
        init(@ViewBuilder content: () -> Content) {
            self.content = content()
        }
        
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                content
            }
        }
    }
    
    struct PlanCompradoCard: View {
        let plan: [String: Any]
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "creditcard.fill")
                        .foregroundColor(Color("DarkGreen"))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plan["name"] as? String ?? "Plan")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        if let expiry = plan["expiry"] as? String {
                            Text("Vence \(expiry)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if let savings = plan["savings"] as? Int, savings > 0 {
                        Text("-\(savings)%")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(5)
                            .background(Color("LightGreen"))
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                }
                
                Divider()
                    .background(Color.gray.opacity(0.2))
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Clases incluidas:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(plan["classCount"] as? Int ?? 0)")
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    HStack {
                        Text("Inversión:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(plan["price"] as? String ?? "$0")
                            .fontWeight(.bold)
                            .foregroundColor(Color("DarkGreen"))
                    }
                }
                .font(.subheadline)
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
    }
    struct ClaseAgendadaCard: View {
        let clase: SesionPilates

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(Color("DarkGreen"))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(clase.tipo)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        Text("con \(clase.instructor)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Text(clase.nivel)
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(5)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }

                Divider()
                    .background(Color.gray.opacity(0.2))

                VStack(alignment: .leading, spacing: 8) {
                    Text("Fecha: \(clase.fecha)")
                    Text("Hora: \(clase.hora) (\(clase.duracion))")
                }
                .font(.subheadline)
            }
            .padding()
            .background(Color("WidgetBackground"))
            .cornerRadius(10)
        }
    }
    struct SesionCard: View {
        let sesion: SesionPilates
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: sesion.tipo.contains("Reformer") ? "figure.pilates" : "mat.rug")
                        .foregroundColor(Color("DarkGreen"))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(sesion.tipo)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("con \(sesion.instructor)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(sesion.nivel)
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(5)
                        .background(nivelColor)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                
                Divider()
                    .background(Color.gray.opacity(0.2))
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                        Text(sesion.fecha)
                            .foregroundColor(.primary)
                    }
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                        Text("\(sesion.hora) (\(sesion.duracion))")
                            .foregroundColor(.primary)
                    }
                }
                .font(.subheadline)
            }
            .padding()
            .frame(width: 250)
        }
        
        private var nivelColor: Color {
            switch sesion.nivel {
            case "Principiante": return Color.green
            case "Intermedio": return Color.blue
            case "Avanzado": return Color.orange
            default: return Color.gray
            }
        }
    }
    
    struct TipCard: View {
        let tip: TipPilates
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: tip.icono)
                        .foregroundColor(Color("DarkGreen"))
                    
                    Text(tip.titulo)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Divider()
                    .background(Color.gray.opacity(0.2))
                
                Text(tip.contenido)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(3)
            }
            .padding()
            .frame(width: 200, height: 150)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
