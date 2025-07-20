//
//  WatchDashboardView.swift
//  MindPulse Watch Watch App
//
//  Created by Gaurav Kumar on 7/16/25.
//

// WatchDashboardView.swift

import SwiftUI

struct WatchDashboardView: View {
    @ObservedObject var viewModel: WatchHealthViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    Text("PulseMind")
                        .font(.title3.bold())
                        .padding(.top)

                    dashboardCard(title: "Heart Rate", value: viewModel.heartRate, unit: "BPM")
                    dashboardCard(title: "HRV", value: viewModel.hrv, unit: "ms")
                    dashboardCard(title: "Blood Oxygen", value: viewModel.bloodOxygen, unit: "%")
                    dashboardCard(title: "Respiratory Rate", value: viewModel.respiratoryRate, unit: "Breaths/minute")
                    dashboardCard(title: "Stress", value: viewModel.stressScore >= 0 ? Double(viewModel.stressScore) : nil, unit: "/100")

                    NavigationLink(destination: WatchBreathingView()) {
                        Text("🧘 Start Breathing")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .font(.footnote.bold())
                    }
                    .padding(.top)
                }
                .padding(.horizontal, 8)
            }
            .onAppear {
                if !viewModel.isAuthorized {
                    viewModel.requestAuthorization()
                } else {
                    viewModel.loadData()
                }
            }
        }
    }

    private func dashboardCard(title: String, value: Double?, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value != nil ? "\(Int(value!)) \(unit)" : "-- \(unit)")
                .font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.15))
        .cornerRadius(10)
    }
}

#Preview {
    
}

