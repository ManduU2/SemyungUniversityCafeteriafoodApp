//
//  SceneDelegate.swift
//  WebCrawlingProject
//
//  Created by 김진혁 on 3/4/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        
        
        
        // add NavigationController
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        let mainViewController = ViewController()
        let navigationController = UINavigationController(rootViewController: mainViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
    }
    
    
    
    

    func sceneDidDisconnect(_ scene: UIScene) {
       
        
        
        
        
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
       
        
        
    }

    func sceneWillResignActive(_ scene: UIScene) {
        
        
        
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
       
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        
        
        
        
        
        
        
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

