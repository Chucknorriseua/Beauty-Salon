//
//  User_SelectProcedureCell.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 13/01/2025.
//

import SwiftUI

struct User_SelectProcedureCell: View {
    private let adaptiveColumn = [
        GridItem(.adaptive(minimum: 86))
    ]
    @StateObject var clientViewModel: ClientViewModel
    @Binding var selectedProcedures: [Procedure]
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: adaptiveColumn, spacing: 4) {
                    ForEach(clientViewModel.procedure, id: \.self) { item in
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
                                VStack {
                                    Text(item.title)
                                        .foregroundColor(.white)
                                        .font(.system(size: 12, weight: .heavy))
                                    Text(String(item.price))
                                        .foregroundColor(.green.opacity(0.9))
                                        .font(.system(size: 12, weight: .bold))
                                }
                                .frame(width: 100, height: 50, alignment: .center)
                                .background(Color(hex: "#3e5b47").opacity(0.6))
                                .clipShape(.rect(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedProcedures.contains(item) ? Color.white : Color.clear, lineWidth: 2)
                                )
                            })
                        }.padding(.all, 4)
                    }
                }
            }
        }
    }
}
//#Preview {
//    User_SelectProcedureCell(clientViewModel: ClientViewModel.shared)
//}
