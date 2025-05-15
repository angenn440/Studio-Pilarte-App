//
//  File.swift
//  Pilarte App
//
//  Created by Alumno on 28/04/25.
//

import Foundation


class PurchaseManager {
    static let shared = PurchaseManager()
    private let userDefaults = UserDefaults.standard
    private let key = "purchasedPlans"
    
    func savePlan(_ plan: PilatesPlan) {
        var plans = getPlans()
        let planDict: [String: Any] = [
            "id": plan.id.uuidString,
            "name": plan.name,
            "classCount": plan.classCount,
            "price": plan.price,
            "description": plan.description,
            "savings": plan.savings ?? 0
        ]
        plans.append(planDict)
        userDefaults.set(plans, forKey: key)
    }
    
    func getPlans() -> [[String: Any]] {
        return userDefaults.array(forKey: key) as? [[String: Any]] ?? []
    }
    
    func removePlan(at index: Int) {
        var plans = getPlans()
        guard index >= 0 && index < plans.count else { return }
        plans.remove(at: index)
        userDefaults.set(plans, forKey: key)
    }
    
    func removePlan(withId id: UUID) {
        var plans = getPlans()
        plans.removeAll { $0["id"] as? String == id.uuidString }
        userDefaults.set(plans, forKey: key)
    }
}
