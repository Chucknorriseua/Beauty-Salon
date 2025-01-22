//
//  MainTabbedView.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 19/08/2024.
//

import SwiftUI
enum TabbedItems: Int, CaseIterable{
    case home = 0
    case client
    case info
    case settingProf
    
    var title: String{
        switch self {
        case .home:
            return "Home".localized
        case .client:
            return "Masters".localized
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
        case .client:
            return "person.2.circle.fill"
        case .info:
            return  "person.circle.fill"
        case .settingProf:
            return "gear"
        }
    }
}

struct Admin_MainTabbedView: View {
    
    @State private var selectedTab = 0
    @StateObject var adminViewModel: AdminViewModel

    
    var body: some View {
        
        ZStack(alignment: .bottom){
            VStack {
                
                switch selectedTab {
                case 0:
                    AdminMainController(admimViewModel: adminViewModel)
                case 1:
                    GetAllMastersInCompany(adminViewModel: adminViewModel)
                case 2:
                    GetAllUsersOfCompany(adminViewModel: adminViewModel)
                case 3:
                    SettingsAdminView(adminViewModel: adminViewModel)
                default:
                    AdminMainController(admimViewModel: adminViewModel)
                }
            }.toolbarBackground(.hidden, for: .tabBar)

            ZStack {
                HStack{
                    ForEach((TabbedItems.allCases), id: \.self){ item in
                        Button{
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
            .cornerRadius(35)
        }.ignoresSafeArea(.keyboard)
    }
}

extension Admin_MainTabbedView{
   private func CustomTabItem(imageName: String, title: String, isActive: Bool) -> some View{
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
        .frame(width: isActive ? 140 : 60, height: 60)
        .background(isActive ? .white.opacity(0.9) : .clear)
        .cornerRadius(30)
    }
}
