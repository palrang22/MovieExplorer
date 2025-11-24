//
//  MovieUsecase.swift
//  MovieExplorer
//
//  Created by 김승희 on 11/24/25.
//

import RxSwift


protocol MovieUsecase {
    func fetchMovies() -> Single<[MovieEntity]>
}


final class MovieUsecaseImpl: MovieUsecase {
    
    private let repository: MovieRepository
    
    init(repository: MovieRepository) {
        self.repository = repository
    }
    
    func fetchMovies() -> Single<[MovieEntity]> {
        return repository.fetchData()
    }
}
