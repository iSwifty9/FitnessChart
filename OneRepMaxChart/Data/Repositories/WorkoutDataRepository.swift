//
//  WorkoutDataRepository.swift
//  OneRepMaxChart
//
//  Created by hope on 7/6/24.
//

import Foundation

protocol WorkoutRepository {
    func loadWorkoutData() async throws -> [ExerciseRecord]
}

final class WorkoutDataRepository: WorkoutRepository {
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func loadWorkoutData() async throws -> [ExerciseRecord] {
        try await apiClient.fetchWorkoutData()
    }
}
