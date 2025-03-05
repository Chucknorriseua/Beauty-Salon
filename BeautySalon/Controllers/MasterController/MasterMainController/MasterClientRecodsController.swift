//
//  MasterClientRecodsController.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 21/02/2025.
//

import SwiftUI

struct MasterClientRecodsController: View {
    
    @ObservedObject var masterVM = MasterViewModel.shared
    @EnvironmentObject var coordinator: CoordinatorView
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(masterVM.sheduleFromClient, id: \.self) { shedule in
                    RecordsFromClientCell(shedule: shedule)
                    }
                }
                .padding(.bottom, 8)
                Spacer()
            }
            .scrollIndicators(.hidden)
            .createBackgrounfFon()
        }
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                TabBarButtonBack {
                    coordinator.pop()
                }
            }
        })
    }
}

#Preview {
    MasterClientRecodsController(masterVM: MasterViewModel.shared)
}
