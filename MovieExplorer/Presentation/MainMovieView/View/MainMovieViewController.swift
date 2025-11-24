//
//  MainMovieViewController.swift
//  MovieExplorer
//
//  Created by 김승희 on 11/24/25.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then


final class MainMovieViewController: UIViewController {
    
    //MARK: Properties
    private let viewModel: MainMovieViewModel
    private var sections: [MovieSection] = []
    
    private let disposeBag = DisposeBag()
    
    //MARK: UI Components
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 50)
        return layout
    }()

    private lazy var movieCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
        $0.backgroundColor = .clear
        $0.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        $0.register(
            MainMovieHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: MainMovieHeaderView.identifier
        )
    }
    
    //MARK: init
    init(viewModel: MainMovieViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegate()
        bind()
        setNavigationBar()
        setLayout()
    }
    
    //MARK: Methods
    private func setDelegate() {
        movieCollectionView.delegate = self
        movieCollectionView.dataSource = self
    }
    
    private func setNavigationBar() {
        title = "Movie Explorer"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
    }
    
    //MARK: Bindings
    private func bind() {
        
        let input = MainMovieViewModel.Input(
            loadTrigger: Observable.just(()),
            movieSelected: movieCollectionView.rx.itemSelected.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.sections
            .drive(onNext: { [weak self] sections in
                self?.sections = sections
                self?.movieCollectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        output.selectedMovie
            .drive(onNext: { movie in
            })
            .disposed(by: disposeBag)
        
        output.error
            .drive(onNext: { message in
                guard !message.isEmpty else { return }
                print("에러:", message)
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: Layout
    private func setLayout() {
        view.backgroundColor = .systemGray6
        [
            movieCollectionView
        ].forEach { view.addSubview($0) }
        
        movieCollectionView.snp.makeConstraints {
            $0.top.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
    }
    
}

//MARK: Extensions
extension MainMovieViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MovieCollectionViewCell.identifier,
            for: indexPath
        ) as? MovieCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let vm = sections[indexPath.section].items[indexPath.row]
        cell.configure(with: vm)
        return cell
    }
    
    
    // Header
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: MainMovieHeaderView.identifier,
            for: indexPath
        ) as! MainMovieHeaderView
        
        header.configure(title: sections[indexPath.section].title)
        return header
    }
}

extension MainMovieViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.bounds.width
        return CGSize(width: width, height: 180)
    }
}
