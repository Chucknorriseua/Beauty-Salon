//
//  AddNewMasterCell.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 22/09/2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct AddNewMasterCell: View {
    
    @State var addMasterInRoom: MasterModel
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text(addMasterInRoom.name)
                        .font(.system(size: 24, weight: .heavy))
                        .padding(.leading, 14)
                    
                    HStack {
                        Image(systemName: "phone.circle.fill")
                            .font(.system(size: 22))
                        Text(addMasterInRoom.phone)
                    }.onTapGesture {
                        let phoneNumber = "tel://" + addMasterInRoom.phone
                        if let url = URL(string: phoneNumber) {
                            UIApplication.shared.open(url)
                        }
                    }
                    HStack {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 20))
                        Text(addMasterInRoom.email)
                    }
                }.padding(.leading, 6)
                    .foregroundStyle(Color.white.opacity(0.92))
                    .lineLimit(2)
                
                Spacer()
                
                
                if let url = URL(string: addMasterInRoom.image ?? "" ) {
                    
                    WebImage(url: url)
                        .resizable()
                        .indicator(.activity)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width * 0.3,
                               height: geometry.size.height * 0.6)
                        .clipShape(Circle())
                        .padding(.trailing, 4)
                    
                } else {
                    Image("ab3")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width * 0.3,
                               height: geometry.size.height * 0.6)
                        .clipShape(Circle())
                        .padding(.trailing, 4)
                }
                
            }.frame(height: geometry.size.height * 0.77)
                .background(Color.init(hex: "#3e5b47").opacity(0.7), in: .rect(cornerRadius: 36))
                .padding(.leading, 5)
                .padding(.trailing, 5)
                .overlay(alignment: .bottomTrailing) {
                    ZStack {
                        Button(action: {
                            Task {
                                let addMaster = MasterModel(id: addMasterInRoom.id, masterID: addMasterInRoom.masterID, name: addMasterInRoom.name, email: addMasterInRoom.email, phone: addMasterInRoom.phone, description: addMasterInRoom.description, image: addMasterInRoom.image, imagesUrl: addMasterInRoom.imagesUrl, latitude: addMasterInRoom.latitude, longitude: addMasterInRoom.longitude)
                                await AdminViewModel.shared.add_MasterToRoom(masterID: addMaster.id, master: addMaster)
                                NotificationController.sharet.notify(title: "You have added a master to your salon 💇‍♀️ 💅", subTitle: "now you can send him the schedule", timeInterval: 2)
                            }
                            
                        }, label: {
                            Text("Add")
                                .foregroundStyle(Color.white)
                                .font(.system(size: 24, weight: .bold))
                                .padding(.leading, 30)
                                .padding(.trailing, 30)
                        })
                    }.background(Color.gray.opacity(0.5), in: .rect(topLeadingRadius: 24, topTrailingRadius: 24))
                        .padding(.trailing, 140)
                }
        }
        .frame(height: 200)
        .padding(.vertical, -26)
    }
}
