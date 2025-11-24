## 기술 스택

### Architecture
- Clean Architecture: Domain, Data, Presentation 레이어 명확한 분리
- MVVM Pattern: ViewModel 기반 단방향 데이터 플로우 구현
- Input-Output Pattern: ViewModel - View 간 명확한 인터페이스 정의

### Reactive Programming
- RxSwift: 반응형 프로그래밍 구현
- RxCocoa: UI 이벤트 바인딩 및 상태 관리

### UI Framework
- UIKit: 코드베이스 UI 구현 (Storyboard 미사용)
- SnapKit 5.7.1: AutoLayout을 위한 DSL 라이브러리
- Then 3.0.0: 가독성 높은 객체 초기화

### Image Handling
- Kingfisher 8.6.2: 비동기 이미지 로딩 및 캐싱



## 프로젝트 구조

```
MovieExplorer
├── App # 앱 진입점 및 Factory
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── AppFactory.swift    # 의존성 주입을 위한 Factory 패턴
│
├── Domain  # 비즈니스 로직 레이어
│   ├── Entity  # 도메인 모델
│   │   └── MovieEntity.swift
│   ├── Repository  # Repository 인터페이스
│   │   └── MovieRepository.swift
│   └── UseCase # 비즈니스 로직 구현
│       └── MovieUsecase.swift
│
├── Data    # 데이터 레이어
│   ├── DTO # 데이터 전송 객체
│   │   └── Movie
│   │       ├── MovieDTO.swift
│   │       └── MovieResponseDTO.swift
│   ├── RepositoryImpl  # Repository 구현체
│   │   └── MovieRepositoryImpl.swift
│   ├── Local   # 로컬 데이터 소스
│   │   └── JsonLoader.swift
│   └── Error   # 에러 정의
│       └── JsonLoadError.swift
│
├── Presentation    # UI 레이어
│   ├── MainMovieView
│   │   ├── View
│   │   │   ├── MainMovieViewController.swift
│   │   │   ├── MovieCollectionViewCell.swift
│   │   │   └── MainMovieHeaderView.swift
│   │   └── ViewModel
│   │       └── MainMovieViewModel.swift
│   └── DetailMovieView
│       ├── View
│       │   └── DetailMovieViewController.swift
│       └── ViewModel
│           └── DetailMovieViewModel.swift
│
└── Core    # 공통 유틸리티
    ├── Extension
    │   └── DateFormatter+Extension.swift
    └── Util
        └── DateParser.swift
```



## 주요 특징 및 기술적 어필 포인트

### 1. Clean Architecture 준수
- 레이어별 명확한 책임 분리: Domain, Data, Presentation 레이어 간 의존성 방향 엄격 준수
- Dependency Inversion: Repository를 Protocol로 정의하여 Domain 레이어가 Data 레이어에 의존하지 않도록 구현
- 테스트 용이성: 각 레이어가 독립적으로 테스트 가능한 구조

```swift
// Domain 레이어는 추상화된 인터페이스만 의존
protocol MovieRepository {
    func fetchData() -> Single<[MovieEntity]>
}

// Data 레이어에서 구체적인 구현 제공
final class MovieRepositoryImpl: MovieRepository {
    // Implementation
}
```

### 2. MVVM + Input/Output Pattern
- 명확한 데이터 흐름: Input과 Output 구조체로 ViewModel 인터페이스 명시화
- 단방향 데이터 플로우: View → ViewModel → View로의 일관된 데이터 흐름
- 테스트 용이성: Input/Output 구조를 통한 단위 테스트 작성 용이

```swift
struct Input {
    let loadTrigger: Observable<Void>
    let movieSelected: Observable<IndexPath>
}

struct Output {
    let sections: Driver<[MovieSection]>
    let selectedMovie: Driver<MovieEntity>
    let error: Driver<String>
}
```

### 3. RxSwift를 활용한 반응형 프로그래밍
- 스트림 기반 데이터 처리: flatMapLatest, map 등의 오퍼레이터를 활용한 데이터 변환
- 메모리 안전성: DisposeBag을 통한 메모리 누수 방지
- UI 업데이트 최적화: Driver를 사용한 메인 스레드 보장 및 중복 이벤트 방지

```swift
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
```

### 4. DTO to Entity Mapping
- 레이어 간 데이터 변환: DTO에서 Domain Entity로의 명확한 변환 로직
- 날짜 파싱 처리: 문자열 형태의 날짜를 Date 타입으로 안전하게 변환
- Optional 처리: nil 안전성을 고려한 데이터 매핑

```swift
extension MovieDTO {
    func mapping() -> MovieEntity {
        return MovieEntity(
            id: id,
            title: title,
            date: DateParser.parse(stringDate: releaseDate),
            overview: overview,
            posterPath: posterPath,
            rate: popularity,
            genre: genre
        )
    }
}
```

### 5. 의존성 주입 (Dependency Injection)
- Factory Pattern: AppFactory를 통한 객체 생성 및 의존성 주입
- 느슨한 결합: 프로토콜 기반의 의존성으로 테스트 및 유지보수 용이
- 생성자 주입: init을 통한 명시적인 의존성 전달

```swift
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
```

### 6. 코드 기반 UI 구현
- Storyboard 미사용: 코드 기반의 유연한 UI 구성
- SnapKit을 활용한 AutoLayout: 가독성 높은 제약조건 설정
- Then 라이브러리: 객체 초기화 코드의 가독성 향상

```swift
private let titleLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 20, weight: .semibold)
    $0.textColor = .black
    $0.numberOfLines = 2
}
```

### 7. 커스텀 Extension 활용
- DateFormatter Extension: 날짜 포맷팅을 위한 재사용 가능한 확장
- 코드 재사용성: 중복 코드 제거 및 일관된 날짜 형식 유지
- Then 라이브러리 활용: 불변 객체 설정의 간결한 표현

```swift
extension DateFormatter {
    static let dateDividedByDot = DateFormatter().then {
        $0.dateFormat = "yyyy.MM.dd"
    }
    
    static let dateSection = DateFormatter().then {
        $0.locale = Locale(identifier: "en_US")
        $0.dateFormat = "MMMM yyyy"
    }
}
