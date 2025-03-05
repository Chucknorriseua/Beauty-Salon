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

extension UIImage {
    func resizeImageUpload(image: UIImage, targetSize: CGSize) -> UIImage {
        let aspectWidth = targetSize.width / image.size.width
        let aspectHeight = targetSize.height / image.size.height
        let aspectRatio = min(aspectWidth, aspectHeight)
        
        let newSize = CGSize(width: image.size.width * aspectRatio, height: image.size.height * aspectRatio)
        UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
