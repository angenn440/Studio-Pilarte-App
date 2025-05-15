//
//  PaquetesView.swift
//  Pilarte App
//
//  Created by Alumno on 25/04/25.
//

import SwiftUI

struct PilatesPlansView: View {
    @StateObject private var viewModel = PilatesPlansViewModel()
    @State private var selectedPlan: PilatesPlan?
    @State private var showingPayment = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        Text("Elige tu paquete")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Compra clases al por mayor y ahorra")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    ForEach(viewModel.plans) { plan in
                        PlanCard(
                            plan: plan,
                            isSelected: selectedPlan?.id == plan.id
                        ) {
                            selectedPlan = plan
                        }
                        .padding(.horizontal)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Beneficios exclusivos")
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        BenefitRow(icon: "calendar", text: "Clases programables a tu conveniencia")
                        BenefitRow(icon: "arrow.clockwise", text: "Reprogramación sin costo")
                        BenefitRow(icon: "person.2.fill", text: "Acceso a clases grupales")
                        BenefitRow(icon: "gift.fill", text: "Descuentos en productos")
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    if let selectedPlan = selectedPlan {
                        Button(action: {
                            showingPayment = true
                        }) {
                            HStack {
                                Text("Comprar ahora")
                                    .fontWeight(.bold)
                                Spacer()
                                Text(selectedPlan.price)
                                    .fontWeight(.bold)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("Green"))
                            .foregroundColor(Color("Principal"))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                }
                .padding(.bottom, 30)
            }
            .background(Color("Primcipal").ignoresSafeArea())
            .navigationTitle("Planes")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingPayment) {
                if let plan = selectedPlan {
                    PaymentView(plan: plan)
                }
            }
        }
    }
}

struct PilatesPlan: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let classCount: Int
    let price: String
    let description: String
    let savings: Int?
    
    static func == (lhs: PilatesPlan, rhs: PilatesPlan) -> Bool {
        return lhs.id == rhs.id
    }
}

class PilatesPlansViewModel: ObservableObject {
    @Published var plans: [PilatesPlan] = [
        PilatesPlan(
            name: "Paquete Básico",
            classCount: 1,
            price: "$350",
            description: "Perfecto para probar nuestras clases",
            savings: nil
        ),
        PilatesPlan(
            name: "Paquete Plata",
            classCount: 5,
            price: "$1,500",
            description: "Ideal para practicar 1 vez por semana",
            savings: 15
        ),
        PilatesPlan(
            name: "Paquete Oro",
            classCount: 10,
            price: "$2,800",
            description: "Recomendado para 2 clases por semana",
            savings: 20
        ),
        PilatesPlan(
            name: "Paquete Platino",
            classCount: 15,
            price: "$3,900",
            description: "Para practicantes regulares (3 clases/semana)",
            savings: 25
        ),
        PilatesPlan(
            name: "Paquete Diamante",
            classCount: 20,
            price: "$4,800",
            description: "Máximo ahorro para practicantes intensivos",
            savings: 30
        )
    ]
}

struct PlanCard: View {
    let plan: PilatesPlan
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 15) {
                HStack {
                    Text(plan.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text(plan.price)
                        .font(.title3)
                        .fontWeight(.heavy)
                        .foregroundColor(Color("Green"))
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(plan.classCount) clases")
                            .font(.headline)
                        
                        Text(plan.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        if let savings = plan.savings {
                            Text("Ahorras \(savings)%")
                                .font(.caption)
                                .padding(5)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(Color("Green"))
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color("Text") : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct BenefitRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(Color("Text"))
                .frame(width: 24)
            Text(text)
            Spacer()
        }
    }
}

struct PaymentView: View {
    let plan: PilatesPlan
    @Environment(\.dismiss) var dismiss
    @State private var showConfirmation = false
    @State private var selectedPaymentMethod: String = ""
    @State private var showingAddCardView = false

    let paymentMethods = ["Visa **** 1234", "MasterCard **** 5678", "Amex **** 9012"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Resumen de compra")
                    .font(.title2)
                    .padding(.top)

                VStack(spacing: 15) {
                    HStack {
                        Text("Paquete:")
                        Spacer()
                        Text(plan.name)
                            .fontWeight(.medium)
                    }

                    HStack {
                        Text("Clases incluidas:")
                        Spacer()
                        Text("\(plan.classCount)")
                            .fontWeight(.medium)
                    }

                    if let savings = plan.savings {
                        HStack {
                            Text("Ahorro:")
                            Spacer()
                            Text("\(savings)%")
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                        }
                    }

                    HStack {
                        Text("Total:")
                        Spacer()
                        Text(plan.price)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color("Green"))
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Selecciona un método de pago")
                        .font(.headline)

                    ForEach(paymentMethods, id: \.self) { method in
                        Button(action: {
                            selectedPaymentMethod = method
                        }) {
                            HStack {
                                Text(method)
                                    .fontWeight(.medium)
                                Spacer()
                                if selectedPaymentMethod == method {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color("Green"))
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedPaymentMethod == method ? Color("Green").opacity(0.2) : Color(.systemBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedPaymentMethod == method ? Color("Green") : Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    Button(action: {
                        showingAddCardView = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Agregar tarjeta")
                        }
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("Green").opacity(0.2))
                        .foregroundColor(Color("Green"))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)

                Spacer()

                Button(action: {
                    if !selectedPaymentMethod.isEmpty {
                        PurchaseManager.shared.savePlan(plan)
                        showConfirmation = true
                    }
                }) {
                    Text("Confirmar compra")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedPaymentMethod.isEmpty ? Color.gray : Color("Text"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(selectedPaymentMethod.isEmpty)
                .alert("Compra exitosa", isPresented: $showConfirmation) {
                    Button("OK") { dismiss() }
                } message: {
                    Text("Has adquirido el paquete \(plan.name) con \(selectedPaymentMethod) exitosamente.")
                }
            }
            .padding()
            .navigationTitle("Pagar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddCardView) {
                AddCardView()
            }
        }
    }
}

struct AddCardView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                Text("Agregar Tarjeta")
                    .font(.title)
                    .padding()

                Spacer()

                Button("Guardar") {
                    dismiss()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color("Green"))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Nueva Tarjeta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
    }
}
struct PilatesPlansView_Previews: PreviewProvider {
    static var previews: some View {
        PilatesPlansView()
    }
}
