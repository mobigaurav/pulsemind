//
//  MainTabView.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/14/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var healthViewModel = HealthKitViewModel()
    @StateObject private var jorunalViewModel = JournalingViewModel()
    var body: some View {
        TabView {
            DashboardView(viewModel: healthViewModel, journalViewModel: jorunalViewModel)
                .tabItem {
                    Label("Dashboard", systemImage: "heart.fill")
                }

            JournalingView()
                .tabItem {
                    Label("Journal", systemImage: "book")
                }

            TrendsView(viewModel: healthViewModel, journalViewModel: jorunalViewModel)
                .tabItem {
                    Label("Trends", systemImage: "chart.line.uptrend.xyaxis")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    MainTabView()
}

//ff9c40046be0467cb94a8624b6eea9dd

