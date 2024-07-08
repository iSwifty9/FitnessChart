//
//  APIClient.swift
//  OneRepMaxChart
//
//  Created by hope on 7/6/24.
//

import Foundation

protocol APIClient {
    func fetchWorkoutData() async throws -> [ExerciseRecord]
}

struct MockAPIClient: APIClient {
    func fetchWorkoutData() async throws -> [ExerciseRecord] {
        // Mimicking loading delay of a second
        try? await Task.sleep(nanoseconds: 1000_000_000)
        
        return try loadDataFile()
    }
    
    private func loadDataFile() throws -> [ExerciseRecord] {
        let workoutFile = "workoutData.txt"
        
        guard let fileUrl = Bundle.main.url(forResource: workoutFile, withExtension: nil) else {
            throw "Couldn't load \(workoutFile) file"
        }
        
        do {
            let content = try String(contentsOf: fileUrl, encoding: .utf8)
            return parseWorkoutData(from: content)
        } catch {
            throw "Failed in reading \(workoutFile) file"
        }
    }
    
    private func parseWorkoutData(from content: String) -> [ExerciseRecord] {
        var workoutRecords = [ExerciseRecord]()
        let lines = content.components(separatedBy: .newlines)
        
        for line in lines {
            let comps = line.components(separatedBy: ",")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd yyyy"
            dateFormatter.timeZone = .current
            
            guard
                comps.count > 3, !comps[1].isEmpty,
                let date = dateFormatter.date(from: comps[0]),
                let reps = Int(comps[2]),
                let weight = Double(comps[3])
            else {
                continue
            }
            
            let record = ExerciseRecord(
                date: date,
                exercise: comps[1],
                repetitions: reps,
                weightInPounds: weight,
                oneRM: Utils.calculateOneRepMax(reps: reps, weightInPounds: weight)
            )

            workoutRecords.append(record)
        }

        return workoutRecords
    }
}

