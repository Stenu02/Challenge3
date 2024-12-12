//
//  CreateWorkoutView.swift
//  Challenge3
//
//  Created by Stefano Nuzzo on 10/12/24.
//
import SwiftUI
import SDWebImageSwiftUI

struct CreateWorkoutView: View {
    @Environment(\.presentationMode) var presentationMode // Per controllare la chiusura della vista
    @StateObject private var viewModel = ExerciseViewModel()
    @State private var selectedBodyPart: String = "All"
    @State private var selectedExercises: [Exercise] = []
    @State private var workoutName: String = ""
    @State private var savedWorkouts: [Workout] = []
    @State private var showSelectedExercises = false

    private let bodyParts = ["All", "cardio", "chest", "lower arms", "lower legs", "neck", "shoulders", "upper arms", "upper legs", "waist"]

    var filteredExercises: [Exercise] {
        if selectedBodyPart == "All" {
            return viewModel.exercises
        }
        return viewModel.exercises.filter { $0.bodyPart == selectedBodyPart }
    }


    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Campo per il nome del workout
                TextField("Workout Name", text: $workoutName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                // Filtro per parte del corpo
                Picker("Parte del corpo", selection: $selectedBodyPart) {
                    ForEach(bodyParts, id: \.self) { part in
                        Text(part).tag(part)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.horizontal)
                
                // Lista degli esercizi filtrati
                List(filteredExercises) { exercise in
                    HStack {
                        if let url = URL(string: exercise.gifUrl) {
                            AnimatedImage(url: url)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 80)
                        }
                        VStack(alignment: .leading, spacing: 5) {
                            Text(exercise.name.capitalized)
                                .font(.headline)
                            Text("BodyPart: \(exercise.bodyPart.capitalized)")
                                .font(.subheadline)
                        }
                        Spacer()
                        // Pulsante per aggiungere l'esercizio
                        Button(action: {
                            if !selectedExercises.contains(where: { $0.id == exercise.id }) {
                                selectedExercises.append(exercise)
                            }
                        }) {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.green)
                        }
                    }
                }
                
                // Bottone per mostrare/nascondere gli esercizi selezionati
                Button(action: {
                    showSelectedExercises.toggle()
                }) {
                    HStack {
                        Text("Selected Exercises")
                            .font(.headline)
                        Spacer()
                        Image(systemName: showSelectedExercises ? "chevron.up" : "chevron.down")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Sezione degli esercizi selezionati
                if showSelectedExercises {
                    VStack(alignment: .leading) {
                        List {
                            ForEach(selectedExercises) { exercise in
                                Text(exercise.name)
                            }
                        }
                        Button("Save Workout"){
                            if !workoutName.isEmpty {
                                saveWorkout()
                                presentationMode.wrappedValue.dismiss() // Chiudi la vista
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top)
                }

            }
            .navigationTitle("New Workout")
            .onAppear {
                viewModel.fetchExercises()
            }
        }
    }
    
    private func saveWorkout() {
        let workout = Workout(name: workoutName, exercises: selectedExercises)
        do {
            _ = try JSONEncoder().encode(workout)
            var currentWorkouts = loadWorkouts() // Recupera gli allenamenti salvati
            currentWorkouts.append(workout) // Aggiungi il nuovo allenamento
            let encodedAllWorkouts = try JSONEncoder().encode(currentWorkouts)
            UserDefaults.standard.set(encodedAllWorkouts, forKey: "savedWorkouts")
        } catch {
            print("Errore nella codifica dell'allenamento: \(error)")
        }
    }
    
    private func loadWorkouts() -> [Workout] {
        if let savedWorkoutData = UserDefaults.standard.data(forKey: "savedWorkouts") {
            do {
                let decodedWorkouts = try JSONDecoder().decode([Workout].self, from: savedWorkoutData)
                savedWorkouts = decodedWorkouts
                return decodedWorkouts
            } catch {
                print("Errore nella decodifica degli allenamenti: \(error)")
            }
        }
        return []
    }
}


#Preview {
    CreateWorkoutView()
}
