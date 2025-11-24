//
//  MovieDTO.swift
//  MovieExplorer
//
//  Created by 김승희 on 11/24/25.
//

import Foundation


struct MovieDTO: Decodable {
    let id: Int
    let title: String
    let releaseDate: String
    let overview: String
    let posterPath: String
    let popularity: Double?
    let genre: [String]
}

extension MovieDTO {
    func mapping() -> MovieEntity {
        return MovieEntity(
            id: id,
            title: title,
            date: DateParser.parse(stringDate: releaseDate),
            overview: overview,
            posterPath: posterPath,
            rate: popularity,
            genre: genre
        )
    }
}
