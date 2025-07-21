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
            List {
                Section(header: Text("PulseMind").font(.headline)) {
                    dashboardCard(title: "Heart Rate", value: viewModel.heartRate, unit: "BPM")
                    dashboardCard(title: "HRV", value: viewModel.hrv, unit: "ms")
                    dashboardCard(title: "Blood Oxygen", value: viewModel.bloodOxygen, unit: "%")
                    dashboardCard(title: "Respiratory Rate", value: viewModel.respiratoryRate, unit: "breaths/min")
                    dashboardCard(title: "Stress", value: viewModel.stressScore >= 0 ? Double(viewModel.stressScore) : nil, unit: "/100")

                    NavigationLink("🧘 Start Breathing") {
                        WatchBreathingView()
                    }
                    .font(.footnote.bold())
                }
            }
            .listStyle(.carousel) // Ensures optimized behavior on watchOS
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
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value != nil ? "\(Int(value!)) \(unit)" : "-- \(unit)")
                .font(.body.weight(.medium))
        }
        .padding(.vertical, 4)
    }
}


#Preview {
    WatchDashboardView(viewModel: .init())
}

