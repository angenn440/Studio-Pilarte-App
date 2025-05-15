//
//  ReservaView.swift
//  Pilarte App
//
//  Created by Alumno on 25/04/25.
//

import SwiftUI
import EventKit

struct ReservaView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedDate = Date()
    @State private var selectedTime: String?
    @State private var selectedClassType = "Pilates Mat"
    @State private var showingConfirmation = false
    @State private var showingCalendarAlert = false
    @State private var calendarAccessGranted = false
    
    let availableTimes = ["7:00 AM", "8:00 AM", "9:00 AM", "10:00 AM", "4:00 PM", "5:00 PM", "6:00 PM", "7:00 PM"]
    let classTypes = ["Pilates Mat", "Pilates Reformer", "Pilates Aéreo", "Clase Privada"]
    let instructors = ["Ana Martínez", "Carlos López", "María Fernández"]
    @State private var selectedInstructor = "Ana Martínez"
    
    let eventStore = EKEventStore()
    
    // Colores personalizados
    let primaryColor = Color("Green")
    let secondaryColor = Color("LightGreen")
    let backgroundColor = Color("White")
    let cardColor = Color("WidgetBackground")
    
    var body: some View {
        ZStack {
            // Fondo con textura sutil
            backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header con logo
                    headerSection()
                    
                    // Tarjeta de tipo de clase
                    classTypeCard()
                    
                    // Calendario semanal mejorado
                    weekCalendarCard()
                    
                    // Horarios con diseño de pastilla
                    timeSlotsSection()
                    
                    // Selector de instructor
                    instructorCard()
                    
                    // Botón de confirmación
                    confirmButton()
                }
                .padding(.vertical, 25)
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle("Reservar Clase")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Reserva Confirmada", isPresented: $showingConfirmation) {
            Button("Añadir al Calendario") {
                addEventToCalendar()
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text("Tu clase de \(selectedClassType) con \(selectedInstructor) el \(formattedSelectedDate()) a las \(selectedTime ?? "") ha sido reservada.")
        }
        .alert("Acceso al Calendario", isPresented: $showingCalendarAlert) {
            Button("Ajustes", role: .none) {
                openAppSettings()
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Por favor permite acceso al calendario en Ajustes para añadir tu reserva automáticamente.")
        }
        .onAppear {
            requestCalendarAccess()
        }
    }
    
    // MARK: - Componentes Personalizados
    
    private func headerSection() -> some View {
        VStack(spacing: 10) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 40))
                .foregroundColor(primaryColor)
            
            Text("Reserva tu sesión")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Selecciona fecha, horario e instructor")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.bottom, 10)
    }
    
    private func classTypeCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TIPO DE CLASE")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
            
            Picker("", selection: $selectedClassType) {
                ForEach(classTypes, id: \.self) { type in
                    Text(type).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 8)
        }
        .padding()
        .background(cardColor)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func weekCalendarCard() -> some View {
        VStack(spacing: 15) {
            // Encabezado con mes/año
            HStack {
                Text(selectedDate.monthYearFormatted().uppercased())
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(primaryColor)
                
                Spacer()
                
                // Botones de navegación
                HStack(spacing: 15) {
                    Button(action: previousWeek) {
                        Image(systemName: "chevron.left")
                            .font(.footnote)
                            .padding(8)
                            .background(cardColor)
                            .clipShape(Circle())
                    }
                    
                    Button(action: nextWeek) {
                        Image(systemName: "chevron.right")
                            .font(.footnote)
                            .padding(8)
                            .background(cardColor)
                            .clipShape(Circle())
                    }
                }
            }
            
            // Días de la semana
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { dayOffset in
                    let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: selectedDate.startOfWeek())!
                    dayView(for: date)
                }
            }
        }
        .padding()
        .background(cardColor)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func dayView(for date: Date) -> some View {
        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
        let isToday = Calendar.current.isDateInToday(date)
        
        return Button(action: { selectedDate = date }) {
            VStack(spacing: 6) {
                Text(date.dayOfWeekLetter())
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : (isToday ? primaryColor : .secondary))
                
                Text(date.dayNumber())
                    .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : (isToday ? primaryColor : .primary))
                
                if isSelected {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 6, height: 6)
                } else if isToday {
                    Circle()
                        .fill(primaryColor)
                        .frame(width: 6, height: 6)
                } else {
                    Spacer()
                        .frame(height: 6)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? primaryColor : Color.clear)
            .cornerRadius(8)
        }
    }
    
    private func timeSlotsSection() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("HORARIOS DISPONIBLES")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
            
            // Grid de horarios
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                ForEach(availableTimes, id: \.self) { time in
                    timeSlotButton(time: time)
                }
            }
        }
        .padding()
        .background(cardColor)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func timeSlotButton(time: String) -> some View {
        Button(action: { selectedTime = time }) {
            Text(time)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(selectedTime == time ? primaryColor : cardColor)
                .foregroundColor(selectedTime == time ? .white : .primary)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(selectedTime == time ? primaryColor : Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
    
    private func instructorCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("INSTRUCTOR")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
            
            Menu {
                Picker("", selection: $selectedInstructor) {
                    ForEach(instructors, id: \.self) { instructor in
                        Text(instructor).tag(instructor)
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(primaryColor)
                    
                    Text(selectedInstructor)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(cardColor)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(cardColor)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func confirmButton() -> some View {
        Button(action: confirmReservation) {
            HStack {
                Spacer()
                Text("CONFIRMAR RESERVA")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            .background(selectedTime != nil ? primaryColor : Color.gray.opacity(0.5))
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: selectedTime != nil ? primaryColor.opacity(0.3) : .clear, radius: 10, x: 0, y: 5)
        }
        .disabled(selectedTime == nil)
        .animation(.easeInOut, value: selectedTime)
    }
    
    
    private func previousWeek() {
        selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: selectedDate)!
    }
    
    private func nextWeek() {
        selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: selectedDate)!
    }
    
    private func confirmReservation() {
        guard selectedTime != nil else { return }
        showingConfirmation = true
    }
    
    private func formattedSelectedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: selectedDate)
    }
    
    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Funciones de Calendario
    
    private func requestCalendarAccess() {
        eventStore.requestAccess(to: .event) { granted, error in
            DispatchQueue.main.async {
                self.calendarAccessGranted = granted
                if let error = error {
                    print("Error al solicitar acceso al calendario: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func addEventToCalendar() {
        guard calendarAccessGranted else {
            showingCalendarAlert = true
            return
        }
        
        guard let selectedTime = selectedTime else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.locale = Locale(identifier: "es_MX")
        
        guard let timeDate = dateFormatter.date(from: selectedTime) else { return }
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: timeDate)
        
        guard let eventDate = calendar.date(byAdding: timeComponents, to: calendar.date(from: dateComponents)!) else { return }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = "Clase de \(selectedClassType) con \(selectedInstructor)"
        event.startDate = eventDate
        event.endDate = calendar.date(byAdding: .hour, value: 1, to: eventDate)
        event.notes = "Reserva realizada a través de Pilarte App"
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        let alarm = EKAlarm(relativeOffset: -3600) // Alarma 1 hora antes
        event.addAlarm(alarm)
        
        do {
            try eventStore.save(event, span: .thisEvent)
            print("Evento añadido al calendario")
        } catch {
            print("Error al guardar evento: \(error.localizedDescription)")
        }
    }
}

// MARK: - Extensiones para Date

extension Date {
    func startOfWeek() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components)!
    }
    
    func monthYearFormatted() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: self)
    }
    
    func dayOfWeekLetter() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: self).prefix(1).uppercased()
    }
    
    func dayNumber() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: self)
    }
}

// MARK: - Preview

struct ReservaView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ReservaView()
                .environmentObject(AuthManager())
        }
    }
}
