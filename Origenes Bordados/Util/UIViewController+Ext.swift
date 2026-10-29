//
//  UIViewController+Ext.swift
//  Origenes Bordados
//
//  Created by Facultad de Contaduría y Administracíon on 29/10/26.
//

import UIKit

//Si encuentro el LoaderViewController
extension UIViewController{
    private var loaderChild: LoaderViewController? {
        children.first{ $0 is LoaderViewController } as?
        LoaderViewController
    }
    
    func showLoader() {
        guard loaderChild == nil else { return }
        let loader = LoaderViewController(nibName: "LoaderViewController", bundle: nil)
        
        addChild(loader)
        loader.view.frame = view.bounds
        loader.view.autoresizingMask = [.flexibleWidth, .flexibleHeight] //Si giramos la pantalla
        loader.view.alpha = 0 //Para ver lo que hay detrás de loader
        view.addSubview(loader.view) //A quien llame la función se le va a agregar la subvista de loader
        loader.didMove(toParent: self)//didMove ejecuta el ciclo de vida del loader, que está lista para instanciarse
        UIView.animate(withDuration: 0.2) {//Se crea la animación con duración
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
