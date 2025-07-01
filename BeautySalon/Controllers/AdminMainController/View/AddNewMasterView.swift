//
//  AddNewMasterView.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 10/01/2025.
//

import SwiftUI
import SDWebImageSwiftUI
import MapKit

struct AddNewMasterView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImage: String? = nil
    @State private var isPressFullScreen: Bool = false
    @State var isShowButtonAdd: Bool = false
    @State private var isShowProcedure: Bool = false
    @State var isShowPricelist: Bool = false
    @State var addMasterInRoom: MasterModel
    @State var isShowMasterSend: Bool = false
    @State var isShowSendButton: Bool = false
    @State private var isShowSendShedule: Bool = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ScrollView {
                    VStack {
                        VStack {
                            VStack(alignment: .center, spacing: 10) {
                                Color.clear
                                    .createImageView(model: addMasterInRoom.image ?? "", width: geo.size.width * 0.8,
                                                     height: geo.size.height * 0.44)
                                    .overlay(alignment: .bottomLeading) {
                                        if isShowMasterSend {
                                            HStack(spacing: 16) {
                                                Button(action: { openInMaps()}) {
                                                    VStack {
                                                        Image(systemName: "location.fill.viewfinder")
                                                            .font(.system(size: 32))
                                                            .foregroundStyle(Color.white)
                                                    }
                                                }
                                                
                                                Button(action: {
                                                    Task {
                                                        await ClientViewModel.shared.addMyFavoritesMaster(master: addMasterInRoom)
                                                    }
                                                }) {
                                                    VStack {
                                                        Image(systemName: "bookmark.circle.fill")
                                                            .font(.system(size: 32))
                                                            .foregroundStyle(Color.yellow)
                                                    }
                                                }
                                            }
                                            .offset(y: 16)
                                        }
                                    }
                                    .overlay(alignment: .bottomTrailing) {
                                        if isShowMasterSend {
                                            Button(action: {
                                                Task {
                                                    do {
                                                        try await Client_DataBase.shared.favoritesLikeMasters(masterID: addMasterInRoom.masterID, userID: ClientViewModel.shared.clientModel.id)
                                                    } catch {
                                                        print(error.localizedDescription)
                                                    }
                                                }
                                            }) {
                                        
                                                HStack(spacing: 6) {
                                                    Image(systemName: "heart.fill")
                                                        .foregroundStyle(Color.red)
                                                        .font(.system(size: 30))
                                                    Text("\(addMasterInRoom.likes)")
                                                        .foregroundStyle(Color.white)
                                                        .fontWeight(.bold)
                                                        .font(.system(size: 14))
                                                }
                                            }
                                            .offset(y: 10)
                                        }
                                    }
                                VStack(spacing: 10) {
                                    Text(addMasterInRoom.name)
                                        .font(.system(size: 28, weight: .bold))
                                        .fontDesign(.monospaced)
                                    
                                    Text(addMasterInRoom.phone)
                                        .font(.system(size: 18, weight: .bold))
                                        .onTapGesture {
                                            let phoneNumber = "tel://" + addMasterInRoom.phone
                                            if let url = URL(string: phoneNumber) {
                                                UIApplication.shared.open(url)
                                            }
                                        }
                                }
                                
                                VStack {
                                    ScrollView(.horizontal) {
                                        LazyHStack {
                                            
                                            ForEach(addMasterInRoom.imagesUrl ?? [], id: \.self) { master in
                                                HStack {
                                                    
                                                    if let url = URL(string: master) {
                                                        
                                                        WebImage(url: url)
                                                            .resizable()
                                                            .indicator(.activity)
                                                            .aspectRatio(contentMode: .fill)
                                                            .frame(width: geo.size.width * 0.26,
                                                                   height: geo.size.height * 0.14)
                                                            .clipShape(Circle())
                                                            .clipped()
                                                            .overlay(content: {
                                                                Circle()
                                                                    .stroke(Color.white, lineWidth: 2)
                                                            })
                                                            .onTapGesture {
                                                                withAnimation(.snappy(duration: 0.5)) {
                                                                    selectedImage = master
                                                                    isPressFullScreen.toggle()
                                                                }
                                                            }
                                                        
                                                    }
                                                }.id(master)
                                                    .padding(.horizontal, 4)
                                                
                                            }
                                            
                                        }.scrollTargetLayout()
                                    }.scrollIndicators(.hidden)
                                        .frame(width: geo.size.width * 0.96, height: geo.size.height * 0.16)
                                    
                                    VStack(alignment: .leading) {
                                        
                                        Text(addMasterInRoom.description)
                                            .font(.system(size: 18, weight: .heavy))
                                            .fontDesign(.serif)
                                            .multilineTextAlignment(.leading)
                                        
                                    }
                                    .padding(.horizontal, 6)
                                    .padding(.bottom, 60)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 30)
                    .padding(.top, 60)
                }
                .createBackgrounfFon()
                .overlay(alignment: .bottom, content: {
                    VStack {
                        
                        if isShowButtonAdd {
                            CustomButton(title: "Add") {
                                Task {
                                    let addMaster = MasterModel(id: addMasterInRoom.id, masterID: addMasterInRoom.masterID, roleMaster: addMasterInRoom.roleMaster, name: addMasterInRoom.name, email: addMasterInRoom.email, phone: addMasterInRoom.phone, adress: addMasterInRoom.adress, description: addMasterInRoom.description, image: addMasterInRoom.image, imagesUrl: addMasterInRoom.imagesUrl, categories: addMasterInRoom.categories, masterMake: addMasterInRoom.masterMake, fcnTokenUser: addMasterInRoom.fcnTokenUser, likes: addMasterInRoom.likes, procedure: [], latitude: addMasterInRoom.latitude, longitude: addMasterInRoom.longitude)
                                    
                                    await AdminViewModel.shared.add_MasterToRoom(masterID: addMaster.id, master: addMaster)
                                    
                                    let titleEnter = String(
                                        format: NSLocalizedString("addMaster", comment: ""), addMasterInRoom.name)
                                    
                                    let subTitle = String(
                                        format: NSLocalizedString("addMasterTitle", comment: ""))
                                    
                                    NotificationController.sharet.notify(title: titleEnter, subTitle: subTitle, timeInterval: 2)
                                }
                            }
                        }
                        if isShowSendButton {
                            CustomButton(title: "Sign up") {
                                isShowSendShedule = true
                            }
                        }
                    }
                    .padding(.bottom, 30)
                })
                .scrollIndicators(.hidden)
                
                .foregroundStyle(Color.white)
                .sheet(isPresented: $isShowProcedure, content: {
                    User_MasterPriceList(masterPrice: addMasterInRoom)
                        .presentationDetents([.height(600)])
                })
                .sheet(isPresented: $isShowSendShedule, content: {
                    User_SheetSheduleMasterHome(masterModel: addMasterInRoom)
                        .presentationDetents([.height(600)])
                })
                .swipeBackDismiss(dismiss: dismiss)
                .imageViewSelected(isPressFullScreen: $isPressFullScreen, selectedImage: selectedImage ?? "", isShowTrash: false, deleteImage: {})
                .ignoresSafeArea(.all)
                .toolbar(content: {
                    ToolbarItem(placement: .topBarLeading) {
                        if !isPressFullScreen {
                            TabBarButtonBack {
                                dismiss()
                            }
                        } else {
                            Text("")
                        }
                    }
                })
                
                .toolbar(content: {
                    if isShowPricelist {
                        ToolbarItem(placement: .topBarTrailing) {
                            if !isShowProcedure && !isPressFullScreen {
                                Button(action: {
                                    isShowProcedure = true
                                }, label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "list.bullet.circle")
                                            .font(.system(size: 28))
                                            .foregroundStyle(Color.yellow)
                                    }
                                })
                            } else {
                                Text("")
                            }
                        }
                    }
                })
            }
        }
    }
    private func openInMaps() {
        guard let longitude = addMasterInRoom.longitude, let latitude = addMasterInRoom.latitude else { return }
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)))
        mapItem.name = "We're here"
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving
                                          ])
    }
}

#Preview(body: {
    AddNewMasterView(addMasterInRoom: MasterModel.masterModel(), isShowMasterSend: true)
})
