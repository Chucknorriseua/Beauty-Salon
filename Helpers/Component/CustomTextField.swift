//
//  CustomTextField.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 17/08/2024.
//

import SwiftUI

struct CustomTextField: View {
    
    var text: Binding<String>
    var title: String
    var width: CGFloat
    
    
    @Binding var showPassword: Bool
    
    var body: some View {
        Group {
            VStack(spacing: 18) {
                
                if title == "Password" && !showPassword {
                    SecureField(text: text) {
                        Text(LocalizedStringKey(title))
                            .monospaced()
                            .foregroundStyle(.white.opacity(0.8))
                            .fontWeight(.semibold)
                            .contentTransition(.numericText())
                    }
                } else {
                    TextField(text: text) {
                        Text(LocalizedStringKey(title))
                            .monospaced()
                            .foregroundStyle(.white.opacity(0.8))
                            .fontWeight(.semibold)
                    }
                }
                Divider()
                    .background(Color.white)
                    .frame(height: 2)
            }
        }
        .foregroundStyle(.white)
        .padding(.leading)
        .frame(width: UIScreen.main.bounds.width - 20, height: 60)
        .overlay(alignment: .trailing) {
            if title == "Password" {
                Button(action: {
                    withAnimation {
                        showPassword.toggle()
                    }
                }, label: {
                    Image(systemName: showPassword ? "eye.fill" : "eye.slash.fill")
                        .foregroundStyle(Color.white)
                        .font(.system(size: 26))
                        .padding(.trailing)
                })
            }
        }
    }
}

struct CustomTextFieldPhone: View {
    @Binding var text: String
    var title: String
    var width: CGFloat


    var body: some View {
        Group {
            VStack {
                HStack {
                    TextField(text: $text) {
                        Text(LocalizedStringKey(title))

                    }
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                }
                Divider()
                    .background(Color.white)
                    .frame(height: 2)
            }
        }
        .padding(.leading)
        .foregroundStyle(.white)
        .frame(width: UIScreen.main.bounds.width - 20, height: 60)
    }
}
