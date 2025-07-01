//
//  RecordsFromClientCell.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 21/02/2025.
//

import SwiftUI

struct RecordsFromClientCell: View {
    
    @State var shedule: Shedule
    @Binding var isShowChange: Bool
    @Binding var selecetedRecord: Shedule?
    @State private var isShow: Bool = false
    @Binding var isShowDelete: Bool
    @Binding var isAddSheduleStatic: Bool
    private let adaptiveColumn = [
        GridItem(.adaptive(minimum: 90))
    ]
    
    var body: some View {
        Button(action: {
            withAnimation(.snappy) {
                isShow.toggle()
                selecetedRecord = shedule
            }
        }, label: {
            VStack {
                if isShow {
                    VStack {
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Image(systemName: "person.crop.circle")
                                    .resizable()
                                    .foregroundStyle(Color.white)
                                    .frame(width: 50, height: 50)
                                Spacer()
                                Text(shedule.nameCurrent)
                                    .foregroundStyle(Color.yellow)
                                    .font(.system(size: 24, weight: .bold))
                                    .underline(color: .white.opacity(0.5))
                            }
                            .padding(.horizontal, 16)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 6) {
                                    Image(systemName: "phone.arrow.up.right.circle.fill")
                                        .foregroundStyle(Color.green)
                                    Text(shedule.phone)
                                        .foregroundStyle(Color.white)
                                        .onTapGesture {
                                            let phoneNumber = "tel://" + shedule.phone
                                            if let url = URL(string: phoneNumber) {
                                                UIApplication.shared.open(url)
                                            }
                                        }
                                }
                                HStack {
                                    Text("comment: ")
                                    HStack(spacing: -6) {
                                        Text(shedule.comment)
                                            .lineLimit(6)
                                            .multilineTextAlignment(.leading)
                                            .foregroundStyle(Color.white)
                                        Spacer()
                                    }
                                    .frame(maxWidth: 220, maxHeight: 120)
                                }
                       
                                HStack(spacing: 4) {
                                    Text("Procedure: ")
                                    Text(shedule.taskService)
                                        .foregroundStyle(Color.white)
                                }
                            }
                            .foregroundStyle(Color.yellow)
                            .font(.system(size: 20, weight: .bold))
                            VStack {
                                LazyVGrid(columns: adaptiveColumn, spacing: 8) {
                                    ForEach(shedule.procedure, id: \.self) { item in
                                        Text(item.title)
                                            .foregroundStyle(Color.white)
                                            .fontWeight(.heavy)
                                            .frame(width: 110, height: 60, alignment: .center)
                                            .clipShape(.rect(cornerRadius: 16))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color.init(hex: "#9AC9E8"), lineWidth: 1)
                                            )
                                        
                                    }
                                    
                                }
                                let totalCost = String(
                                    format: NSLocalizedString("totalcost", comment: ""),
                                    calculatePriceProcedure(record: shedule)
                                )
                                Text(totalCost)
                                    .foregroundStyle(.white)
                                    .fontWeight(.bold)
                                    .fontDesign(.serif)
                                    .underline(color: .white.opacity(0.5))
                            }
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .padding(.leading, 4)
                        
                        VStack(alignment: .center) {
                            Text("\(format(shedule.creationDate))")
                        }
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundStyle(Color.white)
                    }
                    .overlay(alignment: .bottomTrailing) {
                        HStack(spacing: 24) {
                            Button(action: {
                                withAnimation(.snappy) {
                                    isShowDelete = true
                                }
                            }, label: {
                               Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(Color.white)
                                    .font(.system(size: 28))
                                
                            })
                            .overlay(
                                RoundedRectangle(cornerRadius: 36)
                                    .stroke(Color.yellow, lineWidth: 2)
                            )
                        }
                    }
                    .overlay(alignment: .bottomLeading) {
                        HStack(spacing: 16) {
                            Button(action: {
                                withAnimation(.snappy) {
                                    isShowChange = true
                                }
                            }, label: {
                                Image(systemName: "list.bullet.circle.fill")
                                    .foregroundStyle(Color.white)
                                    .font(.system(size: 30))
                                
                            })
                            
                            Button {
                                withAnimation(.snappy) {
                                    isAddSheduleStatic = true
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                     .foregroundStyle(Color.white)
                                     .font(.system(size: 28))
                            }
                        }
                    }
                } else {
                    VStack {
                        HStack {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .foregroundStyle(Color.white)
                                .frame(width: 50, height: 50)
                            Spacer()
                            Text(shedule.nameCurrent)
                                .foregroundStyle(Color.yellow)
                                .font(.system(size: 20, weight: .bold))
                                .underline(color: .white.opacity(0.5))
                        }
                        .padding(.horizontal, 16)
                        
                        VStack(alignment: .center) {
                            Text("\(format(shedule.creationDate))")
                        }
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundStyle(Color.white)
                    }
                }
            }
            .padding(.all, 10)
        })
        .frame(maxWidth: .infinity, maxHeight: isShow ? 800 : 140)
        .background(.ultraThinMaterial.opacity(0.4))
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
        .padding(.horizontal, 12)

    }
    private func format(_ date: Date) -> String {
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
