//
//  Date+.swift
//  OneRepMaxChart
//
//  Created by hope on 7/6/24.
//

import Foundation

extension Date {
    /// Returns a `Date` object representing the same day at midnight (00:00:00) in the device's local time zone.
    var toMidnight: Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return calendar.date(from: components)
    }

    var startOfWeek: Date? {
        let comps = Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return Calendar.current.date(from: comps)
    }
}
