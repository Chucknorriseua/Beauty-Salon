//
//  User_SelectProcedureCell.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 13/01/2025.
//

import SwiftUI

struct User_SelectProcedureCell: View {
    
    private let adaptiveColumn = [
        GridItem(.adaptive(minimum: 100))
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
                                }
                                .frame(width: 100, height: 50, alignment: .center)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedProcedures.contains(item) ? Color.clear : Color.white, lineWidth: 2)
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
