//
//  ExerciseDetailViewModel.swift
//  OneRepMaxChart
//
//  Created by hope on 7/6/24.
//

import Foundation

final class ExerciseDetailViewModel: ObservableObject {
    @Published private(set) var viewState: ViewState = .idle
    @Published private(set) var backwardButtonDisabled = true
    @Published private(set) var forwardButtonDisabled = true
    
    private(set) var dailyOneRMs = [DailyOneRM]()
    private(set) var maxOneRM: Int = 0
    var currentTimeFrame: TimeFrame = .month
    let exercise: String
    private let dataManager: WorkoutDataManager
    private var exerciseOneRMData: [Date: [Double]] = [:]
    private var upperExerciseDate: Date = .now
    private var lowerExerciseDate: Date = .now
    private var currentUpperDate: Date?
    private var currentLowerDate: Date?
    private(set) var dateRangeString: String = ""
    private(set) var startOfWeekDates: [Date] = []
    
    init(
        exercise: String,
        dataManager: WorkoutDataManager = DependencyContainer.shared.dataManager
    ) {
        self.exercise = exercise
        self.dataManager = dataManager
    }

    @MainActor
    func loadData() {
        viewState = .loading
        
        Task {
            guard
                let records = await dataManager.getExerciseRecords(exercise),
                !records.isEmpty
            else {
                viewState = .failed("There is no exercise data!")
                return
            }
            
            upperExerciseDate = records.keys.max()!
            lowerExerciseDate = records.keys.min()!
            exerciseOneRMData = records.mapValues { $0.map { record in record.oneRM }}
            loadOneRMDataForTimeFrame(isBackward: nil)
            viewState = .finished
        }
    }
    
    func loadOneRMDataForTimeFrame(isBackward: Bool?) {
        let (lowerDate, upperDate) = getDateRange(isBackward: isBackward)
        
        guard
            let lowerDate, let upperDate,
            let datesBetween = Utils.datesBetween(startDate: lowerDate, endDate: upperDate)
        else {
            viewState = .failed("Failed to calcuate date range")
            return
        }
        
        var dailyOneRMs = [DailyOneRM]()
        var maxOneRM: Double = 0
        var startOfWeekDates = [Date]()

        for day in datesBetween {
            let dailyMaxRM = exerciseOneRMData[day]?.max() ?? 0
            dailyOneRMs.append(DailyOneRM(date: day, value: Int(dailyMaxRM)))
            maxOneRM = max(maxOneRM, dailyMaxRM)
            
            if day == day.startOfWeek {
                startOfWeekDates.append(day)
            }
        }

        // Update view properties
        
        dateRangeString = Utils.dateRangeString(
            lowerDate: lowerDate,
            upperDate: upperDate,
            yearOnly: currentTimeFrame == .year)
        
        currentLowerDate = lowerDate
        currentUpperDate = upperDate
        backwardButtonDisabled = lowerDate <= lowerExerciseDate
        forwardButtonDisabled = upperDate >= upperExerciseDate
        self.maxOneRM = Int(maxOneRM)
        self.dailyOneRMs = dailyOneRMs
        self.startOfWeekDates = startOfWeekDates
    }
    
    /// Calculates the date range by either navigating backward or forward based on the `isBackward` parameter.
    /// If `isBackward` is nil, it calculates the initial date range.
    private func getDateRange(isBackward: Bool?) -> (lower: Date?, upper: Date?) {
        var upperDate: Date?
        var lowerDate: Date?
        
        if isBackward == nil {
            // Initial date range calculation
            upperDate = upperExerciseDate
            lowerDate = Calendar.current.date(byAdding: currentTimeFrame.unit, value: -1, to: upperExerciseDate)
        } else {
            // Date range calculation for navigating back or forth
            if let currentLowerDate, let currentUpperDate {
                if isBackward == true {
                    upperDate = Calendar.current.date(
                        byAdding: .day,
                        value: -1,
                        to: currentLowerDate)
                    lowerDate = upperDate.flatMap {
                        Calendar.current.date(
                            byAdding: currentTimeFrame.unit,
                            value: -1,
                            to: $0)
                    }
                } else {
                    lowerDate = Calendar.current.date(
                        byAdding: .day,
                        value: 1,
                        to: currentUpperDate)
                    upperDate = lowerDate.flatMap {
                        Calendar.current.date(
                            byAdding: currentTimeFrame.unit,
                            value: 1,
                            to: $0)
                    }
                }
            }
        }

        return (lowerDate, upperDate)
    }
}
