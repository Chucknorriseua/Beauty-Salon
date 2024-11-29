//
//  ShedulCell.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 18/09/2024.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseFirestore

struct ShedulCell: View {
    
    @ObservedObject var masterViewModel: MasterCalendarViewModel
    var currentDate: Date
    
    var body: some View {

            let tasks = masterViewModel.getMasterShedule(date: masterViewModel.currentDate)
        
            if !tasks.isEmpty {
                
                ForEach(tasks) { task in
                    HStack {
                        
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                Text(task.nameCurrent)
                                    .font(.system(size: 26, weight: .bold))
                            }.padding(.leading, 30)
                            
                            HStack {
                                Image(systemName: "list.bullet.clipboard.fill")
                                Text("- \(task.taskService)")
                                    .font(.system(size: 19, weight: .medium))
                            }
                            
                            HStack {
                                Image(systemName: "clock.circle.fill")
                                Text("\(format(task.creationDate))")
                                    .font(.system(size: 16, weight: .medium))
                            }
                        }.padding(.leading, 8)
                            .foregroundStyle(Color.white)
                        Spacer()
                    }.frame(width: UIScreen.main.bounds.width - 20, height: 160)
                        .background(task.tinColor, in: .rect(cornerRadius: 44))
          
                }
    
            }
    }
    func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "  HH : mm"
        return formatter.string(from: date)
    }
}

