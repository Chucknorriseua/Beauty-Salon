//
//  RecordFlippedCell.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 22/10/2024.
//

import SwiftUI

struct RecordFlippedCell: View {
    
    
    @State var recordModel: Shedule
    @ObservedObject var viewModelAdmin: AdminViewModel
    @State private var isShowAlert: Bool = false
    @State private var message: String = "Do you want to delete the record?"
    @State private var isFlipped: Bool = false
    @Binding var isShowList: Bool
    @Binding  var selecetedRecord: Shedule?
  
    
    var body: some View {
        GeometryReader(content: { geo in
            
            VStack(alignment: .center, spacing: 10) {
                HStack {
                    if !isFlipped {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack() {
                                Text("🙍‍♀️ \(recordModel.nameMaster)")
                                    .padding(.leading, 8)
                                Spacer()
                                VStack {
                                Text("\(recordModel.nameCurrent)")
                                        .foregroundStyle(Color.yellow).opacity(0.9)
                                        .font(.title2)
                                    Text("from client")
                                        .font(.system(size: 12))
                                        .opacity(0.6)
                                }
                            }.fontWeight(.bold)
                             
                            HStack {Text("💅 \(recordModel.taskService)")}
                            HStack {
                                Image(systemName: "text.bubble.fill")
                                Text(recordModel.comment)
                            }
                            HStack {
                                Image(systemName: "clock.circle.fill")
                                Text("\(format(recordModel.creationDate))")
                            }
                        
                        }.font(.system(size: 19, weight: .medium))
                            .foregroundStyle(Color(hex: "F3E3CE"))
                        Spacer()
                    } else {
                        VStack(spacing: 20) {
                            Text("Send the recording to the master or delete")
                                .fontWeight(.bold)
                            HStack(spacing: 50) {
                                Button(action: {isShowAlert = true}, label: {
                                    Image(systemName: "trash.circle.fill")
                                        .foregroundStyle(Color.red.opacity(0.9))
                                        .font(.system(size: 28))
                                        .padding(.all, 6)
                                }).background(Color.white, in: .rect(cornerRadius: 32))
                                
                                Button(action: {
                                    isShowList = true
                                    selecetedRecord = recordModel
                                }, label: {
                                    Image(systemName: "paperplane.circle.fill")
                                        .foregroundStyle(Color.white.opacity(0.9))
                                        .font(.system(size: 28))
                                        .padding(.all, 6)
                                }).background(Color.blue.opacity(0.8), in: .rect(cornerRadius: 32))
                                
                            }
                            HStack {
                                Image(systemName: "phone.circle.fill")
                                Text(recordModel.phone)
                            }.onTapGesture {
                                let phoneNumber = "tel://" + recordModel.phone
                                if let url = URL(string: phoneNumber) {
                                    UIApplication.shared.open(url)
                                }
                            }
                        }.rotation3DEffect(Angle(degrees: 180), axis: (x: 0.0, y: 1.0, z: 0.0))
                            .foregroundStyle(Color(hex: "F3E3CE"))
                    }
                   
                }
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: geo.size.width * 1, maxHeight: geo.size.height * 0.8)
                .background(Color.init(hex: "#3e5b47").opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
                .rotation3DEffect(
                    isFlipped ? Angle(degrees: 180) : .zero,
                    axis: (x: 0.0, y: 1.0, z: 0.0)
                )
                .animation(.spring(duration: 0.7), value: isFlipped)
                .onTapGesture {
                    isFlipped.toggle()
                }
            }
            .overlay(alignment: .center, content: {
                ZStack {}
                    .customAlert(isPresented: $isShowAlert, hideCancel: true, message: message, title: "") {
                    Task {
                        await viewModelAdmin.deleteRecord(record: recordModel)
                    }
                    } onCancel: {}
            })
        }).frame(height: 240)
            .padding(.leading, 6)
            .padding(.trailing, 6)

    }
    
    func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "  HH : mm,  dd MMMM"
        return formatter.string(from: date)
    }
}

