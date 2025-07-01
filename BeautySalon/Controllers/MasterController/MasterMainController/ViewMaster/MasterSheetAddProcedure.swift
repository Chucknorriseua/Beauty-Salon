//
//  MasterSheetAddProcedure.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 25/01/2025.
//

import SwiftUI

struct MasterSheetAddProcedure: View {
    
    
    @ObservedObject var masterVM: MasterViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var price: String = ""
    @State private var description: String = ""
    
    var body: some View {
        VStack {
            Text("Create prise list")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.yellow)
            VStack {
                SettingsTextField(text: $title, title: "Procedure name", width: .infinity)
                SettingsTextField(text: $price, title: "Price", width: .infinity)
                    .keyboardType(.phonePad)
                ZStack(alignment: .topLeading) {
                    if description.isEmpty {
                        Text("Description, limit your input to 160 characters.")
                            .foregroundStyle(Color(hex: "F3E3CE").opacity(0.7))
                            .padding(.top, 4)
                            .padding(.leading, 4)
                          
                    }
                        TextEditor(text: $description)
                        .foregroundStyle(Color.white)
                            .scrollContentBackground(.hidden)

                }.frame(height: 120)
                    .overlay(content: {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white, lineWidth: 1)
                        })
                .padding(.horizontal, 14)
                CustomButton(title: "Create") {
                    Task {
                        let produced = Procedure(id: UUID().uuidString, title: title, price: price, image: "", colorText: "", description: description)
                        await masterVM.addNewProcedureFirebase(addProcedure: produced)
                        dismiss()
                    }
                }
            }
            Spacer()
        }
        .sheetColor()
        .ignoresSafeArea(.keyboard)
    }
}
