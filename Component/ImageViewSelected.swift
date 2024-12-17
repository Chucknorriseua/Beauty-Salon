//
//  ImageViewSelected.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 04/12/2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct ImageViewSelected: ViewModifier {
    
    var selectedImage: String? = nil
    @Binding var isPressFullScreen: Bool
    var isShowTrash: Bool
    var deleteImage: () -> ()
    
    
    func body(content: Content) -> some View {
        GeometryReader { geo in
            content
                .overlay(alignment: .center) {
                
                if isPressFullScreen, let selectedImage {
                    
                    Color.black
                        .ignoresSafeArea(.all)
                        .opacity(0.9)
                        .transition(.opacity)
                        .overlay(alignment: .topTrailing) {
                            if isShowTrash {
                                Button {
                                    withAnimation(.snappy(duration: 0.5)) {
                                        
                                        deleteImage()
                                        isPressFullScreen.toggle()
                                    }
                                    
                                } label: {
                                    Image(systemName: "trash.circle.fill")
                                        .foregroundStyle(Color.red.opacity(0.8))
                                        .font(.system(size: 32, weight: .bold))
                                }.padding(.trailing, 10)
                            } else {
                               Text("")
                            }
                        }
                    
                    WebImage(url: URL(string: selectedImage))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(minWidth: geo.size.width * 0.9, maxHeight: geo.size.height * 0.8)
                        .clipped()
                        .onTapGesture {
                            withAnimation(.snappy(duration: 0.5)) {
                                isPressFullScreen = false
                            }
                        }.transition(.blurReplace)
                    
                }
            }
        }
    }
}

extension View {
    func imageViewSelected(isPressFullScreen: Binding<Bool>, selectedImage: String, isShowTrash: Bool ,deleteImage: @escaping () -> ()) -> some View {
        self.modifier(ImageViewSelected(selectedImage: selectedImage, isPressFullScreen: isPressFullScreen, isShowTrash: isShowTrash, deleteImage: deleteImage))
    }
}
