//
//  UserSelectedCategories.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 09/01/2025.
//

import SwiftUI

enum Categories: String, Identifiable, CaseIterable {
    case nail, massage, barberShop, housecall, another
    
    var id: String {
        self.rawValue
    }
    
    var displayName: String {
        switch self {
        case .nail: return "Nails".localized
        case .barberShop: return "Barber Shop".localized
        case .massage: return "Massage".localized
        case .housecall: return "At home or away".localized
        case .another: return "Another".localized
        }
    }
}

struct UserSelectedCategories: View {
    
    @Binding var selectedCategory: Categories
    @EnvironmentObject var coordinator: CoordinatorView
    @State private var isShowCategories: Bool = false
    @State private var isSliderDistance: Bool = false
    @Binding var distanceValue: Double
    let onSelectedCategory: () -> ()
    
    var body: some View {
        VStack(spacing: 0) {
            if isShowCategories {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Categories.allCases, id: \.id) { category in
                            Button {
                                selectedCategory = category
                                onSelectedCategory()
                            } label: {
                                VStack {
                                    HStack {
                                        Text(category.displayName.localized)
                                            .font(.system(size: 20))
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .padding(.trailing, 4)
                                            .foregroundStyle(Color.white)
                                            .fontWeight(.bold)
                                    }
                                }.frame(maxWidth: .infinity, maxHeight: 50)
                                    .fontWeight(.bold)
                                    .fontDesign(.monospaced)
                                    .foregroundStyle(Color.white)
                                    .padding(.all, 8)
                                    .padding(.horizontal, 10)
                                
                            }
                        }
                    }
                    .padding(.top, 60)
                }.scrollIndicators(.hidden)
            } else {
                VStack(spacing: 12) {
                    Text("Settings search")
                        .foregroundStyle(Color.yellow)
                        .font(.system(size: 20, weight: .bold))
                    Button {
                        withAnimation(.snappy(duration: 0.5)) {
                            isShowCategories.toggle()
                        }
                    } label: {
                        HStack {
                            Text("Select categories")
                                .font(.system(size: 20, weight: .heavy))
                                .foregroundStyle(Color.white)
                                .padding(.leading, 4)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 4)
                                .foregroundStyle(Color.white)
                                .fontWeight(.bold)
                            
                        }
                        .frame(maxWidth: .infinity, maxHeight: 60)
                        .padding(.horizontal, 6)
                    }
                    Button {
                        withAnimation(.snappy(duration: 0.5)) {
                            isSliderDistance.toggle()
                        }
                    } label: {
                        HStack {
                            Text("Radius search")
                                .font(.system(size: 20, weight: .heavy))
                                .foregroundStyle(Color.white)
                                .padding(.leading, 4)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 4)
                                .foregroundStyle(Color.white)
                                .fontWeight(.bold)
                            
                        }
                        .frame(maxWidth: .infinity, maxHeight: 60)
                        .padding(.horizontal, 6)
                    }
                    Button {
                        withAnimation(.snappy(duration: 0.5)) {
                            coordinator.push(page: .User_Favorites)
                        }
                    } label: {
                        HStack {
                            Text("My Favorites")
                                .font(.system(size: 20, weight: .heavy))
                                .foregroundStyle(Color.white)
                                .padding(.leading, 4)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 4)
                                .foregroundStyle(Color.white)
                                .fontWeight(.bold)
                            
                        }
                        .frame(maxWidth: .infinity, maxHeight: 60)
                        .padding(.horizontal, 6)
                    }
                }.padding(.top, 10)
                if isSliderDistance {
                    VStack {
                        
                        Text("Radius search")
                            .foregroundStyle(Color.yellow)
                            .font(.system(size: 20, weight: .bold))
                        
                        Slider(value: $distanceValue, in: 500...10000, step: 100) {
                        } minimumValueLabel: {
                            Text("500")
                                .foregroundStyle(Color.white)
                        } maximumValueLabel: {
                            Text("\(Int(distanceValue))")
                                .foregroundStyle(Color.white)
                        }.onChange(of: distanceValue) { _, newValue in
                            distanceValue = newValue
                        }
                        
                    }.padding(.horizontal, 6)
                        .fontWeight(.bold)
                } else {
                    
                }
            }
            Spacer()
        }.frame(maxWidth: .infinity, maxHeight: isSliderDistance || isShowCategories ? 340 : 280)
            .background(Color.init(hex: "#223221c"))
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
            .padding(.horizontal, 8)
            .overlay(alignment: .topLeading) {
                if isShowCategories {
                    Button {
                        withAnimation(.snappy(duration: 0.5)) {
                            isShowCategories.toggle()
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(Color.white)
                            .font(.system(size: 24, weight: .bold))
                    }
                    .offset(x: 28, y: 16)
                }
            }
    }
}
#Preview {
    UserSelectedCategories(selectedCategory: .constant(Categories.another),  distanceValue: .constant(0.0), onSelectedCategory: {})
}
extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
