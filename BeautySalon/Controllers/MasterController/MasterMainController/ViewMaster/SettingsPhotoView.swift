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
                                .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                                    content
                                        .opacity(phase.isIdentity ? 1 : 0)
                                        .offset(y: phase.isIdentity ? 0 : 50)
                                }
                        }
                    }.padding(.top, 15)
                        .scrollTargetLayout()
                }.scrollIndicators(.hidden)
                
            }.frame(height: geo.size.height * 0.66)
                .padding(.leading, 6)
                .background(.ultraThickMaterial.opacity(0.6))
                .overlay(alignment: .top) {
                    PhotosPicker(selection: $photoPickerItems, maxSelectionCount: 10, selectionBehavior: .ordered) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                                .foregroundStyle(Color.white)
                                .font(.system(size: 18))
                        }.frame(width: geo.size.width * 0.14, height: geo.size.height * 0.1)
                            .background(Color.gray.opacity(0.2),
                                        in: .rect(bottomLeadingRadius: 22, bottomTrailingRadius: 22))
                    }
                }
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
