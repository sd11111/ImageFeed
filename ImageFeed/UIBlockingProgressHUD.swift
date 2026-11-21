import UIKit
import SwiftUI
import ProgressHUD

@MainActor
final class UIBlockingProgressHUD {
    private static var hudWindow: UIWindow?

    static func show() {
        guard hudWindow == nil else {
            return
        }

        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { scene in
                scene.windows.contains(where: { $0.isKeyWindow })
            })
        else {
            return
        }

        let controller = UIHostingController(
            rootView: ProgressHUDView()
        )
        controller.view.backgroundColor = .clear

        let window = UIWindow(windowScene: scene)
        window.frame = scene.coordinateSpace.bounds
        window.windowLevel = .alert
        window.backgroundColor = .clear
        window.rootViewController = controller

        hudWindow = window

        ProgressHUD.animate(interaction: false)
        window.isHidden = false
    }

    static func dismiss() {
        ProgressHUD.remove()

        hudWindow?.isHidden = true
        hudWindow?.rootViewController = nil
        hudWindow = nil
    }
}
