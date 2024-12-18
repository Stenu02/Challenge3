//
//  ContentView.swift
//  Challenge3
//
//  Created by Stefano Nuzzo on 04/12/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct ExerciseListView: View {
    @StateObject private var viewModel = ExerciseViewModel()
    @State private var selectedBodyPart: String = "Tutti" 
    private let bodyParts = ["Tutti", "upper legs", "back", "armor", "waist", "shoulders","chest"]

    var filteredExercises: [Exercise] {
        if selectedBodyPart == "Tutti" {
            return viewModel.exercises
        }
        return viewModel.exercises.filter { $0.bodyPart == selectedBodyPart }
    }

    var body: some View {
        NavigationView {
            VStack {
                // Menu di selezione per il filtro
                Picker("Parte del corpo", selection: $selectedBodyPart) {
                    ForEach(bodyParts, id: \.self) { part in
                        Text(part).tag(part)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                Group {
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    } else {
                        List(filteredExercises) { exercise in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(exercise.name.capitalized)
                                    .font(.headline)
                                Text("Parte del corpo: \(exercise.bodyPart.capitalized)")
                                    .font(.subheadline)
                                Text("Attrezzatura: \(exercise.equipment)")
                                    .font(.subheadline)
                                
                                
                                if let url = URL(string: exercise.gifUrl) {
                                    AnimatedImage(url: url)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 150)
                                }

                                Text("Muscoli secondari: \(exercise.secondaryMuscles.joined(separator: ", "))")
                                    .font(.subheadline)
                                Text("Istruzioni:")
                                    .font(.subheadline)
                                ForEach(exercise.instructions, id: \.self) { step in
                                    Text("- \(step)")
                                        .font(.caption)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
                .navigationTitle("Esercizi")
                .onAppear {
                    viewModel.fetchExercises()
                }
            }
        }
    }
}

#Preview {
    ExerciseListView()
}
