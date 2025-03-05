//
//  AdminSheduleFromClientCell.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 14/01/2025.
//

import SwiftUI

struct AdminSheduleFromClientCell: View {
    
    @State var recordModel: Shedule
    @ObservedObject var viewModelAdmin: AdminViewModel
    @Binding var isShowAlert: Bool
  
    @Binding var isShowList: Bool
    @Binding var isShowRedactorDate: Bool
    @Binding var selecetedRecord: Shedule?
    @State private var isShowInfo: Bool = false
    @State private var isAnimateGradient: Bool = false
    private let adaptiveColumn = [
        GridItem(.adaptive(minimum: 90))
    ]
    
    var body: some View {
        VStack {
            Button(action: {
                withAnimation(.snappy(duration: 0.6)) {
                    if selecetedRecord?.id == recordModel.id {
                        isShowInfo.toggle()
                    } else {
                        selecetedRecord = recordModel
                        isShowInfo = true
                    }
                }
            }, label: {
                HStack {
                    if selecetedRecord?.id == recordModel.id && isShowInfo {
                        VStack {
                            HStack {
                                HStack(spacing: 2) {
                                    Text("Master: ")
                                        .fontWeight(.bold)
                                    Text("\(recordModel.nameMaster)")
                                        .foregroundStyle(Color.white)
                                        .fontDesign(.monospaced)
                                        .fontWeight(.bold)
                                }
                                Spacer()
                                VStack {
                                    Text("\(recordModel.nameCurrent)")
                                        .foregroundStyle(Color.white)
                                        .underline(color: .white.opacity(0.5))
                                        .font(.title2)
                                    Text("from client")
                                        .font(.system(size: 12))
                                        .opacity(0.6)
                                }
                            }.padding(.horizontal, 6)
                            VStack(spacing: 18) {
                                VStack(spacing: 14) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "phone.circle.fill")
                                            .foregroundStyle(Color.green.opacity(0.9))
                                        Text(recordModel.phone)
                                            .foregroundStyle(Color.white)
                                        Spacer()
                                    }.onTapGesture {
                                        let phoneNumber = "tel://" + recordModel.phone
                                        if let url = URL(string: phoneNumber) {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                    HStack(spacing: 4) {
                                        Text("Wishes: ")
                                            .fontWeight(.bold)
                                        Text(recordModel.comment)
                                            .foregroundStyle(Color.white)
                                        Spacer()
                                    }
                                    
                                }.padding(.horizontal, 4)
                                HStack {
                                    Text("Procedure: ")
                                        .fontWeight(.bold)
                                        .fontDesign(.monospaced)
                                    Text(recordModel.taskService)
                                        .foregroundStyle(Color.white)
                                    Spacer()
                                }.padding(.leading, 2)
                                VStack {
                                    LazyVGrid(columns: adaptiveColumn, spacing: 8) {
                                        ForEach(recordModel.procedure, id: \.self) { item in
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
                                        calculatePriceProcedure(record: recordModel)
                                    )
                                    Text(totalCost)
                                        .foregroundStyle(.white)
                                        .fontWeight(.bold)
                                        .fontDesign(.serif)
                                        .underline(color: .white.opacity(0.5))
                                }.padding(.horizontal, 8)
                            }
                            Spacer()
                            VStack {
                                HStack(alignment: .firstTextBaseline, spacing: 40) {
                                    Button(action: {
                                        withAnimation {
                                            isShowAlert = true
                                        }
                                    }, label: {
                                        Image(systemName: "trash.circle.fill")
                                            .foregroundStyle(Color.red.opacity(0.9))
                                            .font(.system(size: 28))
                                            .padding(.all, 6)
                                    }).background(Color.white, in: Circle())
                                        .clipped()
                                    
                                    Button(action: {
                                        withAnimation {
                                            selecetedRecord = recordModel
                                            isShowList = true
                                        }
                                    }, label: {
                                        Image(systemName: "paperplane.circle.fill")
                                            .foregroundStyle(Color.white.opacity(0.9))
                                            .font(.system(size: 28))
                                            .padding(.all, 6)
                                    }).background(Color.blue.opacity(0.8), in: Circle())
                                        .clipped()
                                    
                                    Button(action: {
                                        withAnimation {
                                            selecetedRecord = recordModel
                                            isShowRedactorDate = true
                                        }
                                    }, label: {
                                        Image(systemName: "square.and.pencil")
                                            .foregroundStyle(Color.white.opacity(0.9))
                                            .font(.system(size: 24))
                                            .padding(.all, 6)
                                    }).background(Color.orange.opacity(0.8), in: Circle())
                                        .clipped()
                                }
                                HStack(spacing: -12) {
                                    Image(systemName: "clock.circle.fill")
                                    Text("\(format(recordModel.creationDate))")
                                        .foregroundStyle(Color.white)
                                        .fontDesign(.monospaced)
                                }
                            }.padding(.bottom, 10)
                        }.padding(.top, 10)
                    } else {
                        VStack {
                            HStack {
                                Text("\(recordModel.nameCurrent)")
                                    .foregroundStyle(Color.white)
                                    .font(.system(size: 22, weight: .bold))
                                Spacer()
                            }
                            HStack(spacing: -10) {
                                Image(systemName: "clock.circle.fill")
                                Text("\(format(recordModel.creationDate))")
                                    .foregroundStyle(Color.white)
                                    .fontDesign(.monospaced)
                            }
                        }.padding(.leading, 8)
                            .padding(.all, 12)
                        Spacer()
                        Image(systemName: "info.circle.fill")
                            .padding(.trailing, 8)
                        
                    }
                }
            })
        }
        .frame(maxWidth: .infinity, maxHeight: !isShowInfo ? 140 : 600)
        .background(.ultraThinMaterial.opacity(0.7))
        .clipShape(.rect(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.init(hex: "#58A6DA"), Color.white]),
                        startPoint: .top,
                        endPoint: .trailing
                    ),
                    lineWidth: 1
                )
        )
        .foregroundStyle(Color.yellow)
        .padding(.horizontal, 8)
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

#Preview(body: {
    AdminSheduleFromClientCell(recordModel: Shedule.sheduleModel(), viewModelAdmin: AdminViewModel.shared, isShowAlert: .constant(true), isShowList: .constant(true), isShowRedactorDate: .constant(true), selecetedRecord: .constant(Shedule.sheduleModel()))
})
