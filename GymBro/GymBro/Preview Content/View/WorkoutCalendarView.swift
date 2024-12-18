//
//  WorkoutCalendarView.swift
//  Challenge3
//
//  Created by Stefano Nuzzo on 12/12/24.
//
import SwiftUI


struct WorkoutCalendarView: View {
    @State private var selectedDate = Date()
    @State private var workoutSchedule: [String: [Workout]] = [:]
    @State private var savedWorkouts: [Workout] = []
    @State private var selectedWorkoutsForDay: [Workout] = []

    var body: some View {
        NavigationView {
            VStack {
                
                Section(header: Text("Select a Date").font(.headline).padding(.top)) {
                    DatePicker("Select a Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding(.horizontal)
                        .padding(.top, 10)
                }
                
                Divider()
                    .padding(.horizontal)
                
                HStack(spacing: 20) {
                    
                    VStack(alignment: .leading) {
                        Text("Assign Workout")
                            .font(.headline)
                            .padding(.leading, 15)
                            .padding(.top, 10)
                        
                        List(savedWorkouts) { workout in
                            Button(action: {
                                assignWorkout(to: selectedDate, workout: workout)
                            }) {
                                HStack {
                                    Text(workout.name)
                                    Spacer()
                                    Image(systemName: "calendar.badge.plus")
                                        .foregroundColor(.blue)
                                }
                                .padding(.vertical, 5)
                            }
                        }
                        .listStyle(PlainListStyle())
                        
                        .padding()
                    }
                    
                    Divider()
                        .frame(height: 300)
                        .padding(.vertical)
                    
                    
                    VStack(alignment: .leading) {
                        Text("Workouts for \(formattedDate(selectedDate))")
                            .font(.headline)
                            .padding(.leading, 15)
                            .padding(.top, 10)
                        
                        if selectedWorkoutsForDay.isEmpty {
                            Text("No workouts assigned to this date.")
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                                .padding(.vertical, 10)
                        } else {
                            List {
                                ForEach(selectedWorkoutsForDay) { workout in
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
                                    .padding(.vertical, 5)
                                }
                                .onDelete(perform: deleteWorkout)
                            }
                            .listStyle(PlainListStyle())
                            //.padding(.horizontal)
                            .padding()
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal)
            }
          
            .onAppear {
                loadWorkouts()
                updateSelectedWorkoutsForDay()
            }
            .onChange(of: selectedDate) { _ in
                updateSelectedWorkoutsForDay()
            }
            .onChange(of: savedWorkouts) { _ in
                cleanupDeletedWorkouts()
            }
        }
    }

    private func assignWorkout(to date: Date, workout: Workout) {
        let dateKey = formattedDate(date)
        if workoutSchedule[dateKey] != nil {
            workoutSchedule[dateKey]?.append(workout)
        } else {
            workoutSchedule[dateKey] = [workout]
        }
        updateSelectedWorkoutsForDay()
        saveSchedule()
    }

    private func deleteWorkout(at offsets: IndexSet) {
        let dateKey = formattedDate(selectedDate)
        guard var workoutsForDay = workoutSchedule[dateKey] else { return }
        workoutsForDay.remove(atOffsets: offsets)
        workoutSchedule[dateKey] = workoutsForDay.isEmpty ? nil : workoutsForDay
        updateSelectedWorkoutsForDay()
        saveSchedule()
    }

    private func updateSelectedWorkoutsForDay() {
        let dateKey = formattedDate(selectedDate)
        selectedWorkoutsForDay = workoutSchedule[dateKey] ?? []
    }

    private func saveSchedule() {
        do {
            let encodedSchedule = try JSONEncoder().encode(workoutSchedule)
            UserDefaults.standard.set(encodedSchedule, forKey: "workoutSchedule")
        } catch {
            print("Errore nel salvataggio del calendario: \(error)")
        }
    }

    private func loadSchedule() {
        if let savedScheduleData = UserDefaults.standard.data(forKey: "workoutSchedule") {
            do {
                let decodedSchedule = try JSONDecoder().decode([String: [Workout]].self, from: savedScheduleData)
                workoutSchedule = decodedSchedule
            } catch {
                print("Errore nella decodifica del calendario: \(error)")
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
        loadSchedule()
    }

    private func cleanupDeletedWorkouts() {
       
        for (date, workouts) in workoutSchedule {
            workoutSchedule[date] = workouts.filter { savedWorkouts.contains($0) }
        }
        updateSelectedWorkoutsForDay()
        saveSchedule()
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    WorkoutCalendarView()
}
