//
//  ExerciseRecord.swift
//  OneRepMaxChart
//
//  Created by hope on 7/6/24.
//

import Foundation

struct ExerciseRecord {
    let date: Date
    let exercise: String
    let repetitions: Int
    let weightInPounds: Double
    let oneRM: Double
    var isDeleted = false
}
