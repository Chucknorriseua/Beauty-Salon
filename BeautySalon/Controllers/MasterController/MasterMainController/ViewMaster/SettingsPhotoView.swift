//
//  SettingsPhotoView.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 09/09/2024.
//

import SwiftUI
import PhotosUI
import SDWebImageSwiftUI

struct SettingsPhotoView: View {
    
    
    @State private var photoPickerItems: [PhotosPickerItem] = []
    
    @StateObject var masterViewModel: MasterViewModel
    @StateObject var authViewModel = Auth_Master_ViewModel()
    @State var isShowAlert: Bool = false
    @Binding var selectedImage: String?
    @Binding var isPressFullScreen: Bool
    @Binding var isShowPhotoPicker: Bool
    
    var body: some View {
        
        GeometryReader { geo in
            VStack {
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(masterViewModel.masterModel.imagesUrl ?? [], id:\.self) { image in
                           HStack {
                              
                                   WebImage(url: URL(string: image))
                                       .resizable()
                                       .indicator(.activity)
                                       .aspectRatio(contentMode: .fill)
                                       .frame(width: geo.size.width * 0.3,
                                              height: geo.size.height * 0.5)
                                       .clipShape(Circle())
                                       .overlay(content: {
                                           Circle()
                                               .stroke(Color.init(hex: "#3e5b47"), lineWidth: 2)
                                       })

                                       .clipped()
                                       .onTapGesture {
                                           withAnimation(.easeInOut(duration: 0.5)) {
                                               
                                               selectedImage = image
                                               isPressFullScreen = true
                                           }
                                       }
                               
                            }.id(image)
                       
                        }
                    }.padding(.top, 15)
                     
                }.scrollIndicators(.hidden)
                
            }.frame(height: geo.size.height * 0.66)
                .padding(.leading, 6)
                .background(.ultraThickMaterial.opacity(0.6))
                .photosPicker(isPresented: $isShowPhotoPicker, selection: $photoPickerItems, maxSelectionCount: 10, selectionBehavior: .ordered)
        }
        .frame(height: 220)
        .padding(.leading, 8)
        .padding(.trailing, 8)
        
        .onChange(of: photoPickerItems) {
            guard let uid = authViewModel.auth.currentUser?.uid else { return }
            Task {
                
                var imageData: [Data] = []
                
                for item in photoPickerItems {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        imageData.append(data)
                    }
                }
                if !imageData.isEmpty {
                    await Master_DataBase.shared.uploadMultipleImages(id: uid, imageData: imageData)
                    await masterViewModel.fetchProfile_Master(id: masterViewModel.masterModel.id)
                }
                photoPickerItems.removeAll()
            }
            
        }
        .onDisappear {
            Admin_DataBase.shared.deinitListener()
        }
    }
}
