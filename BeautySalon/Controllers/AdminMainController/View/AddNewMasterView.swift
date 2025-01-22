//
//  AddNewMasterView.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 10/01/2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct AddNewMasterView: View {
    
    @Environment (\.dismiss) private var dismiss
    @State private var selectedImage: String? = nil
    @State private var isPressFullScreen: Bool = false
    @State var isShowButtonAdd: Bool = false
    @State var addMasterInRoom: MasterModel
    
    var body: some View {
        GeometryReader { geo in
            
            VStack {
                VStack(alignment: .center, spacing: 10) {
                    VStack {}
                        .createImageView(model: addMasterInRoom.image ?? "", width: geo.size.width * 0.8,
                                         height: geo.size.height * 0.44)
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
                    }.foregroundStyle(Color(hex: "F3E3CE"))
                    
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
                                                .overlay(content: {
                                                    Circle()
                                                        .stroke(Color.init(hex: "#3e5b47"), lineWidth: 2)
                                                })
                                                .clipped()
                                                .onTapGesture {
                                                    withAnimation(.snappy(duration: 0.5)) {
                                                        selectedImage = master
                                                        isPressFullScreen.toggle()
                                                    }
                                                }
                                            
                                        }
                                    }.id(master)
                                }
                                
                            }.scrollTargetLayout()
                            
                        }.scrollIndicators(.hidden)
                            .padding(.leading, 4)
                            .padding(.trailing, 4)
                            .frame(width: geo.size.width * 0.96, height: geo.size.height * 0.16)
                            .background(.ultraThinMaterial.opacity(0.6), in: .rect(topLeadingRadius: 16, topTrailingRadius: 16))
                        
                        VStack(alignment: .leading, spacing: 10) {

                            Text(addMasterInRoom.description)
                                .lineLimit(12)
                                .font(.system(size: 22, weight: .regular))
                                .padding(.horizontal, 6)
       
                            Spacer()
                        }.truncationMode(.middle)
                            .foregroundStyle(Color(hex: "F3E3CE"))
                            .frame(width: geo.size.width * 0.96, height: isShowButtonAdd ? geo.size.height * 0.18 : geo.size.height * 0.26)
                            .background(.ultraThinMaterial.opacity(0.6), in: .rect(bottomLeadingRadius: 16, bottomTrailingRadius: 16))
                       
                    }
                }.padding(.top, 60)
                if isShowButtonAdd {
                    CustomButton(title: "Add") {
                        Task {
                            let addMaster = MasterModel(id: addMasterInRoom.id, masterID: addMasterInRoom.masterID, name: addMasterInRoom.name, email: addMasterInRoom.email, phone: addMasterInRoom.phone, description: addMasterInRoom.description, image: addMasterInRoom.image, imagesUrl: addMasterInRoom.imagesUrl, latitude: addMasterInRoom.latitude, longitude: addMasterInRoom.longitude)
                            await AdminViewModel.shared.add_MasterToRoom(masterID: addMaster.id, master: addMaster)
                            let titleEnter = String(
                                format: NSLocalizedString("addMaster", comment: ""), addMasterInRoom.name)
                            let subTitle = String(
                                format: NSLocalizedString("addMasterTitle", comment: ""))
                            NotificationController.sharet.notify(title: titleEnter, subTitle: subTitle, timeInterval: 2)
                        }
                    }
                }
            }.createBackgrounfFon()
                .swipeBackDismiss(dismiss: dismiss)
                .imageViewSelected(isPressFullScreen: $isPressFullScreen, selectedImage: selectedImage ?? "", isShowTrash: false, deleteImage: {})
                .ignoresSafeArea(.all)
                .toolbar(content: {
                    ToolbarItem(placement: .topBarLeading) {
                        if !isPressFullScreen {
                            Button(action: { dismiss()}, label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.backward.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(Color.init(hex: "#3e5b47").opacity(0.8))
                                    Text("Back")
                                        .font(.system(size: 18).bold())
                                    
                                }.foregroundStyle(Color.white)
                                    .font(.system(size: 16).bold())
                            })
                        } else {
                            Text("")
                        }
                    }
            })
        }
    }
}
#Preview {
    AddNewMasterView(addMasterInRoom: MasterModel.masterModel())
}
