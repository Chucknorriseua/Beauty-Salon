//
//  AnalyticCalculator.swift
//  BeautySalon
//
//  Created by Евгений Полтавец on 11/02/2025.
//

import Foundation

struct AnalyticsCalculator {
    
    static func getRecords(for schedules: [Shedule], days: Int) -> Int {
        let calendar = Calendar.current
        let now = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: now) else { return 0 }
        
        return schedules.filter { $0.creationDate >= startDate }.count
    }
    
    static func getMonthlyRecords(schedules: [Shedule]) -> Int {
        return getRecords(for: schedules, days: 30)
    }

    static func getBiweeklyRecords(schedules: [Shedule]) -> Int {
        return getRecords(for: schedules, days: 14)
    }
    
   
    static func getPopularMasters(schedules: [Shedule]) -> [String: Int] {
        var masterCount: [String: Int] = [:]
        
        for schedule in schedules {
            masterCount[schedule.nameMaster, default: 0] += 1
        }
        
        return masterCount.sorted { $0.value > $1.value }.reduce(into: [:]) { $0[$1.key] = $1.value }
    }
    
 
    static func getPopularProcedures(schedules: [Shedule]) -> [String: Int] {
        var procedureCount: [String: Int] = [:]
        
        for schedule in schedules {
            for procedure in schedule.procedure {
                procedureCount[procedure.title, default: 0] += 1
            }
        }
        
        return procedureCount.sorted { $0.value > $1.value }.reduce(into: [:]) { $0[$1.key] = $1.value }
    }

   
    static func getUniqueClients(schedules: [Client]) -> Int {
        let uniqueClients = Set(schedules.map { $0.phone })
        return uniqueClients.count
    }
    
    static func getTotalCostProcedure(schedules: [Shedule]) -> Double {
        var totalCost: Double = 0.0

        for schedule in schedules {
  
            for procedure in schedule.procedure {
                if let cost = Double(procedure.price) {
                    totalCost += cost
                }
            }
        }

        return totalCost
    }
}
