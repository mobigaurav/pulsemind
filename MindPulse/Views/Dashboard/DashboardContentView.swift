//
//  DashboardContentView.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/29/25.
//
import SwiftUI

struct DashboardContentView: View {
    @ObservedObject var viewModel: HealthKitViewModel
    @ObservedObject var journalViewModel: JournalingViewModel
    @Binding var showStressInfo: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                DailyAffirmationCardView()
                QuickActionsView()

                Group {
                    HStack {
                        MetricCardView(title: "Heart Rate", value: viewModel.heartRate, unit: "BPM", color: .red)
                        MetricCardView(title: "HRV", value: viewModel.hrv, unit: "ms", color: .blue)
                    }

                    HStack {
                        MetricCardView(title: "Sleep Duration", value: viewModel.sleepHours, unit: "hrs", color: .purple)
                        if let oxygen = viewModel.bloodOxygen {
                            MetricCardView(title: "Blood Oxygen", value: oxygen * 100, unit: "%", color: .teal)
                        }
                    }

                    HStack {
                        if let breathRate = viewModel.respiratoryRate {
                            MetricCardView(title: "Respiratory Rate", value: breathRate, unit: "breaths/min", color: .mint)
                        }

                        MetricCardView(
                            title: "Stress Score",
                            value: viewModel.stressScore >= 0 ? Double(viewModel.stressScore) : nil,
                            unit: "/100",
                            color: .orange
                        )
                        .onTapGesture {
                            showStressInfo = true
                        }
                        .sheet(isPresented: $showStressInfo) {
                            VStack(spacing: 16) {
                                Text("How is Stress Score Calculated?")
                                    .font(.headline)

                                Text("""
                                   Your stress score (out of 100) is calculated using:
                                   - Heart Rate (BPM)
                                   - Heart Rate Variability (HRV)
                                   - Respiratory Rate
                                   - Sleep Duration
                                   
                                   Higher HRV and longer sleep generally reduce your stress score, while elevated heart rate and respiratory rate can increase it.
                                   """)
                                .font(.callout)
                                .padding()

                                Button("Close") {
                                    showStressInfo = false
                                }
                                .padding()
                            }
                            .padding()
                        }
                    }
                }

                if !journalViewModel.recentMoods.isEmpty {
                    MoodSummaryScrollView(moods: journalViewModel.recentMoods)
                }
            }
            .padding()
        }
    }
}

