//
//  CustomButton.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 17/08/2024.
//

import SwiftUI

struct CustomButton: View {
    
    let title: String
    let action: () -> ()
    
    var body: some View {
        Button(action: {
            action()
            
        }, label: {
            Text(LocalizedStringKey(title))
                .frame(maxWidth: .infinity, maxHeight: 32)
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Color.white)
                .padding()
                .background(Color(red: 0.11, green: 0.14, blue: 0.12))
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.3), radius: 10, x: 5, y: 8)
        })
        .padding()
    }
}

struct CustomButtonColor: View {
    let bd: String
    let title: String
    let action: () -> ()
    
    var body: some View {
        Button(action: {
            action()
            
        }, label: {
            Text(LocalizedStringKey(title))
                .frame(maxWidth: .infinity)
                .fontWeight(.bold)
                .foregroundStyle(Color.black)
                .padding()
                .background(Color(bd))
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.3), radius: 10, x: 5, y: 8)
        })
        .padding()
    }
}

struct CustomSettingsButton: View {
    
    let title: String
    let action: () -> ()
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            VStack(spacing: 6) {
                HStack {
                    Text(LocalizedStringKey(title))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.title)
                        .foregroundStyle(Color.init(hex: "#A8CAEA"))
                }
                Divider()
                    .frame(height: 4)
                    .foregroundStyle(Color.white.opacity(0.6))
            }
            .padding(.horizontal, 12)
        })
    }
}

#Preview(body: {
    CustomSettingsButton(title: "sfsfsdfsfds", action: {})
})
