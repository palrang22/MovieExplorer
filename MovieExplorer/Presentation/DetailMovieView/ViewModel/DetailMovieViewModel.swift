//
//  DetailMovieViewModel.swift
//  MovieExplorer
//
//  Created by 김승희 on 11/24/25.
//

import UIKit

import RxCocoa
import RxSwift


final class DetailMovieViewModel {
    
    //MARK: Input-Output 패턴 사용
    struct Input {
        let closeTrigger: Observable<Void>
    }
    
    struct Output {
        let movie: Driver<DetailMovieItemViewModel>
        let close: Driver<Void>
    }
    
    
    // MARK: Properties
    private let movieEntity: MovieEntity
    private let disposeBag = DisposeBag()
    
    
    // MARK: init
    init(movieEntity: MovieEntity) {
        self.movieEntity = movieEntity
    }
    
    
    // MARK: Transform
    func transform(input: Input) -> Output {
        
        let movieVM = DetailMovieItemViewModel(entity: movieEntity)
        let movieOutput = Observable.just(movieVM)
            .asDriver(onErrorJustReturn: DetailMovieItemViewModel(entity: movieEntity))
        let closeOutput = input.closeTrigger
            .asDriver(onErrorDriveWith: .empty())
        
        return Output(
            movie: movieOutput,
            close: closeOutput
        )
    }
}


//MARK: DetailMovieItemViewModel

struct DetailMovieItemViewModel {
    let imageURL: String
    let title: String
    let date: String
    let genres: String
    let score: String
    let overview: String
    
    init(entity: MovieEntity) {
        self.imageURL = entity.posterPath
        self.title = entity.title
        
        if let date = entity.date {
            self.date = DateFormatter.dateDividedByDash.string(from: date)
        } else {
            self.date = "-"
        }
        
        if entity.genre.isEmpty {
            self.genres = "-"
        } else {
            self.genres = entity.genre.joined(separator: " / ")
        }
        
        if let rate = entity.rate {
            let convertedToScore = rate * 10
            self.score = String(format: "%.1f", convertedToScore)
        } else {
            self.score = "-"
        }
        
        self.overview = entity.overview.isEmpty ? "-" : entity.overview
    }
}
