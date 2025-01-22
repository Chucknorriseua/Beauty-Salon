//
//  AdminChangeRecordsView.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 17/01/2025.
//

import SwiftUI

struct AdminChangeRecordsView: View {
    private let adaptiveColumn = [
        GridItem(.adaptive(minimum: 80))
    ]
    @StateObject var adminViewModel: AdminViewModel
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: adaptiveColumn, spacing: 4) {
                    ForEach(adminViewModel.procedure, id: \.id) { item in
                        VStack {
                            Button(action: {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    
                                    if let index = adminViewModel.procedure.firstIndex(of: item) {
                                        adminViewModel.procedure.remove(at: index)
                                    } else {
                                        adminViewModel.procedure.append(item)
                                    }
                                }
                            }, label: {
                                Text(item.title)
                                    .frame(width: 90, height: 60, alignment: .center)
                                    .background(Color(hex: "#3e5b47").opacity(0.6))
                                    .clipShape(.rect(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(adminViewModel.procedure.contains(item) ? Color.white : Color.clear, lineWidth: 2)
                                    )
                                    .foregroundColor(.white)
                                    .font(.system(size: 12))
                            })
                        }.padding(.all, 2)
                    }
                }
            }
        }
    }
}
