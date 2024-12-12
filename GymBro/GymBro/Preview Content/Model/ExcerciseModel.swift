//
//  ExcerciseModel.swift
//  Challenge3
//
//  Created by Stefano Nuzzo on 10/12/24.
//

import Foundation
import SwiftData

struct Exercise: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var bodyPart: String
    var equipment: String
    var target: String
    var gifUrl: String
    var secondaryMuscles: [String]
    var instructions: [String]
}

