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
    let onSelectedCategory: () -> ()

    var body: some View {
        VStack(spacing: -4) {
            Text("Selected Category")
                .foregroundStyle(Color.yellow)
                .fontWeight(.bold)
                
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
                            .foregroundStyle(Color.white)
                            .background(.ultraThinMaterial.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                }
            }
            .padding()
        }.frame(maxWidth: .infinity, maxHeight: 230)
            .background(.ultraThickMaterial.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal)
    }
}
