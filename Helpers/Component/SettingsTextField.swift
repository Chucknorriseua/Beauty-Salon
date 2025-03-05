//
//  SettingsButton.swift
//  SettingsTextField
//
//  Created by Евгений Полтавец on 19/09/2024.
//

import SwiftUI

struct SettingsTextField: View {
    
    var text: Binding<String>
    var title: String
    var width: CGFloat
    
    var body: some View {
        Group {
            TextField(text: text) {
                Text(LocalizedStringKey(title))
                    .monospaced()
                    .foregroundStyle(Color(hex: "F3E3CE").opacity(0.4))
                    .fontWeight(.semibold)
            }
        }
        .foregroundStyle(Color.white)
        .padding(.leading, 4)
        .frame(width: UIScreen.main.bounds.width - 30, height: 50)
        .background(.ultraThinMaterial.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
    }
}

struct CreateHomeCareColorTextField: View {
    
    var text: Binding<String>
    var title: String
    var width: CGFloat
    var color: Color
    
    var body: some View {
        Group {
            TextField(text: text) {
                Text(LocalizedStringKey(title))
                    .monospaced()
                    .foregroundStyle(Color(hex: "F3E3CE").opacity(0.4))
                    .fontWeight(.semibold)
            }
        }
        .foregroundStyle(color)
        .padding(.leading, 4)
        .frame(width: UIScreen.main.bounds.width - 30, height: 50)
        .background(.ultraThinMaterial.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
    }
}

struct SettingsTextFieldPhone: View {
    
    @Binding var text: String
    var title: String
    var width: CGFloat
    
    
    var body: some View {
        Group {
            HStack {
                TextField(text: $text) {
                    Text(LocalizedStringKey(title))

                }
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
            }
        }
        .foregroundStyle(Color.white)
        .padding(.leading, 4)
        .frame(width: UIScreen.main.bounds.width - 30, height: 50)
        .background(.ultraThinMaterial.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
    }
}
