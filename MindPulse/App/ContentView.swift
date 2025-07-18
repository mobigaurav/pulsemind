//
//  ContentView.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/13/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = HealthKitViewModel()
    var body: some View {
        //DashboardView(viewModel: viewModel)
    }
}

#Preview {
    ContentView()
}
