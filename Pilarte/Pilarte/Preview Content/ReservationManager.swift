//
//  File.swift
//  Pilarte App
//
//  Created by Alumno on 28/04/25.
//

import Foundation
import SwiftUI

class ReservationManager: ObservableObject {
    @Published var reservations: [Reservation] = []
    
    init() {
        loadReservations()
    }
    
    func addReservation(type: String, date: Date, time: String, instructor: String, duration: String, level: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let newReservation = Reservation(
            id: UUID(),
            type: type,
            instructor: instructor,
            date: formatter.string(from: date),
            time: time,
            duration: duration,
            level: level
        )
        reservations.append(newReservation)
        saveReservations()
    }
    
    private func saveReservations() {
        let savedData = reservations.map { reservation in
            [
                "id": reservation.id.uuidString,
                "type": reservation.type,
                "instructor": reservation.instructor,
                "date": reservation.date,
                "time": reservation.time,
                "duration": reservation.duration,
                "level": reservation.level
            ]
        }
        UserDefaults.standard.set(savedData, forKey: "reservasGuardadas")
    }
    
    private func loadReservations() {
        if let savedData = UserDefaults.standard.array(forKey: "reservasGuardadas") as? [[String: String]] {
            reservations = savedData.compactMap { item in
                guard
                    let idString = item["id"],
                    let id = UUID(uuidString: idString),
                    let type = item["type"],
                    let instructor = item["instructor"],
                    let date = item["date"],
                    let time = item["time"],
                    let duration = item["duration"],
                    let level = item["level"]
                else {
                    return nil
                }
                return Reservation(
                    id: id,
                    type: type,
                    instructor: instructor,
                    date: date,
                    time: time,
                    duration: duration,
                    level: level
                )
            }
        }
    }
}
