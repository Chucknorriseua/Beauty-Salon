//
//  ChartsMonthly.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 11/02/2025.
//
import SwiftUI
import Charts

enum MonthStatistics: String, CaseIterable {
    
    case january
    case february
    case march
    case april
    case may
    case june
    case july
    case august
    case september
    case october
    case november
    case december
    
    var displayName: String {
        switch self {
        case .january:
            return "January".localized
        case .february:
            return "February".localized
        case .march:
            return "March".localized
        case .april:
            return "April".localized
        case .may:
            return "May".localized
        case .june:
            return "June".localized
        case .july:
            return "July".localized
        case .august:
            return "August".localized
        case .september:
            return "September".localized
        case .october:
            return "October".localized
        case .november:
            return "November".localized
        case .december:
            return "December".localized
        }
    }
}

struct ChartsMonthly: View {
    
    @EnvironmentObject var coordinator: CoordinatorView
    @StateObject private var adminVM = AdminViewModel.shared
    
    @State private var selectedMonth: MonthStatistics = MonthStatistics.currentMonth
    @State private var isShowMonth: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(spacing: 30) {
                        Text("Salon analytics").font(.title).bold()
                            .foregroundStyle(Color.white)
                        
                        Chart([
                            ("In a month", adminVM.monthlyRecords),
                            ("In 14 days", adminVM.biweeklyRecords)
                        ], id: \.0) { record in
                            BarMark(
                                x: .value("Period", record.0),
                                y: .value("Quantity", record.1)
                            )
                            .foregroundStyle(Color.blue)
                        }
                        .frame(height: 200)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                        
                        
                        Text("Popular procedures").font(.headline)
                            .foregroundStyle(Color.white)
                        let sortedProcedures = adminVM.popularProcedures.sorted(by: { $0.value > $1.value })
                        let chartColors: [Color] = [.blue, .green, .orange, .red, .purple, .yellow, .pink, .cyan, .mint, .brown]
                        
                        Chart(sortedProcedures.indices, id: \.self) { index in
                            let procedure = sortedProcedures[index]
                            
                            SectorMark(
                                angle: .value("Popularity", procedure.value),
                                innerRadius: .ratio(0.5)
                            )
                            .foregroundStyle(chartColors[index % chartColors.count])
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(sortedProcedures, id: \.key) { procedure in
                                HStack {
                                    Circle()
                                        .fill(chartColors[sortedProcedures.firstIndex { $0.key == procedure.key } ?? 0])
                                        .frame(width: 20, height: 20)
                                    
                                    Text(procedure.key)
                                        .foregroundColor(chartColors[sortedProcedures.firstIndex { $0.key == procedure.key } ?? 0])
                                        .font(.body)
                                }
                            }
                        }
                        .frame(height: 300)
                        .padding()
                        
                        
                        Text("The most recorded masters").font(.headline)
                            .foregroundStyle(Color.white)
                        Chart(adminVM.popularMasters.sorted(by: { $0.value > $1.value }), id: \.key) { master in
                            BarMark(
                                x: .value("Master", master.key),
                                y: .value("Records", master.value)
                            )
                            .foregroundStyle(Color.green)
                        }
                        .frame(height: 200)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                        
                        VStack(alignment: .leading, spacing: 20) {
                            HStack(spacing: 10) {
                                Text("Number of unique customers:")
                                Text("\(adminVM.uniqueClients)")
                            }
                            .foregroundStyle(Color.white)
                            .fontWeight(.bold)
                            HStack {
                                Text("The total cost of all procedures from clients: ")
                                    .foregroundStyle(Color.white)
                                    .font(.headline)
                                Text("\(Int(adminVM.totalCostProcedure))")
                                    .foregroundStyle(Color.white)
                                    .fontWeight(.bold)
                                
                            }
                        }
                        
                    }
                    .padding(.bottom, 80)
                    .onAppear {
                        adminVM.selectedMonth = selectedMonth
                        Task {
                            await adminVM.fetch_RecordsMonthly()
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
            .padding(.horizontal, 8)
            .createBackgrounfFon()
            .overlay(alignment: .center, content: {
                if isShowMonth {
                    SelectedMonth(selectedMonth: $selectedMonth)
                    .onChange(of: selectedMonth) { _, new in
                        withAnimation(.linear) {
                            adminVM.selectedMonth = new
                        }
                    }
                }
            })
  
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    TabBarButtonBack {
                        coordinator.pop()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        withAnimation(.linear) {
                            
                            isShowMonth.toggle()
                        }
                    }) {
                        Image(systemName: "list.dash")
                            .foregroundStyle(Color.yellow)
                    }
                }
            })
        }
    }
}


struct ChartsMonthlyMaster: View {
    @EnvironmentObject var coordinator: CoordinatorView
    @StateObject private var masterVM = MasterCalendarViewModel.shared
    @State private var selectedMonth: MonthStatistics = MonthStatistics.currentMonth
    @State private var isShowMonth: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(spacing: 30) {
                        Text("Salon analytics").font(.title).bold()
                            .foregroundStyle(Color.white)
                        
                        Chart([
                            ("In a month", masterVM.monthlyRecords),
                            ("In 14 days", masterVM.biweeklyRecords)
                        ], id: \.0) { record in
                            BarMark(
                                x: .value("Period", record.0),
                                y: .value("Quantity", record.1)
                            )
                            .foregroundStyle(Color.blue)
                        }
                        .frame(height: 200)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                        
                        Text("Popular procedures").font(.headline)
                            .foregroundStyle(Color.white)
                        let sortedProcedures = masterVM.popularProcedures.sorted(by: { $0.value > $1.value })
                        let chartColors: [Color] = [.blue, .green, .orange, .red, .purple, .yellow, .pink, .cyan, .mint, .brown]
                        
                        Chart(sortedProcedures.indices, id: \.self) { index in
                            let procedure = sortedProcedures[index]
                            
                            SectorMark(
                                angle: .value("Popularity", procedure.value),
                                innerRadius: .ratio(0.5)
                            )
                            .foregroundStyle(chartColors[index % chartColors.count])
                        }
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(sortedProcedures, id: \.key) { procedure in
                                HStack {
                                    Circle()
                                        .fill(chartColors[sortedProcedures.firstIndex { $0.key == procedure.key } ?? 0])
                                        .frame(width: 20, height: 20)
                                    
                                    Text(procedure.key)
                                        .foregroundColor(chartColors[sortedProcedures.firstIndex { $0.key == procedure.key } ?? 0])
                                        .font(.body)
                                }
                            }
                        }
                        .frame(height: 300)
                        .padding()
                        
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 10) {
                                Text("Number of unique customers:")
                                Text("\(masterVM.uniqueClients)")
                            }
                            .foregroundStyle(Color.white)
                            .fontWeight(.bold)
                        }
                    }
                    .padding(.bottom, 80)
                }
                .scrollIndicators(.hidden)
            }
            .padding(.horizontal, 8)
            .createBackgrounfFon()
            .overlay(alignment: .center, content: {
                if isShowMonth {
                    SelectedMonth(selectedMonth: $selectedMonth)
                    .onChange(of: selectedMonth) { _, new in
                        withAnimation(.linear) {
                            masterVM.selectedMonth = new
                        }
                    }
                }
            })
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    TabBarButtonBack {
                        coordinator.pop()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        withAnimation(.linear) {
                            
                            isShowMonth.toggle()
                        }
                    }) {
                        Image(systemName: "list.dash")
                            .foregroundStyle(Color.yellow)
                    }
                }
            })
        }
    }
}

