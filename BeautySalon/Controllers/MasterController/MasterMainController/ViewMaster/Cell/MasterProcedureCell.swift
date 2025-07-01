//
//  MasterProcedureCell.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 25/01/2025.
//

import SwiftUI

struct MasterProcedureCell: View {
    
    @State var procedure: Procedure
    @ObservedObject var masterVM: MasterViewModel
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text(procedure.title)
                        .padding(.leading, 14)
                        .font(.system(size: 24, weight: .bold))
                    Text(procedure.description)
                        .font(.system(size: 16, weight: .heavy))
                        .fontWidth(.condensed)
                    HStack(spacing: 2) {
                        Spacer()
                        Text("price: ")
                        HStack {
                            Text(procedure.price)
                                .foregroundStyle(Color.blue)
                                .font(.system(size: 16, weight: .bold))
                                .padding(.all, 8)
                        }
                        .background(Color.white)
                        .clipShape(.rect(cornerRadius: 18))
                        
                    }
                    .offset(x: 20)
                }.foregroundStyle(Color.white)
                Spacer()
                Button(action: {
                    Task {
                        await masterVM.deleteCreateProcedure(procedureID: procedure)
                    }
                }, label: {
                    Image(systemName: "trash.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(Color.red.opacity(0.8))
                }).offset(x: 80)
            }.padding([.horizontal, .vertical], 10)
        }
        .setCellColor(radius: 12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.init(hex: "#58A6DA"), Color.white]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1
                )
        )
        .padding(.horizontal, 4)
        
    }
}
