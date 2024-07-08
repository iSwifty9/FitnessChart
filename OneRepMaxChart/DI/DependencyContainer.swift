//
//  DependencyContainer.swift
//  OneRepMaxChart
//
//  Created by hope on 7/6/24.
//

import Foundation

final class DependencyContainer {
    static let shared = DependencyContainer()
    
    private init() {}
    
    lazy var apiClient: APIClient = {
        MockAPIClient()
    }()

    lazy var dataRepository: WorkoutRepository = {
       WorkoutDataRepository(apiClient: apiClient)
    }()
    
    lazy var dataManager: WorkoutDataManager = {
       WorkoutDataManager(repository: dataRepository)
    }()
}
