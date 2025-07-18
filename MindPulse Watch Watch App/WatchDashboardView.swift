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
        ScrollView {
            VStack(spacing: 8) {
                Text("MindPulse")
                    .font(.headline)

                metricRow("HR", value: viewModel.heartRate, unit: "BPM")
                metricRow("HRV", value: viewModel.hrv, unit: "ms")
                metricRow("Stress", value: viewModel.stressScore >= 0 ? Double(viewModel.stressScore) : nil, unit: "/100")

                NavigationLink("Breathe") {
                    WatchBreathingView()
                }
            }
            .padding(.vertical, 4)
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

    @ViewBuilder
    private func metricRow(_ title: String, value: Double?, unit: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            if let v = value {
                Text(unit == "/100" ? "\(Int(v))\(unit)" : "\(Int(v)) \(unit)")
            } else {
                Text("-- \(unit)")
                    .foregroundColor(.gray)
            }
        }
    }
}


