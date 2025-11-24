//
//  DetailMovieView.swift
//  MovieExplorer
//
//  Created by 김승희 on 11/24/25.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then


final class DetailMovieViewController: UIViewController {
    
    //MARK: Properties
    private let viewModel: DetailMovieViewModel
    private let disposeBag = DisposeBag()
    
    //MARK: UI Components
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
    }
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 22, weight: .bold)
        $0.textColor = .black
        $0.numberOfLines = 2
    }
    
    private let dateLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = .black
    }
    
    private let genreLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = .darkGray
    }
    
    private let starIconView = UIImageView().then {
        $0.image = UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysTemplate)
        $0.tintColor = .lightGray
        $0.contentMode = .scaleAspectFit
    }
    
    private let scoreLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .black
    }
    
    private let overviewLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18, weight: .regular)
        $0.textColor = .darkGray
        $0.numberOfLines = 0
    }
    
    private lazy var closeButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemGray4
        config.baseForegroundColor = .black
        config.cornerStyle = .medium
        config.title = "뒤로가기"
        $0.configuration = config
    }
    
    //MARK: init
    init(viewModel: DetailMovieViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setLayout()
        setNavigationBar()
    }
    
    //MARK: Methods
    private func setNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = "상세보기"

        let backAction = UIAction { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }

        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            primaryAction: backAction
        )
        backButton.tintColor = .systemGray

        navigationItem.leftBarButtonItem = backButton
    }
    
    //MARK: Bindings
    private func bind() {
        let input = DetailMovieViewModel.Input(
            closeTrigger: closeButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.movie
            .drive(onNext: { [weak self] vm in
                guard let self else { return }
                self.titleLabel.text = vm.title
                self.dateLabel.text = vm.date
                self.genreLabel.text = vm.genres
                self.scoreLabel.text = vm.score
                self.overviewLabel.text = vm.overview
                self.imageView.kf.setImage(with: URL(string: vm.imageURL))
            })
            .disposed(by: disposeBag)
        
        output.close
            .drive(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: Layout
    private func setLayout() {
        view.backgroundColor = .systemGray6
        
        [
            imageView,
            containerView
        ].forEach { view.addSubview($0) }
        
        [
            scrollView,
            closeButton
        ].forEach { containerView.addSubview($0) }
        
        scrollView.addSubview(contentView)
        
        [
            titleLabel,
            dateLabel,
            genreLabel,
            starIconView,
            scoreLabel,
            overviewLabel
        ].forEach { contentView.addSubview($0) }
        
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
            $0.height.equalTo(300)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(12)
            $0.leading.trailing.equalTo(imageView)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(closeButton.snp.top).offset(-12)
        }
        
        closeButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview().offset(-20)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(20)
        }
        
        dateLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        genreLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(titleLabel)
        }
        
        starIconView.snp.makeConstraints {
            $0.top.equalTo(genreLabel.snp.bottom).offset(8)
            $0.leading.equalTo(titleLabel)
            $0.width.height.equalTo(16)
        }
        
        scoreLabel.snp.makeConstraints {
            $0.leading.equalTo(starIconView.snp.trailing).offset(6)
            $0.centerY.equalTo(starIconView)
        }
        
        overviewLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(titleLabel)
            $0.top.equalTo(scoreLabel.snp.bottom).offset(8)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }

}
