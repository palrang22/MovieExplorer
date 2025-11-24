//
//  AppFactory.swift
//  MovieExplorer
//
//  Created by 김승희 on 11/24/25.
//

import UIKit


final class AppFactory {
    func makeMainMovieFlow() -> UIViewController {
        let jsonLoader = JsonLoader()
        let repository = MovieRepositoryImpl(jsonLoader: jsonLoader)
        let usecase = MovieUsecaseImpl(repository: repository)
        let viewModel = MainMovieViewModel(movieUsecase: usecase)
        let viewController = MainMovieViewController(viewModel: viewModel)
        return UINavigationController(rootViewController: viewController)
    }
}
