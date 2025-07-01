//
//  User_MyRecordsCell.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 15/03/2025.
//

import SwiftUI

struct User_MyRecordsCell: View {
    
    @State var myRecords: Shedule
    @Binding var deleteRecords: Shedule?
    @State private var isShowDateils: Bool = false
    private let adaptiveColumn = [
        GridItem(.adaptive(minimum: 90))
    ]
    
    var body: some View {
        Button(action: {
            withAnimation {
                isShowDateils.toggle()                
            }
        }) {
            VStack {
                VStack(spacing: 10) {
                    Text(myRecords.nameSalonOrManster)
                        .foregroundStyle(Color.yellow)
                        .font(.system(size: 20, weight: .bold))
                    HStack {
                        Image(systemName: "phone.circle")
                            .foregroundStyle(Color.green)
                        Text(myRecords.phoneSalonOrMaster)
                            .foregroundStyle(Color.white)
                    }
                    Text("\(format(myRecords.creationDate))")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(Color.white)
                    if isShowDateils {
                        VStack {
                            LazyVGrid(columns: adaptiveColumn, spacing: 8) {
                                ForEach(myRecords.procedure, id: \.self) { item in
                                    Text(item.title)
                                        .font(.system(size: 12, weight: .heavy))
                                        .foregroundStyle(Color.white)
                                        .frame(width: 110, height: 60, alignment: .center)
                                        .clipShape(.rect(cornerRadius: 16))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.white, lineWidth: 1)
                                        )
                                    
                                }
                            }
                            let totalCost = String(
                                format: NSLocalizedString("totalcost", comment: ""),
                                calculatePriceProcedure(record: myRecords)
                            )
                            Text(totalCost)
                                .foregroundStyle(.white)
                                .fontWeight(.bold)
                                .fontDesign(.serif)
                                .underline(color: .white.opacity(0.5))
                        }.padding(.horizontal, 8)
                    }
                }
                .padding(.top, 10)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: isShowDateils ? 300 : 100)
            .background(.ultraThinMaterial.opacity(0.3))
            .clipShape(.rect(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.init(hex: "#58A6DA"), Color.white]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1
                    )
            )
            .padding(.horizontal, 8)
        }
        .overlay(alignment: .topTrailing) {
            Button(action: {
                Task {
                    ClientViewModel.shared.isDeleteRecords = true
                    deleteRecords = myRecords
                }
            }, label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(Color.white)
                    .font(.system(size: 28))
                
            })
            .padding(.trailing, 14)
            .padding(.top, 6)
        }
    }
    func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "  HH : mm,  dd MMMM"
        return formatter.string(from: date)
    }
    
    private func getCurrencySymbol() -> String {
        let countryCode = Locale.current.region?.identifier ?? "US"
        switch countryCode {
        case "UA":
            return "₴"
        case "PL":
            return "zł"
        default:
            return "$"
        }
    }
    
    func calculatePriceProcedure(record: Shedule) -> String {
        let totalCost = record.procedure.reduce(0.0) { (result, item) -> Double in
            return result + (Double(item.price) ?? 0.0)
        }
        let currencySymbol = getCurrencySymbol()
        return "\(String(format: "%.1f", totalCost)) \(currencySymbol)"
    }
}
