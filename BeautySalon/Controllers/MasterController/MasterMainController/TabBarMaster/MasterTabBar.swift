//
//  MasterTabBar.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 21/08/2024.
//


import SwiftUI
enum TabbedItemsMaster: Int, CaseIterable{
    case home = 0
    case info
    case settingProf
    
    var title: String{
        switch self {
        case .home:
            return "Home".localized
        case .info:
            return "Client".localized
        case .settingProf:
            return "Settings".localized
        }
    }
    
    var iconName: String{
        switch self {
        case .home:
            return "house.circle.fill"
        case .info:
            return  "person.circle.fill"
        case .settingProf:
            return "gear"
        }
    }
}

struct MasterTabBar: View {
    
    @State private var selectedTab = 0
    @StateObject var masterViewModel: MasterViewModel
    @StateObject var VmCalendar: MasterCalendarViewModel
    @State private var isPressFullScreen: Bool = false
    
    var body: some View {

        ZStack(alignment: .bottom) {
            ZStack {
                switch selectedTab {
                case 0:
                    MasterMainController(masterViewModel: masterViewModel, VmCalendar: VmCalendar)
                case 1:
                    ClientForMastrer(masterViewModel: MasterViewModel.shared)
                case 2:
                    SettingsMaster(masterViewModel: masterViewModel, isPressFullScreen: $isPressFullScreen)
                default:
                    MasterMainController(masterViewModel: masterViewModel, VmCalendar: VmCalendar)
                }
            }.toolbarBackground(.hidden, for: .tabBar)

            ZStack {
                HStack{
                    ForEach((TabbedItemsMaster.allCases), id: \.self) { item in
                            Button {
                                withAnimation(.snappy(duration: 0.7)) {
                                    selectedTab = item.rawValue
                                }
                            } label: {
                                
                                CustomTabItem(imageName: item.iconName, title: item.title, isActive: (selectedTab == item.rawValue))
                            }
                    }
                }
                .padding(6)
            }
            .frame(height: 70)
            .background(.ultraThinMaterial)
            .opacity(isPressFullScreen ? 0 : 1)
            .cornerRadius(35)
            .padding(.horizontal, 26)
        }.ignoresSafeArea(.keyboard)
    }
}

extension MasterTabBar{
    func CustomTabItem(imageName: String, title: String, isActive: Bool) -> some View{
        HStack(spacing: 10){
            Spacer()
            Image(systemName: imageName)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(isActive ? .black : .gray)
                .frame(width: 20, height: 20)
            if isActive{
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(isActive ? .black : .gray)
            }
            Spacer()
        }
        .frame(width: isActive ? 120 : 60, height: 60)
        .background(isActive ? .white.opacity(0.6) : .clear)
        .cornerRadius(30)
    }
}
