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

                // Stress Trend
                VStack(alignment: .leading, spacing: 12) {
                    Text("Stress Trend (Last 7 Days)")
                        .font(.title2)
                        .bold()
                    
                    Chart(viewModel.stressHistory) { entry in
                        LineMark(
                            x: .value("Date", entry.date),
                            y: .value("Stress Score", entry.score)
                        )
                        .symbol(Circle())
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Color.orange)
                    }
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: 7)) { value in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel {
                                if let dateValue = value.as(Date.self) {
                                    Text(dateValue, format: .dateTime.weekday(.narrow))
                                        .font(.caption2)
                                        .rotationEffect(.degrees(-30))
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(preset: .extended, position: .leading) // auto handle spacing
                    }
                    .chartYScale(domain: 0...100)
                    .frame(height: 260)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)

                }

                // Mood Frequency
                if !journalViewModel.entries.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Mood Frequency")
                            .font(.title2)
                            .bold()

                        HStack(spacing: 16) {
                            ForEach(journalViewModel.moodFrequencySorted(), id: \.key) { mood, count in
                                VStack {
                                    Text(mood)
                                        .font(.system(size: 36))
                                    Text("\(count)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.top, 8)
                    }
                }

                Spacer()
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




