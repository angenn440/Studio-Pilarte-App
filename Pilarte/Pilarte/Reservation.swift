//
//  ReservationManager.swift
//  Pilarte App
//
//  Created by Alumno on 28/04/25.
//

import Foundation

struct Reservation: Identifiable {
    let id: UUID
    let type: String
    let instructor: String
    let date: String
    let time: String
    let duration: String
    let level: String
}


