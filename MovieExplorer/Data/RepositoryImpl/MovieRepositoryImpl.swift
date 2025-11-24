//
//  MovieRepositoryImpl.swift
//  MovieExplorer
//
//  Created by 김승희 on 11/24/25.
//

import RxSwift


final class MovieRepositoryImpl: MovieRepository {
    private let jsonLoader: JsonLoader
    
    init(jsonLoader: JsonLoader) {
        self.jsonLoader = jsonLoader
    }
    
    func fetchData() -> Single<[MovieEntity]> {
        return jsonLoader.load(fileName: "MovieList")
            .map { (response: MovieResponseDTO ) in
                response.movies.map { $0.mapping() }
            }
    }
}
