//
//  ExerciseDetailView.swift
//  OneRepMaxChart
//
//  Created by hope on 7/6/24.
//

import SwiftUI
import Charts

struct ExerciseDetailView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel: ExerciseDetailViewModel
    
    // Calculating the range for Y-axis of the chart
    private var oneRMRange: ClosedRange<Int> {
        let maxRange = viewModel.maxOneRM == 0 ? 500 : viewModel.maxOneRM
        return 0...maxRange
    }
    
    private var isDarkMode: Bool { colorScheme == .dark }
    
    init(exercise: String) {
        let vm = ExerciseDetailViewModel(exercise: exercise)
        _viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            switch viewModel.viewState {
            case .loading:
                ProgressView()
            case .finished:
                dateRangeView
                exerciseSummaryView
                chartView
                Spacer()
            default:
                EmptyView()
            }
        }
        .padding(.horizontal)
        .toolbarRole(.editor)
        .alert(isPresented: .constant(viewModel.viewState.error != nil)) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.viewState.error!),
                dismissButton: .destructive(Text("OK"))
            )
        }
        .onAppear {
            viewModel.loadData()
        }
    }
    
    @ViewBuilder
    private var dateRangeView: some View {
        VStack(spacing: 16) {
            Picker("Select time frame", selection: $viewModel.currentTimeFrame) {
                ForEach(TimeFrame.allCases) { timeFrame in
                    Text(timeFrame.description)
                        .tag(timeFrame)
                }
            }
            .pickerStyle(.segmented)
            .disabled(true)
            
            HStack(spacing: 16) {
                previousForwardButton(isBackward: true)
                
                Text(viewModel.dateRangeString)
                    .frame(width: 220)
                
                previousForwardButton(isBackward: false)
            }
        }
    }
    
    private var exerciseSummaryView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(viewModel.exercise)
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("One Rep Max • lbs")
                    .foregroundStyle(.gray)
            }
            .padding(.vertical, 8)

            Spacer()

            Text("\(viewModel.maxOneRM)")
                .font(.system(size: 32))
        }
    }

    private var chartView: some View {
        Chart(viewModel.dailyOneRMs) { oneRM in
            LineMark(
                x: .value("Date", oneRM.date, unit: .day),
                y: .value("OneRepMax", oneRM.value)
            )
            .symbol(Circle())
        }
        .chartXAxis {
            AxisMarks(values: viewModel.startOfWeekDates) { value in
                if let date = value.as(Date.self) {
                    let label = formattedDate(for: date)
                    let isBoundary = label.count > 2
                    
                    AxisValueLabel {
                        Text(label)
                            .font(.system(size: 14))
                            .fontWeight(.semibold)
                            .frame(minWidth: isBoundary ? 60 : 0)
                            .foregroundStyle(
                                isBoundary ? (isDarkMode ? .white : .black) : .gray
                            )
                            .padding(.top, 16)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(values: [0, viewModel.maxOneRM]) { value in
                if let intValue = value.as(Int.self) {
                    AxisValueLabel {
                        Text("\(intValue)")
                            .font(.system(size: 14))
                    }
                }
            }
        }
        .chartYScale(domain: oneRMRange)
        .frame(height: 300)
        .foregroundStyle(
            isDarkMode ? .white : .black
        )
    }
    
    @ViewBuilder
    private func previousForwardButton(isBackward: Bool) -> some View {
        let buttonDisabled = isBackward ? viewModel.backwardButtonDisabled : viewModel.forwardButtonDisabled
        
        Button {
            viewModel.loadOneRMDataForTimeFrame(isBackward: isBackward)
        } label: {
            Image(systemName: isBackward ? "chevron.left" : "chevron.right")
                .resizable()
                .scaledToFit()
                .frame(height: 18)
        }
        .frame(width: 42, height: 28)
        .background(.gray.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .opacity(buttonDisabled ? 0 : 1)
    }
    
    /// Formats the date for the X-axis.
    ///
    /// Note: Displays only the start day of each week, and format the first and last items as "MMM d".
    /// Other week start days are formatted as "d".
    private func formattedDate(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        let index = viewModel.startOfWeekDates.firstIndex(of: date)
        
        if index == 0 || index == viewModel.startOfWeekDates.count - 1 {
            dateFormatter.dateFormat = "MMM d"
        } else {
            dateFormatter.dateFormat = "d"
        }

        return dateFormatter.string(from: date)
    }
}

#Preview {
    ExerciseDetailView(exercise: "Back Squat")
}
