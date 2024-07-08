//
//  ExerciseListView.swift
//  OneRepMaxChart
//
//  Created by hope on 7/6/24.
//

import SwiftUI

struct ExerciseListView: View {
    @StateObject private var viewModel = ExerciseListViewModel()
    
    var body: some View {
        NavigationStack {
            List(viewModel.exerciseSummaries) { summary in
                exerciseCell(summary)
                    .tag(summary.id)
            }
            .listStyle(.plain)
            .navigationTitle("Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                if case .loading = viewModel.viewState {
                    ProgressView()
                }
            }
            .alert(isPresented: .constant(viewModel.viewState.error != nil)) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.viewState.error!),
                    dismissButton: .destructive(Text("OK"))
                )
            }
        }
        .onAppear {
            viewModel.loadData()
        }
    }
    
    private func exerciseCell(_ data: ExerciseSummary) -> some View {
        ZStack {
            NavigationLink {
                ExerciseDetailView(exercise: data.exercise)
            } label: {
                EmptyView()
            }
            .opacity(0)
            
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(data.exercise)
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("One Rep Max • lbs")
                        .foregroundStyle(.gray)
                }
                .padding(.vertical, 8)
                
                Spacer()
                
                Text("\(data.latestMaxOneRM)")
                    .font(.system(size: 32))
            }
        }
    }
}

#Preview {
    ExerciseListView()
}
