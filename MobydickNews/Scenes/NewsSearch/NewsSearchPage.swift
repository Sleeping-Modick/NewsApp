import RxSwift
import SnapKit
import UIKit

final class NewsSearchPage: UIViewController {
    private let viewModel = NewsSearchViewModel()
    private let disposeBag = DisposeBag()
    // 검색 바
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.backgroundImage = UIImage() // Search바 기본구성인 두가지의 선을 지우는 ㄱ
        searchBar.placeholder = "검색할 단어를 입력해주세요"
        return searchBar
    }()
    
    // 검색 결과를 보여줄 테이블 뷰
    private lazy var searchTableView: UITableView = {
        let tableView = UITableView()
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchTableView.dataSource = self
        searchTableView.delegate = self
        // Cell 등록
        searchTableView.register(TableViewCell.self, forCellReuseIdentifier: "cell")
        viewModel.getAllHeadLineNews()
        setupUI()
        bindViewModel()
        
        //키보드 내려가게하기
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(navigationBarTapped))
        navigationController?.navigationBar.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func navigationBarTapped() {
        // 키보드 내리기
        view.endEditing(true)
    }

    func bindViewModel() {
        viewModel.newsListSubject.bind { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.searchTableView.reloadData()
            }
        }.disposed(by: disposeBag)
    }
    
    // UI 요소를 설정하는 메서드
    func setupUI() {
        view.addSubview(searchBar)
        view.addSubview(searchTableView)
           
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(CGFloat.defaultPadding)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
           
        searchTableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(CGFloat.defaultPadding)
            make.leading.trailing.bottom.equalToSuperview()
            // 탭 바 상단에 맞추어주는 코드
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}

extension NewsSearchPage: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let query = searchBar.text {
            viewModel.getSearchNewsData(searchTitle: query)
        }
        searchBar.resignFirstResponder() // 엔터를 치면 키보드 사라짐
    }
}

extension NewsSearchPage: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let articles = viewModel.filteredArticle() else { return 0 }
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        
        guard let articles = viewModel.filteredArticle() else { return UITableViewCell() }
        let temp = articles[indexPath.row]
        cell.configure(title: temp.title, description: temp.description, date: temp.publishedAt, imageString: temp.urlToImage)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailPageVC = NewsDetailPage()
        guard let article = viewModel.newsList?.articles?[indexPath.row] else { return }
        detailPageVC.bind(article: article)
        navigationController?.pushViewController(detailPageVC, animated: true)
    }
}
