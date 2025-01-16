//
//  CoordinatorView.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 28/08/2024.
//

import SwiftUI

enum PageAll: String, Identifiable {
    
// MARK: Main controller Sign In or Main Register Profile
    case main, Main_Reg_Profile
// MARK: ADMIN VIEW CONTROLLER
    case Admin_Register, Admin_main, Admin_Desc_Pass, Admin_CreatPriseList
// MARK: MASTER VIEW CONTROLLER
    case Master_Register, Master_Main, Master_Select_Company, Master_upDateProfile
//MARK: USER VIEW CONTROLLER
    case User_Register, User_Main, User_Settings, User_SheduleAdmin
    
    case google

    var id: String {
        self.rawValue
    }
}

final class CoordinatorView: ObservableObject {
    
    @Published var path: NavigationPath = .init()
    
    
    func push(page: PageAll) {
        path.append(page)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }

    @ViewBuilder
        func Adminbuild(page: PageAll) -> some View {
            NavigationView(content: {
                
                switch page {
                    //                MARK: MAIN CONTROLLER----------------------------------------
                case .main:
                    MainCoordinator()
                case .Main_Reg_Profile:
                    Main_Controller_Register()
                    
                    //                MARK: ADMIN CONTROLLER----------------------------------------
                case .Admin_Register:
                    AdminRegister()
                case .Admin_main:
                    Admin_MainTabbedView(adminViewModel: AdminViewModel.shared)
                case .Admin_Desc_Pass:
                    AdminReg_Desc_Password(adminViewModel: AdminViewModel.shared)
                case .Admin_CreatPriseList:
                    AdminCreatePriceList(adminViewModel: AdminViewModel.shared)
                    
                    //                MARK: MASTER CONTROLLER----------------------------------------
                case .Master_Register:
                    MasterRegister()
                case .Master_Main:
                    MasterTabBar(masterViewModel: MasterViewModel.shared, VmCalendar: MasterCalendarViewModel.shared)
                case .Master_Select_Company:
                    MasterSelectedCompany(masterViewModel: MasterViewModel.shared)
                case .Master_upDateProfile:
                    MasterUploadProfile(masterViewModel: MasterViewModel.shared)
                    
                    //                MARK: USER CONTROLLER----------------------------------------
                case .User_Register:
                    UserRegisters()
                case .User_Main:
                    UserSelectedComapnyController(clientViewModel: ClientViewModel.shared)
                case .User_Settings:
                    UserSettings(clientViewModel: ClientViewModel.shared)
                case .User_SheduleAdmin:
                    UserMainForSheduleController(clientViewModel: ClientViewModel.shared)
                    
                case .google:
                    GoogleRegisterProfile()
                }
            }).navigationBarBackButtonHidden(true)
               
        }
    
}
