//
//  CoreDataManager.swift
//  Pilarte
//
//  Created by Alumno on 07/05/25.
//

import CoreData
import UIKit


class CoreDataManager {
    static let shared = CoreDataManager()
    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "ReservasModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error al cargar Core Data: \(error)")
            }
        }
    }

    func guardarReserva(usuarioID: String, claseID: String, fecha: Date, estado: String = "confirmada") {
        let context = container.viewContext
        let reserva = Reserva(context: context)
        reserva.id = UUID()
        reserva.usuarioID = usuarioID
        reserva.claseID = claseID
        reserva.fecha = fecha
        reserva.estado = estado

        do {
            try context.save()
            print("✅ Reserva guardada en Core Data")
        } catch {
            print("❌ Error al guardar: \(error.localizedDescription)")
        }
    }

    // Recuperar todas las reservas
    func obtenerReservas() -> [Reserva] {
        let request: NSFetchRequest<Reserva> = Reserva.fetchRequest()
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("❌ Error al leer reservas: \(error)")
            return []
        }
    }
}
