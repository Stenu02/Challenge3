//
//  MainPage.swift
//  Challenge3
//
//  Created by Stefano Nuzzo on 10/12/24.
//

import SwiftUI

struct MainPage: View {
    @State private var showCreateWorkoutView = false
    @State private var savedWorkouts: [Workout] = []

    var body: some View {
        NavigationView {
            VStack {
                Text("GymBro")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(1)
                Divider()
                    .background(Color.black)
                    .frame(width: 100)
                Text("Lift like a bro")
                Divider()
                
                Text("Workout")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Button(action: {
                        showCreateWorkoutView.toggle()
                    }) {
                        VStack(spacing: 10) {
                            Image(systemName: "dumbbell")
                                .font(.system(size: 40))
                                .foregroundColor(.black)
                            Text("New Routine")
                                .font(.body)
                                .foregroundColor(.black)
                        }
                        .frame(width: 180, height: 100)
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                    }
                    
                    Button(action: {
                        print("Suggestion tapped")
                    }) {
                        VStack(spacing: 10) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 40))
                                .foregroundColor(.black)
                            Text("Suggestion")
                                .font(.body)
                                .foregroundColor(.black)
                        }
                        .frame(width: 180, height: 100)
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                    }
                }
                
                Text("List")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                if($savedWorkouts.isEmpty) {
                    Text("No saved workouts")
                }
                
                // Lista degli allenamenti salvati con navigazione al dettaglio
                List {
                    ForEach($savedWorkouts) { $workout in
                        NavigationLink(destination: WorkoutDetailView(workout: $workout)) {
                            VStack(alignment: .leading) {
                                Text(workout.name)
                                    .font(.headline)
                                ForEach(workout.exercises.prefix(3)) { exercise in
                                    Text(exercise.name)
                                        .font(.subheadline)
                                }
                                if workout.exercises.count > 3 {
                                    Text("and \(workout.exercises.count - 3) more...")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteWorkout)
                }
                
                Spacer()
            }
            .sheet(isPresented: $showCreateWorkoutView) {
                CreateWorkoutView()
                    .onDisappear {
                        loadWorkouts()
                    }
            }
            .onAppear {
                loadWorkouts()
            }
        }
    }

    private func loadWorkouts() {
        if let savedWorkoutData = UserDefaults.standard.data(forKey: "savedWorkouts") {
            do {
                let decodedWorkouts = try JSONDecoder().decode([Workout].self, from: savedWorkoutData)
                savedWorkouts = decodedWorkouts
            } catch {
                print("Errore nella decodifica degli allenamenti: \(error)")
            }
        }
    }

    private func deleteWorkout(at offsets: IndexSet) {
        savedWorkouts.remove(atOffsets: offsets)
        saveWorkouts()
    }

    private func saveWorkouts() {
        do {
            let encodedWorkouts = try JSONEncoder().encode(savedWorkouts)
            UserDefaults.standard.set(encodedWorkouts, forKey: "savedWorkouts")
        } catch {
            print("Errore nella codifica degli allenamenti: \(error)")
        }
    }
}

#Preview {
    MainPage()
}
