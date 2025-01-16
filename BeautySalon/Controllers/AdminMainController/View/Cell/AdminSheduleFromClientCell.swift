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
    @State private var isShowAlert: Bool = false
    @State private var message: String = "Do you want to delete the record?"
    @State private var isFlipped: Bool = false
    @Binding var isShowList: Bool
    @Binding var selecetedRecord: Shedule?
    @State private var isShowInfo: Bool = false
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
                                }.padding(.leading, 4)
                                VStack {
                                    LazyVGrid(columns: adaptiveColumn, spacing: 8) {
                                        ForEach(recordModel.procedure, id: \.self) { item in
                                            Text(item.title)
                                                .frame(width: 100, height: 50, alignment: .center)
                                                .clipShape(.rect(cornerRadius: 16))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(Color.white, lineWidth: 1)
                                                )
                                            
                                        }
                                    }
                                }.padding(.horizontal, 8)
                            }
                            Spacer()
                            VStack {
                                HStack(spacing: 80) {
                                    Button(action: {
                                        isShowAlert = true
                                    }, label: {
                                        Image(systemName: "trash.circle.fill")
                                            .foregroundStyle(Color.red.opacity(0.9))
                                            .font(.system(size: 32))
                                            .padding(.all, 6)
                                    }).background(Color.white, in: .rect(cornerRadius: 32))
                                        .clipped()
                                    
                                    Button(action: {
                                        isShowList = true
                                        selecetedRecord = recordModel
                                    }, label: {
                                        Image(systemName: "paperplane.circle.fill")
                                            .foregroundStyle(Color.white.opacity(0.9))
                                            .font(.system(size: 32))
                                            .padding(.all, 6)
                                    }).background(Color.blue.opacity(0.8), in: .rect(cornerRadius: 32))
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
        .frame(maxWidth: .infinity, maxHeight: !isShowInfo ? 140 : 500)
        .background(.regularMaterial)
//        .background(Color.init(hex: "#C0C0C0").opacity(0.8))
        .foregroundStyle(Color.yellow)
        .clipShape(.rect(cornerRadius: 24))
        .padding(.horizontal, 8)
        .overlay(alignment: .center, content: {
            ZStack {}
                .customAlert(isPresented: $isShowAlert, hideCancel: true, message: message, title: "") {
                    Task {
                        await viewModelAdmin.deleteRecord(record: recordModel)
                    }
                } onCancel: {}
        })
    }
    func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "  HH : mm,  dd MMMM"
        return formatter.string(from: date)
    }
}
#Preview(body: {
    AdminSheduleFromClientCell(recordModel: Shedule.sheduleModel(), viewModelAdmin: AdminViewModel.shared, isShowList: .constant(false), selecetedRecord: .constant(Shedule.sheduleModel()))
})
