//
//  AdminMenuProcedureView.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 14/01/2025.
//

import SwiftUI

struct AdminMenuProcedureView: View {
    
    private let adaptiveColumn = [
        GridItem(.adaptive(minimum: 100))
    ]
    @ObservedObject var adminViewModel: AdminViewModel
    @Binding var addProcedure: Bool
    let onSelected: () -> ()
    
    var body: some View {
        VStack {
            Text("Selected procedure")
                .foregroundStyle(Color.yellow)
                .fontDesign(.serif)
                .fontWeight(.bold)
                .padding(.top, 6)
            ScrollView {
                LazyVGrid(columns: adaptiveColumn, spacing: 4) {
                    ForEach(adminViewModel.adminProfile.procedure, id: \.self) { item in
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.5)) {
                                deleteProcedure(procedure: item)
                            }
                            addProcedure = true
                            onSelected()
                        }, label: {
                            Text(String(item.title))
                                .frame(width: 110, height: 44, alignment: .center)
                                .background(Color.init(hex: "#3e5b47").opacity(0.6))
                                .cornerRadius(16)
                                .foregroundColor(.white)
                                .font(.system(size: 12))
                        }).clipped()
                        
                    }
                }
            }
        }.frame(maxWidth: .infinity, maxHeight: 220)
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 16))
      
    }
    
    func deleteProcedure(procedure: Procedure) {
        Task {
            await adminViewModel.addNewProcedure(addProcedure: procedure)
        }
    }
}
