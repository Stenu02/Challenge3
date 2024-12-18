//
//  WorkoutDetailView.swift
//  Challenge3
//
//  Created by Stefano Nuzzo on 11/12/24.
//

import SwiftUI
import SDWebImageSwiftUI


struct WorkoutDetailView: View {
    @Binding var workout: Workout

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(workout.name)
                .font(.largeTitle)
                .padding(.bottom)

      
            List {
                ForEach(workout.exercises.indices, id: \.self) { index in
                    HStack{
                        if let url = URL(string: workout.exercises[index].gifUrl) {
                                AnimatedImage(url: url)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 80)
                            }
                        VStack(alignment: .leading) {
                            
                            Text(workout.exercises[index].name.capitalized)
                                .font(.headline)
                            Text("Body part: \(workout.exercises[index].bodyPart.capitalized)")
                                .font(.subheadline)
                        }
                    }
                }
            }

            Spacer()
        }
        .padding()
    }
}
