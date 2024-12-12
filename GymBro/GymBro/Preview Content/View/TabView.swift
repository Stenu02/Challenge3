//
//  TabView.swift
//  Challenge3
//
//  Created by Stefano Nuzzo on 10/12/24.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            Tab("Workout", systemImage: "dumbbell") {
                MainPage()
            }
            Tab("Calendar", systemImage: "calendar") {
                WorkoutCalendarView()
             }
            Tab("Profile", systemImage: "person") {
                MainPage()
            }
        }
    }
}

#Preview {
    MainView()
}
