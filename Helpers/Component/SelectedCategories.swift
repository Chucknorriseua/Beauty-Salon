//
//  SelectedCategories.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 11/02/2025.
//

import SwiftUI

struct SelectedCategories: View {
    
    @Binding var selectedCtegory: String?
    @Binding var isShowInformation: Bool
    @Binding var isShowAnother: Bool
    
    var body: some View {
        VStack {
            Text("Categories")
                .foregroundStyle(Color.white)
                .font(.system(size: 20, weight: .bold))
                .offset(x: 10)
            VStack {
                ForEach(Categories.allCases, id: \.self) { item in
                    Button(action: {
                        selectedCtegory = item.rawValue
                        withAnimation(.linear) {
                            isShowInformation = (item == .housecall)
                            isShowAnother = (item == .another)
                        }
                    }, label: {
                        VStack {
                            HStack {
                                Text(item.displayName)
                                    .foregroundStyle(Color.white)
                                    .font(.system(size: 20, weight: .bold))
                                    .padding(.all, 12)
                                Spacer()
                                Image(systemName: selectedCtegory == item.rawValue ? "largecircle.fill.circle" : "circlebadge")
                                    .foregroundStyle(Color.yellow)
                            }
                            Divider()
                                .frame(height: 4)
                        }
                    })
                    .padding(.horizontal, 2)
                }
            }
        }
        .transition(.scale)
    }
}

struct SelectedMonth: View {
    
    @Binding var selectedMonth: MonthStatistics
    
    var body: some View {
        VStack {
            Text("Selected Month Statistics.")
                .foregroundStyle(Color.white)
                .fontWeight(.bold)
                .offset(x: 10)
            ScrollView {
                
                VStack {
                    ForEach(MonthStatistics.allCases, id: \.self) { item in
                        Button(action: {
                            withAnimation(.snappy) {
                                
                                selectedMonth = item
                            }
                        }, label: {
                            VStack {
                                HStack {
                                    Text(item.displayName)
                                        .foregroundStyle(Color.white)
                                        .fontWeight(.bold)
                                        .padding(.all, 12)
                                    Spacer()
                                    Image(systemName: selectedMonth == item ? "largecircle.fill.circle" : "circlebadge")
                                        .foregroundStyle(Color.blue)
                                }
                                Divider()
                                    .frame(height: 6)
                                    .foregroundStyle(Color.white)
                            }
                        })
                        .padding(.horizontal, 6)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 200)
            .background(.ultraThinMaterial)
            .padding(.horizontal, 12)
        }
        .transition(.scale)
    }
}
