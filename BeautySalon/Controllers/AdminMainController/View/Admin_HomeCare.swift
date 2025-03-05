//
//  Admin_HomeCare.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 25/02/2025.
//

import SwiftUI

struct Admin_HomeCare: View {
    
    
    @EnvironmentObject var coordinator: CoordinatorView
    @ObservedObject private var adminViewModel = AdminViewModel.shared
    @State private var isShowSheet: Bool = false
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(adminViewModel.createHomeCare, id: \.self) { homeCare in
                        VStack {
                            HomeCareCell(homeCare: homeCare, isShow: true)
                        }
                        .padding(.bottom, 10)
                    }
                }
            }
            .onAppear {
                Task {
                    await adminViewModel.fetchHomeCareProduct()
                }
            }
        }
        .createBackgrounfFon()
        .sheet(isPresented: $isShowSheet, content: {
            Admin_SheetAddHomeCare(adminVM: adminViewModel)
                .presentationDetents([.height(660)])
        })
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                TabBarButtonBack {
                    coordinator.pop()
                }
            }
            ToolbarItem(placement: .principal) {
            Text("Home care")
                    .foregroundStyle(Color.yellow)
                    .font(.system(size: 24))
                    .fontWeight(.bold)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    isShowSheet = true
                }, label: {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 26))
                        .foregroundStyle(Color.yellow.opacity(0.9))
                })
            }
        })
    }
}

#Preview {
    Admin_HomeCare()
}
