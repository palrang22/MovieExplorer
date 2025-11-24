//
//  MovieEntity.swift
//  MovieExplorer
//
//  Created by 김승희 on 11/24/25.
//

import Foundation


struct MovieEntity {
    let id: Int
    let title: String
    let date: Date?
    let overview: String
    let posterPath: String
    let rate: Double?
    let genre: [String]
}
