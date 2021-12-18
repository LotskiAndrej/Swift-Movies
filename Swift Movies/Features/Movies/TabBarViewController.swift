import UIKit

class TabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        tabBar.backgroundColor = .white
        tabBar.tintColor = .black
        
        let divider = UIView()
        divider.backgroundColor = .systemGray
        
        tabBar.addSubview(divider)
        divider.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.top.leading.trailing.equalToSuperview()
        }
        
        addTabBarItems()
    }
    
    private func addTabBarItems() {
        let tabOne = UINavigationController(rootViewController: MovieListViewController())
        let tabOneBarItem = UITabBarItem(title: "Movies",
                                         image: UIImage(systemName: "film"),
                                         selectedImage: UIImage(systemName: "film.fill"))
        tabOne.tabBarItem = tabOneBarItem
        
        
        let tabTwo = UINavigationController(rootViewController: FavoritesListViewController())
        let tabTwoBarItem = UITabBarItem(title: "Favorites",
                                         image: UIImage(systemName: "heart"),
                                         selectedImage: UIImage(systemName: "heart.fill"))
        tabTwo.tabBarItem = tabTwoBarItem
        
        viewControllers = [tabOne, tabTwo]
    }
}
