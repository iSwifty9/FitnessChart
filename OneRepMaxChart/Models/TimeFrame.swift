//
//  TimeFrame.swift
//  OneRepMaxChart
//
//  Created by hope on 7/6/24.
//

import Foundation

enum TimeFrame: String, CaseIterable, Identifiable {
    case week, month, year
    var id: Self { self }
    var description: String { self.rawValue.capitalized }
    
    var unit: Calendar.Component {
        switch self {
        case .week: .weekOfYear
        case .month: .month
        case .year: .year
        }
    }
}
