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
    
    @ObservedObject var masterViewModel: MasterViewModel
    @StateObject var authViewModel = Auth_Master_ViewModel()
    @State var isShowAlert: Bool = false
    @Binding var selectedImage: String?
    @Binding var isPressFullScreen: Bool
    @Binding var isShowPhotoPicker: Bool
    
    var body: some View {
            VStack {
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(masterViewModel.masterModel.imagesUrl ?? [], id:\.self) { image in
                           HStack {
                              
                                   WebImage(url: URL(string: image))
                                       .resizable()
                                       .indicator(.activity)
                                       .aspectRatio(contentMode: .fill)
                                       .frame(width: 90,
                                              height: 90)
                                       .clipShape(Circle())
                                       .clipped()
                                       .overlay(content: {
                                           Circle()
                                               .stroke(Color.white, lineWidth: 2)
                                       })
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
                
            }
            .frame(maxWidth: .infinity, maxHeight: 200)
                .padding(.leading, 6)
                .photosPicker(isPresented: $isShowPhotoPicker, selection: $photoPickerItems, maxSelectionCount: 10, selectionBehavior: .ordered)

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
                    await masterViewModel.fetchProfile_Master()
                }
                photoPickerItems.removeAll()
            }
            
        }
        .onDisappear {
            Admin_DataBase.shared.deinitListener()
        }
    }
}
