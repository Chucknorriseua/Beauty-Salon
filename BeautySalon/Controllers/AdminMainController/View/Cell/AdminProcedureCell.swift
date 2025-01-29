//
//  AdminProcedureCell.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 14/01/2025.
//

import SwiftUI

struct AdminProcedureCell: View {
    private let adaptiveColumn = [
        GridItem(.adaptive(minimum: 86))
    ]
    @ObservedObject var adminViewModel: AdminViewModel
    @Binding var selectedProcedures: [Procedure]
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: adaptiveColumn, spacing: 4) {
                    ForEach(adminViewModel.procedure, id: \.self) { item in
                        VStack {
                            Button(action: {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    
                                    if let index = selectedProcedures.firstIndex(of: item) {
                                        selectedProcedures.remove(at: index)
                                    } else {
                                        selectedProcedures.append(item)
                                    }
                                }
                            }, label: {
                                Text(item.title)
                                    .frame(width: 100, height: 50, alignment: .center)
                                    .background(Color(hex: "#3e5b47").opacity(0.6))
                                    .clipShape(.rect(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(selectedProcedures.contains(item) ? Color.white : Color.clear, lineWidth: 2)
                                    )
                                    .foregroundColor(.white)
                                    .font(.system(size: 12, weight: .heavy))
                            })
                        }.padding(.all, 4)
                    }
                }
            }
        }
    }
}
