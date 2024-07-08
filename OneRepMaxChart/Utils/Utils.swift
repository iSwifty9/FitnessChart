//
//  Utils.swift
//  OneRepMaxChart
//
//  Created by hope on 7/6/24.
//

import Foundation

enum Utils {
    /// Estimates the one-repetition maximum (1RM) using the Brzycki formula.
    /// Reference: https://en.wikipedia.org/wiki/One-repetition_maximum
    static func calculateOneRepMax(reps: Int, weightInPounds: Double) -> Double {
        guard (1..<37).contains(reps) else {
            return 0
        }
        return weightInPounds * 36 / (37 - Double(reps))
    }
    
    /// Generates a string representing the range between two dates based on the current device calendar.
    ///
    /// - Returns: A string representing the date range in the format "YYYY MMM DD - MMM DD".
    /// If the years are different, then returns "YYYY MMM DD - YYYY MMM DD".
    /// If the `yearOnly` is set, returns "YYYY".
    static func dateRangeString(lowerDate: Date, upperDate: Date, yearOnly: Bool = false) -> String {
        let calendar = Calendar.current
        
        let lowerDateComponents = calendar.dateComponents([.year, .month, .day] , from: lowerDate)
        let upperDateComponents = calendar.dateComponents([.year, .month, .day], from: upperDate)
        
        guard
            let lowerYear = lowerDateComponents.year,
            let lowerMonth = lowerDateComponents.month,
            let lowerDay = lowerDateComponents.day,
            let upperYear = upperDateComponents.year,
            let upperMonth = upperDateComponents.month,
            let upperDay = upperDateComponents.day
        else {
            return ""
        }

        if yearOnly {
            return "\(upperYear)"
        }
        
        let lowerMonthSymbol = calendar.shortMonthSymbols[lowerMonth - 1]
        let upperMonthSymbol = calendar.shortMonthSymbols[upperMonth - 1]

        var result = "\(lowerYear) \(lowerMonthSymbol) \(lowerDay) - "
        if lowerYear != upperYear {
            result += "\(upperYear)"
        }
        result += "\(upperMonthSymbol) \(upperDay)"
        
        return result
    }
    
    /// Generates an array of `Date` objects representing each day between the given start and end dates, inclusive.
    static func datesBetween(startDate: Date, endDate: Date) -> [Date]? {
        guard startDate <= endDate else {
            return nil
        }
        
        var dates: [Date] = []
        var currentDate = startDate

        while currentDate <= endDate {
            if let day = currentDate.toMidnight {
                dates.append(day)
            }

            guard
                let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)
            else {
                break
            }
            
            currentDate = nextDate
        }
        
        return dates
    }
}
