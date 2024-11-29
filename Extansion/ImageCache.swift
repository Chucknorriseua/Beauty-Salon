//
//  ImageCache.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 21/10/2024.
//
import SwiftUI

class ImageCache {
    
    static let shared = ImageCache()
    
    private init() {}
    
    private let cache = NSCache<NSString, UIImage>()
    
    func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func saveImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
