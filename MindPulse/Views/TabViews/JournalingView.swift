//
//  Journal.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/13/25.
//

import SwiftUI

struct JournalingView: View {
    @StateObject private var viewModel = JournalingViewModel()
    @FocusState private var isTextFocused: Bool
    @Namespace private var animation

    var body: some View {
        ScrollView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color("AccentColor"), Color.white]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                VStack(alignment: .leading, spacing: 16) {
                    Text("How are you feeling today?")
                        .font(.title2.bold())
                    
                    // Mood Selection
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(viewModel.moods, id: \.self) { mood in
                                Text(mood)
                                    .font(.system(size: 36))
                                    .frame(width: 60, height: 60)
                                    .background(viewModel.selectedMood == mood ? Color.accentColor.opacity(0.3) : Color.gray.opacity(0.1))
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(viewModel.selectedMood == mood ? Color.accentColor : .clear, lineWidth: 2)
                                    )
                                    .scaleEffect(viewModel.selectedMood == mood ? 1.1 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.selectedMood)
                                    .onTapGesture {
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        withAnimation {
                                            viewModel.selectedMood = mood
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                    
                    // Text Entry
                    ZStack(alignment: .topLeading) {
                        if viewModel.text.isEmpty {
                            Text("Write about your day...")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 10)
                                .padding(.top, 12)
                        }
                        
                        TextEditor(text: $viewModel.text)
                            .focused($isTextFocused)
                            .frame(height: 150)
                            .padding(4)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                            .onSubmit {
                                isTextFocused = false
                            }
                    }
                    
                    // Save Button
                    Button(action: {
                        viewModel.saveEntry()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.selectedMood = ""
                            viewModel.text = ""
                        }
                        isTextFocused = false
                    }) {
                        Label("Save Entry", systemImage: "square.and.pencil")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.selectedMood.isEmpty || viewModel.text.isEmpty ? Color.gray : Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(viewModel.selectedMood.isEmpty || viewModel.text.isEmpty)
                    
                    Divider().padding(.vertical)
                    
                    // Past Entries
                    Text("Past Entries")
                        .font(.title3.bold())
                    
                    if viewModel.entries.isEmpty {
                        Text("No entries yet!")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        List {
                            ForEach(viewModel.entries, id: \.id) { entry in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(entry.mood)
                                            .font(.title3)
                                        Spacer()
                                        Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Text(entry.text)
                                        .font(.body)
                                }
                                .padding(6)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(10)
                                .listRowInsets(EdgeInsets())
                                .padding(.vertical, 4)
                            }
                            .onDelete(perform: viewModel.deleteEntry)
                        }
                        .listStyle(PlainListStyle())
                        .frame(minHeight: 300)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Journal")
        .background(Color(.systemGroupedBackground))
        .onTapGesture { isTextFocused = false }
        .onAppear { viewModel.fetchEntries() }
    }
}

#Preview {
    JournalingView()
}
