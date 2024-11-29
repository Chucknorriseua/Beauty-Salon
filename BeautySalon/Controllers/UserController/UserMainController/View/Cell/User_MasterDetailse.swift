//
//  User_MasterDetailse.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 04/10/2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct User_MasterDetailse: View {
    
    @Environment (\.dismiss) private var dismiss
    @State private var selectedImage: String? = nil
    @State private var isPressFullScreen: Bool = false
    
    @State var masterModel: MasterModel? = nil
    
    var body: some View {
        GeometryReader { geo in
            
            VStack {
                VStack(alignment: .center, spacing: 10) {
                    if let image = masterModel?.image, let url = URL(string: image) {
                        
                        WebImage(url: url)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width * 1, height: geo.size.height * 0.5)
                            .clipShape(.rect(cornerRadius: 0))
                    } else {
                        Image("ab3")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width * 1, height: geo.size.height * 0.5)
                            .clipShape(.rect(cornerRadius: 0))
                        
                    }
                    LazyVStack {
                        ScrollView(.horizontal) {
                            LazyHStack {
                                
                                ForEach(masterModel?.imagesUrl ?? [], id: \.self) { master in
                                    LazyHStack {
                                        
                                        if let url = URL(string: master) {
                                            
                                            WebImage(url: url)
                                                .resizable()
                                                .indicator(.activity)
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: geo.size.width * 0.32,
                                                       height: geo.size.height * 0.18)
                                                .clipShape(.rect(cornerRadius: 42))
                                                .clipped()
                                                .onTapGesture {
                                                    withAnimation(.easeInOut(duration: 0.5)) {
                                                        selectedImage = master
                                                        isPressFullScreen.toggle()
                                                    }
                                                }
                                            
                                        }
                                    }.id(master)
                                        .scrollTransition(.interactive) { content, phase in
                                            content
                                                .opacity(phase.isIdentity ? 1 : 0)
                                                .offset(y: phase.isIdentity ? 0 : -50)
                                        }
                                }
                                
                            }.padding(.leading, 6)
                                .padding(.trailing, 6)
                                .scrollTargetLayout()
                            
                        }.scrollIndicators(.hidden)
                        
                        
                        VStack(alignment: .leading) {
                            Text(masterModel?.description ?? "")
                                .lineLimit(12)
                                .foregroundStyle(Color(hex: "F3E3CE"))
                                .font(.system(size: 22, weight: .regular))
                                .padding(.leading, 6)
                                .padding(.trailing, 6)
                            
                        }.multilineTextAlignment(.leading)
                    }
                }
                Spacer()
            }.createBackgrounfFon()
                .swipeBackDismiss(dismiss: dismiss)
                .overlay(alignment: .center) {
                    
                    
                    if isPressFullScreen, let selectedImage {
                        
                            Color.black
                                .ignoresSafeArea(.all)
                                .opacity(0.9)
                                .transition(.opacity)
                            
                            WebImage(url: URL(string: selectedImage))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(minWidth: geo.size.width, maxHeight: geo.size.height)
                                .clipped()
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        isPressFullScreen.toggle()
                                    }
                                }.transition(.blurReplace)
                        
                    }
                }.ignoresSafeArea(.all)
                .toolbar(content: {
                        ToolbarItem(placement: .topBarLeading) {
                            if !isPressFullScreen {
                                Button(action: {
                                    
                                    dismiss()
                                }, label: {
                                    HStack(spacing: 4) {
                                         Image(systemName: "chevron.backward.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(Color.init(hex: "#3e5b47").opacity(0.8))
                                    Text("Back")
                                        .font(.system(size: 18).bold())
                                        
                                    }.foregroundStyle(Color.white)
                                        .padding(.all, 4)
                                        .background(Color.white.opacity(0.4), in: .rect(cornerRadius: 24))
                                        .font(.system(size: 16).bold())
                                })
                            } else {
                                Text("")
                            }
                        }
                })
        }
    }
}
