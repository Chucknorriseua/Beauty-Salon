//
//  User_MenuProcedureView.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 13/01/2025.
//

import SwiftUI

struct User_MenuProcedureView: View {
    
    private let adaptiveColumn = [
        GridItem(.adaptive(minimum: 100))
    ]
    @ObservedObject var clientViewModel: ClientViewModel
    @Binding var addProcedure: Bool
    @Binding var selectedProcedure: [Procedure]
    let onSelected: () -> ()
    
    var body: some View {
        VStack {
            Text("Selected procedure")
                .foregroundStyle(Color.white)
                .fontDesign(.serif)
                .fontWeight(.bold)
                .padding(.top, 6)
            ScrollView {
                LazyVGrid(columns: adaptiveColumn, spacing: 4) {
                    ForEach(clientViewModel.adminProfile.procedure, id: \.self) { item in
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.5)) {
                                clientViewModel.addNewProcedure(addProcedure: item)
                               
                                    if selectedProcedure.contains(item) {
                                        selectedProcedure.removeAll {$0 == item}
                                    } else {
                                        selectedProcedure.append(item)
                                    }
                                
                            }
                            addProcedure = true
                            onSelected()
                        }, label: {
                            VStack {
                                Text(String(item.title))
                                    .foregroundColor(.white)
                                    .font(.system(size: 12, weight: .heavy))
                            }.frame(width: 110, height: 60, alignment: .center)
                                .background(selectedProcedure.contains(item) ?  Color.clear : Color.gray.opacity(0.2))
                                .cornerRadius(16)
                        })
                        
                    }
                }
            }
        }.frame(maxWidth: .infinity, maxHeight: 280)
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 16))
      
    }
}

struct User_MenuProcedureForeMasterView: View {
    
    private let adaptiveColumn = [
        GridItem(.adaptive(minimum: 100))
    ]
    @ObservedObject var clientViewModel: ClientViewModel
    @Binding var addProcedure: Bool
    @Binding var selectedProcedure: [Procedure]
    @State var masterModel: MasterModel
    let onSelected: () -> ()
    
    var body: some View {
        VStack {
            Text("Selected procedure")
                .foregroundStyle(Color.white)
                .fontDesign(.serif)
                .fontWeight(.bold)
                .padding(.top, 6)
            ScrollView {
                LazyVGrid(columns: adaptiveColumn, spacing: 4) {
                    ForEach(masterModel.procedure, id: \.self) { item in
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.5)) {
                                clientViewModel.addNewProcedure(addProcedure: item)
                               
                                    if selectedProcedure.contains(item) {
                                        selectedProcedure.removeAll {$0 == item}
                                    } else {
                                        selectedProcedure.append(item)
                                    }
                                
                            }
                            addProcedure = true
                            onSelected()
                        }, label: {
                            VStack {
                                Text(String(item.title))
                                    .foregroundColor(.white)
                                    .font(.system(size: 12, weight: .heavy))
                            }.frame(width: 110, height: 60, alignment: .center)
                                .background(selectedProcedure.contains(item) ?  Color.clear : Color.gray.opacity(0.2))
                                .cornerRadius(16)
                        })
                        
                    }
                }
            }
        }.frame(maxWidth: .infinity, maxHeight: 280)
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 16))
      
    }
}
