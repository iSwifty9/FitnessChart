//
//  DailyOneRM.swift
//  OneRepMaxChart
//
//  Created by hope on 7/6/24.
//

import Foundation

struct DailyOneRM: Identifiable {
    let date: Date
    let value: Int
    var id: Date { date }
}
