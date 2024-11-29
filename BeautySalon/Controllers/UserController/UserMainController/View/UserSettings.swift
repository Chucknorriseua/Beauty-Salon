//
//  UserSettings.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 03/10/2024.
//

import SwiftUI

struct UserSettings: View {
    
    @Environment (\.dismiss) private var dismiss
    @State private var taskTitle: String = ""
    @State private var taskService: String = ""
    
    @StateObject var clientViewModel: ClientViewModel
    
    var body: some View {
        GeometryReader { geo in
            
            VStack(alignment: .center, spacing: 10,  content: {
                
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .tint(Color.white)
                        .font(.system(size: 20))
                        .padding(.all, 2)
                        .padding(.leading, 30)
                        .padding(.trailing, 30)
                }.background(Color.red, in: .rect(bottomLeadingRadius: 44, bottomTrailingRadius: 44))
                
                
                VStack(alignment: .center, spacing: 16) {
                    
                    SettingsButton(text: $clientViewModel.clientModel.name, title: "Change name", width: geo.size.width * 1)
                    SettingsButton(text: $clientViewModel.clientModel.phone, title: "Phone +(000)", width: geo.size.width * 1)
                        .keyboardType(.numberPad)
                        .textContentType(.telephoneNumber)
                        .onChange(of: clientViewModel.clientModel.phone) { _, new in
                            clientViewModel.clientModel.phone = formatPhoneNumber(new)
                        }

                }
                .font(.system(size: 16, weight: .medium))
                .tint(Color.white)
                .foregroundStyle(Color.white)

                HStack {
                    MainButtonSignIn(image: "person.crop.circle.fill", title: "Save", action: {
                        Task {
                            await clientViewModel.save_UserProfile()
                            NotificationController.sharet.notify(title: "Save settings", subTitle: "Your settings have been saved👌", timeInterval: 1)
                            dismiss()
                        }
                    })
                }
                Spacer()
            }).padding(.leading, 6)
            .background(Color.init(hex: "#3e5b47").opacity(0.8))
            .ignoresSafeArea(.all)
        }.frame(width: 420)
    }
}
