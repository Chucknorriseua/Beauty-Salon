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
    
    @ObservedObject var clientViewModel = ClientViewModel.shared
    
    var body: some View {
            
            VStack(spacing: 10,  content: {
                
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .tint(Color.white)
                        .font(.system(size: 20))
                        .padding(.all, 2)
                        .padding(.leading, 30)
                        .padding(.trailing, 30)
                }.background(Color.red, in: .rect(bottomLeadingRadius: 44, bottomTrailingRadius: 44))
                
                VStack {
                    
                    VStack {
                        
                        SettingsTextField(text: $clientViewModel.clientModel.name, title: "Change name", width: .infinity)
                        SettingsTextFieldPhone(text: $clientViewModel.clientModel.phone, title: "Phone +(000)", width: .infinity)
                     
                    }
                    .font(.system(size: 16, weight: .medium))
                    
                    HStack {
                        MainButtonSignIn(image: "person.crop.circle.fill", title: "Save", action: {
                            Task {
                                await clientViewModel.save_UserProfile()
                                let titleEnter = String(
                                    format: NSLocalizedString("saveSettings", comment: ""))
                                let subTitle = String(
                                    format: NSLocalizedString("saveSettingsTitle", comment: ""))
                                NotificationController.sharet.notify(title: titleEnter, subTitle: subTitle, timeInterval: 1)
                                dismiss()
                            }
                        })
                    }
                }
                Spacer()
            })
            .sheetColor()

    }
}
