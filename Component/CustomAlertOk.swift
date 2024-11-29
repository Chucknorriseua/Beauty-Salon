//
//  CustomAlertOk.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 11/09/2024.
//

import SwiftUI

struct CustomAlertOk: ViewModifier {
    
    
    @Binding var isPresented: Bool
    var message: String
    var title: String
    var onConfirm: () -> Void

    func body(content: Content) -> some View {
            ZStack {
                content
                    .disabled(isPresented)
                
                if isPresented {
                    ZStack {
                  
                        VStack(spacing: 20) {
                            Text(title)
                                .foregroundColor(Color.white.opacity(0.9))
                                .font(.system(size: 22, weight: .bold))
                                .padding(.top, 20)
                            
                            Text(message)
                                .foregroundColor(.white)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                            
                            HStack {
                                Button(action: {
                                        onConfirm()
                                        isPresented = false
                                }) {
                                    Text("OK")
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .clipped()
                                        .padding()
                                        .background(Color.green.opacity(0.7))
                                        .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            Spacer().frame(height: 20)
                        }
                        .background(.ultraThinMaterial.opacity(0.9))
                        .cornerRadius(20)
                        .shadow(radius: 20)
                        .padding(40)
                    }
                    .transition(.opacity)
                }
            }.animation(.easeInOut(duration: 0.5), value: isPresented)
        }
    }

extension View {
    func customAlertOk(isPresented: Binding<Bool>, message: String, title: String, onConfirm: @escaping () -> Void) -> some View {
        self.modifier(CustomAlertOk(isPresented: isPresented, message: message, title: title, onConfirm: onConfirm))
    }
}
