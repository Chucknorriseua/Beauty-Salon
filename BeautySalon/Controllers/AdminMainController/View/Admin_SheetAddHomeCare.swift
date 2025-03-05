//
//  Admin_SheetAddHomeCare.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 25/02/2025.
//

import SwiftUI
import PhotosUI
import SDWebImageSwiftUI

struct Admin_SheetAddHomeCare: View {
    
    @ObservedObject var adminVM: AdminViewModel
    @Environment (\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var price: String = ""
    @State private var description: String = ""
    @State private var selectColors: Color = .white
    @State private var photoPickerItems: PhotosPickerItem? = nil
    @State private var isAddPhotoCare: Bool = false
    @State private var selectedUIImage: UIImage? = nil
 
    
    var body: some View {
        VStack {
            Text("Create Home care")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.yellow)
            VStack {
                if let uiImage = selectedUIImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 300, height: 140)
                        .clipShape(.rect(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white, lineWidth: 2)
                        )
               
  
                } else {
                    Image("ab1")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 100)
                        .clipShape(.rect(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white, lineWidth: 2)
                        )
                        
                }
                
                CreateHomeCareColorTextField(text: $title, title: "Name product", width: .infinity, color: selectColors)
                CreateHomeCareColorTextField(text: $price, title: "Price", width: .infinity, color: selectColors)
                    .keyboardType(.phonePad)
                ZStack(alignment: .topLeading) {
                    if description.isEmpty {
                        Text("Description, limit your input to 160 characters.")
                            .foregroundStyle(Color(hex: "F3E3CE").opacity(0.7))
                            .padding(.top, 4)
                            .padding(.leading, 4)
                    }
                        TextEditor(text: $description)
                            .scrollContentBackground(.hidden)
                            .foregroundStyle(selectColors)
                }.frame(height: 150)
                .overlay(content: {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white, lineWidth: 2)
                    })
                    .clipShape(.rect(cornerRadius: 12))
           
                .padding(.horizontal, 14)
                
                HStack {
                    Text("Select color: ")
                        .foregroundStyle(selectColors)
                        .fontWeight(.bold)
                        .underline(color: selectColors)
                    ColorPicker("", selection: $selectColors, supportsOpacity: false)
                }
                .padding(.horizontal, 14)
                
                CustomButton(title: "Create") {
                    Task {
                        let hexColor = selectColors.toHex() ?? "#000000"
                        var imageUrlString: String? = nil
                        
                        if let selectedUIImage, let imageData = selectedUIImage.jpegData(compressionQuality: 0.5) {
                            if let imageUrl = await Admin_DataBase.shared.addImageHomeCare(imageData: imageData) {
                                imageUrlString = imageUrl.absoluteString
                            } else {
                                print("Ошибка загрузки изображения")
                            }
                        }
                        
                        let produced = Procedure(
                            id: UUID().uuidString,
                            title: title,
                            price: price,
                            image: imageUrlString ?? "",
                            colorText: hexColor,
                            description: description
                        )
                        
                        await AdminViewModel.shared.addNewHomeCareFirebase(addProcedure: produced)
                        dismiss()
                    }
                }
            }
            Spacer()
        }
        .photosPicker(isPresented: $isAddPhotoCare, selection: $photoPickerItems, matching: .images)
        .onChange(of: photoPickerItems) {
                Task {
                    if let photoPickerItems,
                       let data = try? await photoPickerItems.loadTransferable(type: Data.self),
                        let image = UIImage(data: data) {
                            selectedUIImage = image
                    }
                    photoPickerItems = nil
                }
                
            }
        .overlay(alignment: .topTrailing, content: {
            Button(action: {
                isAddPhotoCare = true
            }, label: {
                Image(systemName: "photo.circle.fill")
                    .foregroundStyle(Color.yellow)
                    .font(.system(size: 36))
            })
            .padding([.top, .trailing], 10)
        })
        .sheetColor()
    }
}

#Preview {
    Admin_SheetAddHomeCare(adminVM: AdminViewModel.shared)
}

//картинка название описнаие цена
