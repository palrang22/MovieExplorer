//
//  MainMovieViewModel.swift
//  MovieExplorer
//
//  Created by 김승희 on 11/24/25.
//

import UIKit

import RxCocoa
import RxSwift


final class MainMovieViewModel {
    
    //MARK: Input-Output 패턴 사용
    struct Input {
        let loadTrigger: Observable<Void>
        let movieSelected: Observable<IndexPath>
    }
    
    struct Output {
        let sections: Driver<[MovieSection]>
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
        let sectionsRelay = BehaviorRelay<[MovieSection]>(value: [])
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
        
        // 월별 섹션 생성
        let sections = moviesRelay
            .map { movies -> [MovieSection] in
                // 월별 섹션 생성을 위해 날짜값이 있는 데이터만 남겼습니다.
                let validMovies = movies.compactMap { movie in
                    movie.date != nil ? movie : nil
                }
                
                let sortedMovies = validMovies.sorted {
                    $0.date! > $1.date!
                }
                
                let grouped = Dictionary(grouping: sortedMovies) { movie in
                    DateFormatter.dateSection.string(from: movie.date!)
                }
                
                let orderedKeys: [String] = sortedMovies.reduce(into: []) { arr, movie in
                    let key = DateFormatter.dateSection.string(from: movie.date!)
                    if !arr.contains(key) {
                        arr.append(key)
                    }
                }
                
                return orderedKeys.map { key in
                    let entities = grouped[key]!
                    let items = entities.map(MainMovieItemViewModel.init)
                    return MovieSection(title: key, items: items, entities: entities)
                }
            }
            .do(onNext: { sections in
                sectionsRelay.accept(sections)
            })
            .asDriver(onErrorJustReturn: [])
        
        
        // 영화 선택 -> MovieEntity 전달
        let selectedMovie = input.movieSelected
            .withLatestFrom(sectionsRelay.asObservable()) { indexPath, sections in
                sections[indexPath.section].entities[indexPath.row]
            }
            .asDriver(onErrorDriveWith: .empty())
        
        return Output(
            sections: sections,
            selectedMovie: selectedMovie,
            error: errorRelay.asDriver(onErrorJustReturn: "")
        )
    }
}


//MARK: MainMovieItemViewModel, MovieSection


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

struct MovieSection {
    let title: String
    let items: [MainMovieItemViewModel]
    let entities: [MovieEntity]
}
