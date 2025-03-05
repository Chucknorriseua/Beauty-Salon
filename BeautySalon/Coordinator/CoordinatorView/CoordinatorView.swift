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
    case Admin_Register, Admin_main, Admin_Desc_Pass, Admin_MapInfo, Admin_Charts, Admin_creatPrice, Admin_HomeCare
// MARK: MASTER VIEW CONTROLLER
    case Master_Register, Master_Main, Master_Select_Company, Master_upDateProfile, Master_CreatePriceList, Maste_MapInfo, Master_Charts, Master_Shedule
//MARK: USER VIEW CONTROLLER
    case User_Register, User_Main, User_Settings, User_SheduleAdmin, User_Favorites, User_PriceList
    
    case google, apple

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
            NavigationView {
                
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
                    Admin_MainTabbedView()
                case .Admin_Desc_Pass:
                    AdminReg_Desc_Password()
                case .Admin_MapInfo:
                    MapViewInfo()
                case .Admin_Charts:
                    ChartsMonthly()
                case .Admin_creatPrice:
                    AdminCreatePriceList()
                case .Admin_HomeCare:
                    Admin_HomeCare()
                
                    //                MARK: MASTER CONTROLLER----------------------------------------
                case .Master_Register:
                    MasterRegister()
                case .Master_Main:
                    MasterTabBar(masterViewModel: MasterViewModel.shared, VmCalendar: MasterCalendarViewModel.shared)
                case .Master_Select_Company:
                    MasterSelectedCompany()
                case .Master_upDateProfile:
                    MasterUploadProfile()
                case .Master_CreatePriceList:
                    MasterCreatPriceList()
                case .Maste_MapInfo:
                    MapInfoMasterView()
                case .Master_Charts:
                    ChartsMonthlyMaster()
                case .Master_Shedule:
                    MasterClientRecodsController()
                    
                    //                MARK: USER CONTROLLER----------------------------------------
                case .User_Register:
                    UserRegisters()
                case .User_Main:
                    UserSelectedComapnyController(clientViewModel: ClientViewModel.shared)
                case .User_Settings:
                    UserSettings()
                case .User_SheduleAdmin:
                    UserMainForSheduleController(clientViewModel: ClientViewModel.shared)
                case .User_Favorites:
                    User_MyFavorites()
                case .User_PriceList:
                    User_PriceList()
                case .google:
                    GoogleRegisterProfile()
           
                case .apple:
                    AppleRegisterView()
                }
             
            }.navigationBarBackButtonHidden(true)
               
        }
    
}
