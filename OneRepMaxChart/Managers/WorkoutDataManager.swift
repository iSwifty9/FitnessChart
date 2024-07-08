//
//  WorkoutDataManager.swift
//  OneRepMaxChart
//
//  Created by hope on 7/6/24.
//

import Foundation

actor WorkoutDataManager {
    private var records: [ExerciseRecord] = []
    
    /// The index key is the exercise name, and the value is a dictionary where:
    /// - The key is a midnight date in the device time zone (formatted as "yyyy-MM-dd 00:00:00 Z"), allowing for daily indexing.
    /// - The value is an array of indices from the `records` array, optimizing memory usage by storing the indices.
    ///
    /// Note: Do not delete items from the `records` array, as this will change the indices and cause inconsistencies in `recordsIndex`.
    private var recordsIndex: [String: [Date:[Int]]] = [:]
    
    private let repository: WorkoutRepository
    private var lastRecordIndex = -1

    var exerciseList: [String] {
        Array(recordsIndex.keys)
    }
    
    init(repository: WorkoutRepository) {
        self.repository = repository
    }
    
    /// Loads workout records from the repository and updates the records index.
    ///
    /// - Parameter range: The date range for loading records. If nil, loads all records.
    func loadWorkoutData(in range: ClosedRange<Date>? = nil) async throws {
        let newRecords = try await repository.loadWorkoutData()
        
        if !newRecords.isEmpty {
            records.append(contentsOf: newRecords)
            updateIndex()
        }
    }
    
    /// Retrieves the records for a specific exercise.
    func getExerciseRecords(_ exercise: String) -> [Date: [ExerciseRecord]]? {
        guard let exerciseIndex = self.recordsIndex[exercise] else {
            return nil
        }
        
        return exerciseIndex.mapValues { indices in
            indices.map { records[$0] }
        }
    }
    
    /// Retrieves the records for a specific date across all exercises.
    func getExerciseRecords(byDate date: Date) -> [ExerciseRecord] {
        var result = [ExerciseRecord]()
        
        for exercise in exerciseList {
            if let recordIndices = recordsIndex[exercise]?[date] {
                result.append(contentsOf: recordIndices.map { records[$0] })
            }
        }
        
        return result
    }
    
    /// Marks the specific records as deleted.
    ///
    /// Note: Setting `isDeleted` acts as a soft delete to avoid updating `recordsIndex` due to real deletion from the array.
    ///
    /// - Parameter indices: The indices of the records to mark as deleted.
    func deleteRecords(_ records: [ExerciseRecord]) {
        for record in records {
            if let index = self.records.firstIndex(
                where: { $0.date == record.date && $0.exercise == record.exercise }
            ) {
                self.records[index].isDeleted = true
                // Note: Run actual deletion of records in local and remote database
            }
        }
    }
    
    /// Updates the index for new records.
    private func updateIndex() {
        let newItemRange = (lastRecordIndex + 1)..<records.count
        for index in newItemRange {
            if let midnight = records[index].date.toMidnight {
                let exercise = records[index].exercise
                recordsIndex[exercise, default: [:]][midnight, default: []].append(index)
            }
        }
        lastRecordIndex = records.count - 1
    }
}
