//
//  Dashboard.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/13/25.
//
import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: HealthKitViewModel
    @ObservedObject var journalViewModel: JournalingViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {


                    // Daily Affirmation
                    DailyAffirmationCardView()
                      
//                    // News Articles
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack(spacing: 16) {
//                            ForEach(SampleArticles.articles) { article in
//                                ArticleCardView(article: article)
//                            }
//                        }
//                        .padding(.horizontal)
//                    }

                    // Quick Actions
                    QuickActionsView()

                    // Health Metrics
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
                        }
                       
                    }

                    // Mood Summary
                    if !journalViewModel.recentMoods.isEmpty {
                        MoodSummaryScrollView(moods: journalViewModel.recentMoods)
                    }
                    
//                    NavigationLink(destination: FocusTimerView()) {
//                        FocusTimerCardView()
//                    }
//                    .buttonStyle(PlainButtonStyle())
//
//                    // Breathing session
//                    NavigationLink(destination: BreathingView()) {
//                        BreathingCardView()
//                    }
//                    .padding(.top, 10)
                }
                .padding()
            }
            .navigationTitle("PulseMind")
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
                    message: Text("PulseMind would like to access your health data to provide stress and wellness insights."),
                    primaryButton: .default(Text("Allow")) {
                        viewModel.requestHealthAccess()
                    },
                    secondaryButton: .cancel(Text("Not Now"))
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



#Preview {
    DashboardView(viewModel: .init(), journalViewModel: .init())
}
