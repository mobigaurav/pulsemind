//
//  DashboardSplitView.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/29/25.
//

import SwiftUI

struct DashboardSplitView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @ObservedObject var viewModel: HealthKitViewModel
    @ObservedObject var journalViewModel: JournalingViewModel
    @State private var showStressInfo = false
    
    var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                NavigationSplitView {
                    // Optional sidebar placeholder or menu
                    List {
                        Label("Dashboard", systemImage: "house")
                    }
                    .navigationTitle("PulseMind")
                } detail: {
                    DashboardContentView(
                        viewModel: viewModel,
                        journalViewModel: journalViewModel,
                        showStressInfo: $showStressInfo
                    )
                }
            } else {
                NavigationStack {
                    DashboardContentView(
                        viewModel: viewModel,
                        journalViewModel: journalViewModel,
                        showStressInfo: $showStressInfo
                    )
                    .navigationTitle("PulseMind")
                }
            }
        }
        .onAppear {
            viewModel.checkAuthorizationNeeded()
            viewModel.startWatchConnectivityBridge()
            journalViewModel.fetchRecentMoods()
        }
        .alert(item: $viewModel.activeAlert) { alertType in
            switch alertType {
            case .requestPermission:
                return Alert(
                    title: Text("Health Access Needed"),
                    message: Text("PulseMind uses Apple Health data (like HRV, sleep, and heart rate) to calculate your stress score. Your data stays private on your device."),
                    dismissButton: .default(Text("Continue")) {
                        viewModel.requestHealthAccess()
                    }
                )
            case .accessDenied:
                return Alert(
                    title: Text("Health Access Denied"),
                    message: Text("You can enable access anytime in Settings → Privacy → Health → PulseMind."),
                    primaryButton: .default(Text("Open Settings")) {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    },
                    secondaryButton: .cancel(Text("Not Now"))
                )
            }
        }
    }
}

