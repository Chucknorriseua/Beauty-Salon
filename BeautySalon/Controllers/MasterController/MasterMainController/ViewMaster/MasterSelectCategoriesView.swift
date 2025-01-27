//
//  MasterSelectCategoriesView.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 25/01/2025.
//

import SwiftUI

struct MasterSelectCategoriesView: View {
    
    @Binding var selectedCategory: Categories
    @Binding var isShowCategories: Bool
   
    let onSelectedCategory: () -> ()

    var body: some View {
        VStack(spacing: 0) {
                ScrollView {
                    VStack {
                        ForEach(Categories.allCases, id: \.id) { category in
                            Button {
                                selectedCategory = category
                                onSelectedCategory()
                            } label: {
                                VStack {
                                    Text(category.displayName.localized)
                                }.frame(maxWidth: 220, maxHeight: 60)
                                    .fontWeight(.bold)
                                    .fontDesign(.monospaced)
                                    .foregroundStyle(Color.white)
                                    .padding(.all, 8)
                                    .background(.ultraThinMaterial.opacity(0.8))
                                    .clipShape(RoundedRectangle(cornerRadius: 24))
                            }
                        }
                    }
                    .padding()
                }.scrollIndicators(.hidden)
            
            Spacer()
        }.frame(maxWidth: .infinity, maxHeight: 260)
            .background(.regularMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.gray]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 4
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal)
            .overlay(alignment: .topLeading) {
                    Button {
                        withAnimation(.snappy(duration: 0.5)) {
                            isShowCategories.toggle()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                                .padding(.trailing, 4)
                                .font(.system(size: 18, weight: .bold))
                        }.frame(maxWidth: 40, maxHeight: 40)
                            .background(.ultraThinMaterial.opacity(0.7))
                            .clipShape(Circle())
                            .padding(.horizontal, 4)
                    }.padding(.leading, 18)
                        .padding(.top, 10)
            }
    }
}
