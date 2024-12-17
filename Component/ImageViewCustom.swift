//
//  ImageViewCustom.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 04/12/2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct ImageViewCustom: ViewModifier {
    
    var model: String
    var width: CGFloat
    var height: CGFloat
    
    
    func body(content: Content) -> some View {
      
            if let url = URL(string: model), !model.isEmpty {
                
                WebImage(url: url)
                    .resizable()
                    .indicator(.activity)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width,
                           height: height)
                    .clipShape(Circle())
                    .overlay(content: {
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    })
                    .padding(.leading, 6)
                
            } else {
                Image("ab1")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width,
                           height: height)
                    .clipShape(Circle())
                    .overlay(content: {
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    })
                    .padding(.leading, 6)
                
            }
        
    }
}

extension View {
    func createImageView(model: String, width: CGFloat, height: CGFloat) -> some View {
        self.modifier(ImageViewCustom(model: model, width: width, height: height))
    }
}
