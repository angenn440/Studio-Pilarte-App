//
//  SwiftUIView.swift
//  Pilarte App
//
//  Created by Alumno on 25/04/25.
//

import SwiftUI

struct PaymentMethods: View {
    @StateObject public var viewModel = PaymentMethodsViewModel()
    @State public var showingAddCard = false
    @State public var showingDeleteAlert = false
    @State public var cardToDelete: PaymentMethod?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("Background").ignoresSafeArea()
                
                if viewModel.paymentMethods.isEmpty {
                    emptyStateView
                } else {
                    cardsListView
                }
            }
            .navigationTitle("Métodos de Pago")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCard = true }) {
                        Image(systemName: "plus")
                            .font(.headline)
                    }
                }
            }
            .sheet(isPresented: $showingAddCard) {
                AddPaymentMethodView { newCard in
                    viewModel.addPaymentMethod(newCard)
                }
            }
            .alert("Eliminar Tarjeta", isPresented: $showingDeleteAlert) {
                Button("Eliminar", role: .destructive) {
                    if let card = cardToDelete {
                        viewModel.deletePaymentMethod(card)
                    }
                }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("¿Estás seguro de que quieres eliminar esta tarjeta?")
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "creditcard.fill")
                .font(.system(size: 60))
                .foregroundColor(Color("Green").opacity(0.3))
            
            Text("No tienes métodos de pago")
                .font(.title3)
                .fontWeight(.medium)
            
            Text("Agrega una tarjeta para realizar pagos rápidamente")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, 40)
            
            Button(action: { showingAddCard = true }) {
                Label("Agregar Tarjeta", systemImage: "plus")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("Green"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
        }
    }
    
    private var cardsListView: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(viewModel.paymentMethods) { card in
                    CardView(card: card)
                        .contextMenu {
                            Button(role: .destructive) {
                                cardToDelete = card
                                showingDeleteAlert = true
                            } label: {
                                Label("Eliminar", systemImage: "trash")
                            }
                        }
                        .padding(.horizontal)
                }
                
                Button(action: { showingAddCard = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Agregar otra tarjeta")
                    }
                    .foregroundColor(Color("Green"))
                    .padding()
                }
            }
            .padding(.vertical)
        }
    }
}


struct CardView: View {
    let card: PaymentMethod
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(card.cardType.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30)
                
                Spacer()
                
                if card.isDefault {
                    Text("PREDETERMINADA")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(4)
                        .background(Color("Green").opacity(0.2))
                        .cornerRadius(4)
                }
            }
            
            Text(card.cardNumber.formattedCardNumber())
                .font(.title2)
                .fontWeight(.medium)
                .tracking(2)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Titular")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(card.cardholderName.uppercased())
                        .font(.subheadline)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Vence")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(card.expiryDate)
                        .font(.subheadline)
                }
                
                Spacer()
            }
            .padding(.top, 5)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color("White").opacity(0.0), Color("Black").opacity(0)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct AddPaymentMethodView: View {
    @Environment(\.dismiss) var dismiss
    var onSave: (PaymentMethod) -> Void
    
    @State private var cardholderName = ""
    @State private var cardNumber = ""
    @State private var expiryDate = ""
    @State private var cvv = ""
    @State private var isDefault = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nombre del titular", text: $cardholderName)
                        .textContentType(.name)
                    
                    TextField("Número de tarjeta", text: $cardNumber)
                        .keyboardType(.numberPad)
                        .onChange(of: cardNumber) { newValue in
                            cardNumber = newValue.filter { $0.isNumber }
                            if cardNumber.count > 16 {
                                cardNumber = String(cardNumber.prefix(16))
                            }
                        }
                    
                    HStack {
                        TextField("MM/AA", text: $expiryDate)
                            .keyboardType(.numbersAndPunctuation)
                            .onChange(of: expiryDate) { newValue in
                                let filtered = newValue.filter { $0.isNumber }
                                if filtered.count > 4 {
                                    expiryDate = String(filtered.prefix(4))
                                } else {
                                    expiryDate = filtered
                                }
                                
                                if expiryDate.count > 2 {
                                    let index = expiryDate.index(expiryDate.startIndex, offsetBy: 2)
                                    expiryDate.insert("/", at: index)
                                }
                            }
                        
                        TextField("CVV", text: $cvv)
                            .keyboardType(.numberPad)
                            .onChange(of: cvv) { newValue in
                                cvv = newValue.filter { $0.isNumber }
                                if cvv.count > 3 {
                                    cvv = String(cvv.prefix(3))
                                }
                            }
                            .frame(width: 80)
                    }
                }
                
                Section {
                    Toggle("Establecer como predeterminada", isOn: $isDefault)
                }
                
                Section {
                    Button("Agregar Tarjeta") {
                        let cardType = detectCardType(cardNumber: cardNumber)
                        let newCard = PaymentMethod(
                            id: UUID().uuidString,
                            cardholderName: cardholderName,
                            cardNumber: cardNumber,
                            expiryDate: expiryDate,
                            cardType: cardType,
                            isDefault: isDefault
                        )
                        onSave(newCard)
                        dismiss()
                    }
                    .disabled(!formIsValid)
                }
            }
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
    
    private var formIsValid: Bool {
        !cardholderName.isEmpty &&
        cardNumber.count >= 15 && 
        expiryDate.count == 5 &&
        cvv.count >= 3
    }
    
    private func detectCardType(cardNumber: String) -> CardType {
        if cardNumber.starts(with: "4") {
            return .visa
        } else if cardNumber.starts(with: "5") {
            return .mastercard
        } else if cardNumber.starts(with: "34") || cardNumber.starts(with: "37") {
            return .amex
        } else if cardNumber.starts(with: "3") {
            return .jcb
        } else {
            return .unknown
        }
    }
}


struct PaymentMethod: Identifiable, Equatable {
    let id: String
    let cardholderName: String
    let cardNumber: String
    let expiryDate: String
    let cardType: CardType
    var isDefault: Bool
}

enum CardType {
    case visa
    case mastercard
    case amex
    case jcb
    case unknown
    
    var iconName: String {
        switch self {
        case .visa: return "visa"
        case .mastercard: return "mastercard"
        case .amex: return "amex"
        case .jcb: return "jcb"
        case .unknown: return "creditcard"
        }
    }
    
    var cvvLength: Int {
        self == .amex ? 4 : 3
    }
}

class PaymentMethodsViewModel: ObservableObject {
    @Published var paymentMethods: [PaymentMethod] = [
        PaymentMethod(
            id: "1",
            cardholderName: "Ana Rodríguez",
            cardNumber: "4111111111111111",
            expiryDate: "12/25",
            cardType: .visa,
            isDefault: true
        ),
        PaymentMethod(
            id: "2",
            cardholderName: "Ana Rodríguez",
            cardNumber: "5555555555554444",
            expiryDate: "05/24",
            cardType: .mastercard,
            isDefault: false
        )
    ]
    
    func addPaymentMethod(_ method: PaymentMethod) {
        var newMethods = paymentMethods
        if method.isDefault {
            newMethods = newMethods.map { var m = $0; m.isDefault = false; return m }
        }
        newMethods.append(method)
        paymentMethods = newMethods
    }
    
    func deletePaymentMethod(_ method: PaymentMethod) {
        paymentMethods.removeAll { $0.id == method.id }
        if method.isDefault && !paymentMethods.isEmpty {
            paymentMethods[0].isDefault = true
        }
    }
}


extension String {
    func formattedCardNumber() -> String {
        let groups: [Int]
        if self.hasPrefix("34") || self.hasPrefix("37") {
            groups = [4, 6, 5]
        } else {
            groups = [4, 4, 4, 4]
        }
        
        var result = ""
        var index = self.startIndex
        
        for group in groups {
            if index >= self.endIndex { break }
            let end = self.index(index, offsetBy: min(group, self.distance(from: index, to: self.endIndex)))
            result += self[index..<end] + " "
            index = end
        }
        
        return result.trimmingCharacters(in: .whitespaces)
    }
}


#Preview {
    PaymentMethods()
}
