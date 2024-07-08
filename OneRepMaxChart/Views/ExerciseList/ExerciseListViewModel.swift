//
//  ExerciseListViewModel.swift
//  OneRepMaxChart
//
//  Created by hope on 7/6/24.
//

import Foundation

final class ExerciseListViewModel: ObservableObject {
    @Published private(set) var viewState: ViewState = .idle
    
    private(set) var exerciseSummaries = [ExerciseSummary]()
    private let dataManager: WorkoutDataManager

    init(workoutDataManager: WorkoutDataManager = DependencyContainer.shared.dataManager) {
        dataManager = workoutDataManager
    }
    
    @MainActor
    func loadData() {
        viewState = .loading
        exerciseSummaries = []
        
        Task {
            do {
                try await dataManager.loadWorkoutData()
                let allExercises = await dataManager.exerciseList
                
                for exercise in allExercises {
                    if let exerciseRecords = await dataManager.getExerciseRecords(exercise) {
                        let allPRValues = exerciseRecords.values.flatMap { $0 }.map { $0.oneRM }
                        if let maxPR = allPRValues.max() {
                            let summary = ExerciseSummary(
                                exercise: exercise,
                                latestMaxOneRM: Int(maxPR)
                            )
                            exerciseSummaries.append(summary)
                        }
                    }
                }
                
                viewState = .finished
            } catch {
                viewState = .failed(error)
            }
        }
    }
}
