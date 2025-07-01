//
//  HomeCareCell.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 25/02/2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct HomeCareCell: View {
    
    @State private var isToggle: Bool = false
    @State var homeCare: Procedure
    @State var isShow: Bool = false
    @State private var colorTextFb: Color = .white
    
    var body: some View {
        Button {
            withAnimation(.snappy(duration: 1)) {
                isToggle.toggle()
            }
        } label: {
            VStack {
                
                if isToggle {
                    VStack {
                        if let url = URL(string: homeCare.image), !homeCare.image.isEmpty {
                            
                            WebImage(url: url)
                                .resizable()
                                .indicator(.activity)
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity, maxHeight: 600)
                                .clipShape(.rect(cornerRadius: 16))
                    
                        } else {
                            Image("ab1")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity, maxHeight: 600)
                                .clipShape(.rect(cornerRadius: 16))
                        }
                    }
                    .overlay(alignment: .topTrailing) {
                        if isShow {
                            Button {
                                withAnimation(.easeOut) {
                                    delete()
                                }
                            } label: {
                                Image(systemName: "trash.circle")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundStyle(colorTextFb)
                            }
                            .padding([.top, .trailing], 6)
                        }
                    }
                    .overlay(alignment: .center) {
                        VStack(spacing: 30) {
                            Spacer()
                            Text(homeCare.title)
                                .foregroundStyle(colorTextFb)
                                .font(.system(size: 26, weight: .bold))
                            HStack(spacing: 0) {
                                Text("price: ")
                                    .foregroundStyle(colorTextFb)
                                    .font(.system(size: 16, weight: .heavy))
                                Text(homeCare.price)
                                    .foregroundStyle(colorTextFb)
                                    .fontWeight(.bold)
                                    .padding(.all, 8)
                            }
                            .padding(.leading, 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            VStack(alignment: .leading) {
                                ScrollView {
                                    VStack(alignment: .leading) {
                                        Text(homeCare.description)
                                            .foregroundStyle(colorTextFb)
                                            .font(.system(size: 18, weight: .heavy))
                                            .fontDesign(.serif)
                                            .multilineTextAlignment(.leading)
                                    }
                                    .padding(.horizontal, 4)
                                }
                                .scrollIndicators(.hidden)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 200, alignment: .leading)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .padding(.horizontal, 12)
                            
                        }
                        .padding(.bottom, 16)
                    }
                } else {
                    VStack {
                        if let url = URL(string: homeCare.image), !homeCare.image.isEmpty {
                            
                            WebImage(url: url)
                                .resizable()
                                .indicator(.activity)
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity, maxHeight: 160)
                                .clipShape(.rect(cornerRadius: 16))
                            
                            
                        } else {
                            Image("ab1")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity, maxHeight: 160)
                                .clipShape(.rect(cornerRadius: 16))
                            
                            
                        }
                    }
                    .onAppear {
                        colorTextFb = homeCare.colorText.toColor()
                    }
                    .overlay(alignment: .center) {
                        VStack(spacing: 24) {
                            Spacer()
                            Text(homeCare.title)
                                .foregroundStyle(colorTextFb)
                                .font(.system(size: 26, weight: .bold))
                            
                        }
                        .padding(.bottom, 16)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: isToggle ? 600 : 160)
        .clipShape(.rect(cornerRadius: 16))
        .animation(.snappy(duration: 1), value: isToggle)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white, lineWidth: 2)
                .animation(.snappy, value: isToggle)
        )
        .animation(.snappy(duration: 1), value: isToggle)
        .padding(.horizontal, 8)
        .padding(.bottom, 10)
    }
    
    private func delete() {
        Task {
            await AdminViewModel.shared.deleteCreateHomeCare(procedureID: homeCare)
        }
    }
}

#Preview {
    HomeCareCell(homeCare: Procedure.procedureModel())
}

