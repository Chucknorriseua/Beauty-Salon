//
//  ProcedureCell.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 12/01/2025.
//

import SwiftUI

struct ProcedureCell: View {
    
    @State var procedure: Procedure
    @ObservedObject var adminViewModel: AdminViewModel
    
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
                    .offset(x: 40)
                }.foregroundStyle(Color.white)
                Button {
                    withAnimation(.easeOut) {
                        delete()
                    }
                } label: {
                    Image(systemName: "trash.square")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(Color.red)
                }.offset(x: 80)
                Spacer()
            }.padding(.vertical, 8)
                .padding(.leading, 4)
        }
        .setCellColor(radius: 12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.init(hex: "#58A6DA"), Color.white]),
                        startPoint: .top,
                        endPoint: .trailing
                    ),
                    lineWidth: 1
                )
        )
        .padding(.horizontal, 8)
    }
    private func delete() {
        Task {
            await adminViewModel.deleteCreateProcedure(procedureID: procedure)
        }
    }
}

#Preview {
    ProcedureCell(procedure: Procedure.procedureModel(), adminViewModel: AdminViewModel.shared)
}
