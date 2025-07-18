//
//  ContentView.swift
//  MindPulse Watch Watch App
//
//  Created by Gaurav Kumar on 7/16/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var watchVM = WatchHealthViewModel()
    var body: some View {
        VStack {
          WatchDashboardView(viewModel: watchVM)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
