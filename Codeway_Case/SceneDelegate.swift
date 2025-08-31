import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { 
            print("SceneDelegate: HATA - WindowScene bulunamadı!")
            return 
        }
        
        print("=== SCENE DELEGATE BAŞLADI ===")
        print("SceneDelegate: WindowScene bulundu: \(windowScene)")
        
        // Window oluştur
        let window = UIWindow(windowScene: windowScene)
        window.backgroundColor = .systemBackground
        print("SceneDelegate: Window oluşturuldu")
        
        // HomeViewController'ı root olarak ayarla
        let homeViewController = HomeViewController()
        let navigationController = UINavigationController(rootViewController: homeViewController)
        
        window.rootViewController = navigationController
        print("SceneDelegate: HomeViewController root olarak ayarlandı")
        
        // Window'u görünür yap
        window.makeKeyAndVisible()
        print("SceneDelegate: Window görünür yapıldı")
        
        // Window referansını sakla
        self.window = window
        
        // Window'u kontrol et
        print("SceneDelegate: Window kontrolü:")
        print("  - Window: \(window)")
        print("  - Frame: \(window.frame)")
        print("  - isKeyWindow: \(window.isKeyWindow)")
        print("  - backgroundColor: \(window.backgroundColor?.description ?? "nil")")
        
        // Tüm window'ları listele
        print("SceneDelegate: Tüm window'lar:")
        for (index, win) in UIApplication.shared.windows.enumerated() {
            print("  Window \(index): \(win)")
            print("    - isKeyWindow: \(win.isKeyWindow)")
            print("    - backgroundColor: \(win.backgroundColor?.description ?? "nil")")
        }
        
        print("=== SCENE DELEGATE TAMAMLANDI ===")
    }
}
