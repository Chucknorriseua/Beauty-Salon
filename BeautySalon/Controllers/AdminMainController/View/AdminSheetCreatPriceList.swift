//
//  AdminSheetCreatPriceList.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 12/01/2025.
//

import SwiftUI

struct AdminSheetCreatPriceList: View {
    
    
    @StateObject var adminViewModel: AdminViewModel
    @Environment (\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var price: String = ""
    @State private var description: String = ""
    
    var body: some View {
        VStack {
            Text("Create prise list")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.yellow.opacity(0.9))
            VStack {
                SettingsButton(text: $title, title: "Procedure name", width: .infinity)
                SettingsButton(text: $price, title: "Price", width: .infinity)
                ZStack(alignment: .topLeading) {
                    if description.isEmpty {
                        Text("Description, limit your input to 160 characters.")
                            .foregroundStyle(Color(hex: "F3E3CE").opacity(0.7))
                            .padding(.top, 4)
                            .padding(.leading, 4)
                    }
                        TextEditor(text: $description)
                            .scrollContentBackground(.hidden)

                }.frame(height: 120)
                .background(.ultraThinMaterial.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 14)
                CustomButton(title: "Create") {
                    Task {
                        let produced = Procedure(id: UUID().uuidString, title: title, price: price, description: description)
                        await adminViewModel.addNewProcedure(addProcedure: produced)
                        dismiss()
                    }
                }
            }
            Spacer()
        }.background(Color.init(hex: "#3e5b47").opacity(0.8))
    }
}

#Preview {
    AdminSheetCreatPriceList(adminViewModel: AdminViewModel.shared)
}
