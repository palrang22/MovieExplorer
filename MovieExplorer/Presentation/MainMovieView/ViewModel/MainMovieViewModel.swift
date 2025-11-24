//
//  MainMovieViewModel.swift
//  MovieExplorer
//
//  Created by 김승희 on 11/24/25.
//

import UIKit

import RxCocoa
import RxSwift


struct MainMovieItemViewModel {
    let imageURL: String
    let title: String
    let date: String
    let score: String
    
    init(entity: MovieEntity) {
        self.imageURL = entity.posterPath
        self.title = entity.title
        
        if let date = entity.date {
            self.date = DateFormatter.dateDividedByDot.string(from: date)
        } else {
            self.date = "-"
        }
        
        if let rate = entity.rate {
            let convertedToScore = rate * 10
            self.score = String(format: "%.1f", convertedToScore)
        } else {
            self.score = "-"
        }
    }
}


final class MainMovieViewModel {
    
    //MARK: Input-Output 패턴 사용
    struct Input {
        let loadTrigger: Observable<Void>
        let movieSelected: Observable<IndexPath>
    }
    
    struct Output {
        let movies: Driver<[MainMovieItemViewModel]>
        let selectedMovie: Driver<MovieEntity>
        let error: Driver<String>
    }
    
    //MARK: Properties
    private let movieUsecase: MovieUsecase
    private let disposeBag = DisposeBag()
    
    //MARK: init
    init(movieUsecase: MovieUsecase) {
        self.movieUsecase = movieUsecase
    }
    
    //MARK: transform
    func transform(input: Input) -> Output {
        
        let moviesRelay = BehaviorRelay<[MovieEntity]>(value: [])
        let selectedMovieRelay = PublishRelay<MovieEntity>()
        let errorRelay = PublishRelay<String>()
        
        // 최초 로딩: Usecase 실행
        input.loadTrigger
            .flatMapLatest { [weak self] _ -> Single<[MovieEntity]> in
                guard let self else { return .just([]) }
                return self.movieUsecase.fetchMovies()
                    .catch { error in
                        errorRelay.accept(error.localizedDescription)
                        return .just([])
                    }
            }
            .bind(to: moviesRelay)
            .disposed(by: disposeBag)
        
        // 최신순 정렬
        let sortedMovies = moviesRelay
            .map { (movies: [MovieEntity]) -> [MainMovieItemViewModel] in
                let sorted = movies.sorted {
                    guard let left = $0.date, let right = $1.date else {
                        return $0.date != nil
                    }
                    return left > right
                }
                return sorted.map(MainMovieItemViewModel.init)
            }
            .asDriver(onErrorJustReturn: [])
        
        // 영화 선택 -> MovieEntity 전달
        let selectedMovie = input.movieSelected
            .withLatestFrom(moviesRelay) { indexPath, movie in
                movie[indexPath.row]
            }
            .asDriver(onErrorDriveWith: .empty())
        
        return Output(
            movies: sortedMovies,
            selectedMovie: selectedMovie,
            error: errorRelay.asDriver(onErrorJustReturn: "")
        )
    }
    
    //MARK: Methods
}
