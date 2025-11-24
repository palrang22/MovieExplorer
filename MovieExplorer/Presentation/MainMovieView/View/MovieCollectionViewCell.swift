//
//  MovieCollectionViewCell.swift
//  MovieExplorer
//
//  Created by 김승희 on 11/24/25.
//

import UIKit

import Kingfisher
import SnapKit
import Then


final class MovieCollectionViewCell: UICollectionViewCell {
    static let identifier = "MovieCollectionViewCell"
    
    //MARK: UI Components
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
    }
    
    private let posterImageView = UIImageView().then {
        $0.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = .black
        $0.numberOfLines = 2
    }
    
    private let dateLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 13, weight: .regular)
        $0.textColor = .darkGray
    }
    
    private let starIconView = UIImageView().then {
        $0.image = UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysTemplate)
        $0.tintColor = .darkGray
        $0.contentMode = .scaleAspectFit
    }
    
    private let scoreLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 15, weight: .medium)
        $0.textColor = .black
    }
    
    //MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: configure
    func configure(with viewModel: MainMovieItemViewModel) {
        titleLabel.text = viewModel.title
        dateLabel.text = viewModel.date
        scoreLabel.text = viewModel.score
        posterImageView.kf.setImage(with: URL(string: viewModel.imageURL))
    }
    
    //MARK: layout
    private func setLayout() {
        backgroundColor = .white
        
        contentView.addSubview(containerView)
        containerView.addSubview(posterImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(starIconView)
        containerView.addSubview(scoreLabel)
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8)
        }
        
        posterImageView.snp.makeConstraints {
            $0.left.top.bottom.equalToSuperview().inset(12)
            $0.width.equalTo(100)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(posterImageView.snp.top)
            $0.left.equalTo(posterImageView.snp.right).offset(12)
            $0.right.equalToSuperview().inset(12)
        }
        
        dateLabel.snp.makeConstraints {
            $0.left.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
        }
        
        starIconView.snp.makeConstraints {
            $0.left.equalTo(titleLabel)
            $0.top.equalTo(dateLabel.snp.bottom).offset(8)
            $0.width.height.equalTo(16)
        }
        
        scoreLabel.snp.makeConstraints {
            $0.left.equalTo(starIconView.snp.right).offset(6)
            $0.centerY.equalTo(starIconView.snp.centerY)
        }
    }
}
