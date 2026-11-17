//
//  UIViewController+Ext.swift
//  Origenes Bordados
//
//  Created by Facultad de Contaduría y Administración on 29/10/26.
//
import UIKit

extension UIViewController{
    // El loader vive en el navigationController (si existe) para cubrir toda la pantalla
    private var loaderHost: UIViewController {
        navigationController ?? self
    }
    
    private var loaderChild: LoaderViewController? {
        loaderHost.children.first { $0 is LoaderViewController } as? LoaderViewController
    }
    
    func showLoader(){
        guard loaderChild == nil else { return }
        
        let host = loaderHost
        let loader = LoaderViewController(nibName: "LoaderViewController", bundle: nil)
        
        host.addChild(loader)
        loader.view.frame = host.view.bounds
        loader.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        loader.view.alpha = 0
        host.view.addSubview(loader.view)
        loader.didMove(toParent: host)
        
        UIView.animate(withDuration: 0.2) {
            loader.view.alpha = 1
        }
    }
    
    func hideLoader(){
        guard let loader = loaderChild else { return }
        
        loader.willMove(toParent: nil)
        UIView.animate(withDuration: 0.2, animations: {
            loader.view.alpha = 0
        }, completion: { _ in
            loader.view.removeFromSuperview()
            loader.removeFromParent()
        })
    }
}
