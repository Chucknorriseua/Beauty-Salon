//
//  AdminChangeRecordsView.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 17/01/2025.
//

import SwiftUI

struct AdminChangeRecordsView: View {
    private let adaptiveColumn = [
        GridItem(.adaptive(minimum: 100))
    ]
    @ObservedObject var adminViewModel: AdminViewModel
    
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
                                    .frame(width: 110, height: 60, alignment: .center)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(adminViewModel.procedure.contains(item) ? Color.white : Color.clear, lineWidth: 2)
                                    )
                                    .foregroundColor(.white)
                                    .font(.system(size: 12, weight: .heavy))
                            })
                        }.padding(.all, 2)
                    }
                }
            }
        }
    }
}
