//
//  MovieResponseDTO.swift
//  MovieExplorer
//
//  Created by 김승희 on 11/24/25.
//

struct MovieResponseDTO: Decodable {
    let page: Int
    let totalResults: Int
    let totalPages: Int
    let movies: [MovieDTO]
    let status: String
    let timestamp: String
}
