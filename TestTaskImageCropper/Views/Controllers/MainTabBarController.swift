import UIKit

final class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTabBarController()
        setUpTabBar()
    }
    
    private func setUpTabBar() {
        tabBar.backgroundColor = .white
        tabBar.unselectedItemTintColor = .lightGray
    }
    
    private func setUpTabBarController() {
        let menuBar = self.createNavigation(with: "Menu", and: UIImage(systemName: "scribble.variable"), vc: ImageCropperViewController())
        let settingsBar = self.createNavigation(with: "Settings", and: UIImage(systemName: "scribble.variable"), vc: TableViewSettingsViewController())
        
        self.setViewControllers([menuBar, settingsBar], animated: true)
    }
    
    private func createNavigation(with title: String, and image: UIImage?, vc: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: vc)
        nav.tabBarItem.title = title
        nav.tabBarItem.image = image
        return nav
    }
}
