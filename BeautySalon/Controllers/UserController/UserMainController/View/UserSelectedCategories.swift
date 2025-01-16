//
//  UserSelectedCategories.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 09/01/2025.
//

import SwiftUI

enum Categories: String, Identifiable, CaseIterable {
    case nail, hairStyle, massage, another

    var id: String {
        self.rawValue
    }

    var displayName: String {
        switch self {
        case .nail: return "Nails"
        case .hairStyle: return "Hair Style"
        case .massage: return "Massage"
        case .another: return "Another"
        }
    }
}

struct UserSelectedCategories: View {
    
    @Binding var selectedCategory: Categories
    @State private var isShowCategories: Bool = false
    @State private var isSliderDistance: Bool = false
    @Binding var distanceValue: Double
    let onSelectedCategory: () -> ()

    var body: some View {
        VStack(spacing: 0) {
            if isShowCategories {
                VStack {
                    VStack {
                        ForEach(Categories.allCases, id: \.id) { category in
                            Button {
                                selectedCategory = category
                                onSelectedCategory()
                            } label: {
                                VStack {
                                    switch category {
                                    case .nail:
                                        Text("Nails")
                                    case .hairStyle:
                                        Text("Hair Style")
                                    case .massage:
                                        Text("Massage")
                                    case .another:
                                        Text("Another")
                                    }
                                }.frame(width: 140, height: 40)
                                    .fontWeight(.bold)
                                    .fontDesign(.monospaced)
                                    .foregroundStyle(Color.white)
                                    .background(.ultraThinMaterial.opacity(0.8))
                                    .clipShape(RoundedRectangle(cornerRadius: 24))
                            }
                        }
                    }
                    .padding()
                }
            } else {
                VStack {
                    Text("Settings search")
                        .foregroundStyle(Color.yellow)
                        .fontWeight(.bold)
                    Button {
                        withAnimation(.snappy(duration: 0.5)) {
                            isShowCategories.toggle()
                        }
                    } label: {
                        HStack {
                            Text("Select categories")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(Color(hex: "F3E3CE")).opacity(0.7)
                                .padding(.leading, 4)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 4)
                            
                        }.frame(maxWidth: .infinity, maxHeight: 44)
                            .background(.ultraThinMaterial.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal, 4)
                    }
                    Button {
                        withAnimation(.snappy(duration: 0.5)) {
                            isSliderDistance.toggle()
                        }
                    } label: {
                        HStack {
                            Text("Radius search")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(Color(hex: "F3E3CE")).opacity(0.7)
                                .padding(.leading, 4)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 4)
                            
                        }.frame(maxWidth: .infinity, maxHeight: 44)
                            .background(.ultraThinMaterial.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal, 4)
                    }
                }.padding(.top, 10)
                if isSliderDistance {
                    VStack {
                     
                        Text("Radius search")
                                .foregroundStyle(Color.yellow)
                               
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
        }.frame(maxWidth: .infinity, maxHeight: isSliderDistance || isShowCategories ? 230 : 180)
            .background(.ultraThickMaterial.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal)
            .overlay(alignment: .topLeading) {
                if isShowCategories {
                    Button {
                        withAnimation(.snappy(duration: 0.5)) {
                            isShowCategories.toggle()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                                .padding(.trailing, 4)
                            Text("Back")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(Color(hex: "F3E3CE")).opacity(0.7)
                                .padding(.leading, 4)
                        }.frame(maxWidth: 80, maxHeight: 30)
                            .background(.ultraThinMaterial.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal, 4)
                    }.padding(.leading, 18)
                        .padding(.top, 10)
                }
            }
    }
}
#Preview {
    UserSelectedCategories(selectedCategory: .constant(Categories.another),  distanceValue: .constant(0.0), onSelectedCategory: {})
}
