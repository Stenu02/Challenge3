//
//  WorkoutModel.swift
//  Challenge3
//
//  Created by Stefano Nuzzo on 10/12/24.
//


import Foundation


struct Workout: Codable,Identifiable, Hashable{
    var id = UUID().uuidString
    var name: String
    var exercises: [Exercise]
}
