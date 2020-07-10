//
//  ToastViewController.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 10/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showToast(text: String) {
        
        let toast = UIView()
        toast.translatesAutoresizingMaskIntoConstraints = false
        toast.layer.cornerRadius = 10
        toast.backgroundColor = UIColor(rgb: 0x4E4E4E)
        
        let toastLabel = UILabel()
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.text = text
        toastLabel.textColor = .white
        toastLabel.font = .systemFont(ofSize: 14)
        toastLabel.numberOfLines = 0
        
        toast.addSubview(toastLabel)
        view.addSubview(toast)
        
        toastLabel.leadingAnchor.constraint(equalTo: toast.leadingAnchor, constant: 16).isActive = true
        toastLabel.trailingAnchor.constraint(equalTo: toast.trailingAnchor, constant: -16).isActive = true
        toastLabel.topAnchor.constraint(equalTo: toast.topAnchor, constant: 10).isActive = true
        toastLabel.bottomAnchor.constraint(equalTo: toast.bottomAnchor, constant: -10).isActive = true
        
        toast.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24).isActive = true
        toast.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24).isActive = true
        toast.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60).isActive = true
        
        toast.alpha = 0
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            toast.alpha = 1
        }, completion: { _ in
            Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { [weak self] _ in
                self?.hideToast(toast)
            }
        })
    }
    
    func hideToast(_ toast: UIView) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            toast.alpha = 0
        }, completion: { _ in
            toast.removeFromSuperview()
        })
    }
    
}
