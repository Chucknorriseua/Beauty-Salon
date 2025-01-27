//
//  MasterProcedureCell.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 25/01/2025.
//

import SwiftUI

struct MasterProcedureCell: View {
    
    @State var procedure: Procedure
    @StateObject var masterVM: MasterViewModel
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(procedure.title)
                        .padding(.leading, 14)
                        .font(.system(size: 24, weight: .bold))
                    Text(procedure.description)
                        .fontWidth(.compressed)
                    HStack(spacing: 2) {
                        Spacer()
                        Text("price: ")
                        Text(procedure.price)
                            .foregroundStyle(Color.green.opacity(0.8))
                            .font(.system(size: 16, weight: .bold))
                    }
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
                })
            }.padding([.horizontal, .vertical], 10)
        }
        .background(.ultraThinMaterial.opacity(0.6))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.gray]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2
                )
        )
        .clipShape(.rect(cornerRadius: 12))
        .padding(.horizontal, 4)
        
    }
}
