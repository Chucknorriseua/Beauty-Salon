//
//  AdminSelectNewProcedureView.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 17/01/2025.
//

import SwiftUI

struct AdminSelectNewProcedureView: View {
    
    private let adaptiveColumn = [
        GridItem(.adaptive(minimum: 100))
    ]
    @StateObject var adminViewModel = AdminViewModel()
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
                    ForEach(adminViewModel.adminProfile.procedure, id: \.id) { item in
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.5)) {
                                Task {
                                  await adminViewModel.addNewProcedure(addProcedure: item)
                                }
                                if adminViewModel.procedure.contains(item) {
                                    adminViewModel.procedure.removeAll {$0 == item}
                                    } else {
                                        adminViewModel.procedure.append(item)
                                    }
                                
                            }
                            addProcedure = true
                            onSelected()
                        }, label: {
                            Text(String(item.title))
                                .frame(width: 110, height: 44, alignment: .center)
                                .background(adminViewModel.procedure.contains(item) ? Color.gray.opacity(0.2) : Color.init(hex: "#3e5b47").opacity(0.6))
                                .cornerRadius(16)
                                .foregroundColor(.white)
                                .font(.system(size: 12, weight: .heavy))
                        })
                        
                    }
                }
            }
        }.frame(maxWidth: .infinity, maxHeight: 220)
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 16))
      
    }
}
