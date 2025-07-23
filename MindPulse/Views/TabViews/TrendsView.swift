//
//  TrendsView.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/14/25.
//

import SwiftUI
import Charts

struct TrendsView: View {
    @ObservedObject var viewModel: HealthKitViewModel
    @ObservedObject var journalViewModel: JournalingViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // MARK: - Stress Trend
                VStack(alignment: .leading, spacing: 12) {
                    Text("Stress Trend (Last 7 Days)")
                        .font(.title2)
                        .bold()

                    Chart {
                        ForEach(viewModel.stressHistory) { entry in
                            LineMark(
                                x: .value("Date", entry.date),
                                y: .value("Stress Score", entry.score)
                            )
                            .interpolationMethod(.catmullRom)
                            .symbol(Circle())
                            .foregroundStyle(Color.orange)
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: viewModel.stressHistory.map { $0.date }) { value in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel {
                                if let dateValue = value.as(Date.self) {
                                    Text(dateValue, format: .dateTime.weekday(.abbreviated))
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks()
                    }
                    .frame(height: 260)
                }

                Spacer()
                // MARK: - Mood Frequency (Bar Chart)
                if !journalViewModel.entries.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Mood Frequency")
                            .font(.title2)
                            .bold()

                        Chart {
                            ForEach(journalViewModel.moodFrequencySorted(), id: \.key) { mood, count in
                                BarMark(
                                    x: .value("Mood", mood),
                                    y: .value("Count", count)
                                )
                                .foregroundStyle(Color.accentColor)
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .automatic) { value in
                                AxisGridLine()
                                AxisTick()
                                AxisValueLabel()
                            }
                        }
                        .chartYAxis {
                            AxisMarks()
                        }
                        .frame(height: 260)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                    }
                }
                
                Spacer()
                
//                VStack(alignment: .leading, spacing: 12) {
//                    Text("Mood vs Stress")
//                        .font(.title2)
//                        .bold()
//
//                    Chart {
//                        ForEach(viewModel.stressHistory) { entry in
//                            LineMark(
//                                x: .value("Date", entry.date),
//                                y: .value("Stress Score", entry.score)
//                            )
////                            .foregroundStyle(.orange)
////                            .symbol(Circle())
//                        }
//
//                        ForEach(journalViewModel.moodTrendEntries()) { entry in
//                            LineMark(
//                                x: .value("Date", entry.date),
//                                y: .value("Mood Score", entry.moodScore * 20) // Scale mood (1-5) to match stress range
//                            )
//                            //.foregroundStyle(.blue)
//                        }
//                    }
////                    .chartYScale(domain: 0...100)
////                    .frame(height: 260)
////                    .background(Color(.secondarySystemBackground))
////                    .cornerRadius(16)
//                }


            }
            .padding()
        }
        .navigationTitle("Your Trends")
        .onAppear {
            viewModel.fetchStressHistory()
            journalViewModel.fetchEntries()
        }
    }
}

#Preview {
    TrendsView(viewModel: .init(), journalViewModel: .init())
}





