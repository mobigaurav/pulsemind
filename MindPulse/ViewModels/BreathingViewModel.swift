//
//  BreathingViewModel.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/13/25.
//

import Foundation
import Combine

class BreathingViewModel: ObservableObject {
    @Published var timeRemaining: Int = 60
    @Published var isBreathing: Bool = false

    private var timer: AnyCancellable?

    func startBreathing() {
        timeRemaining = 60
        isBreathing = true

        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }

                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.stopBreathing()
                }
            }
    }

    func stopBreathing() {
        timer?.cancel()
        timer = nil
        isBreathing = false
    }
}

