//
//  ExerciseSummary.swift
//  OneRepMaxChart
//
//  Created by hope on 7/6/24.
//

import Foundation

struct ExerciseSummary: Identifiable {
    let exercise: String
    let latestMaxOneRM: Int
    var id: String { exercise }
}
