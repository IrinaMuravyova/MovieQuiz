//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Irina Muravyeva on 05.11.2025.
//
import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    
    func show(in vc: UIViewController, model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: model.buttonText,
            style: .default) {_ in
                model.completion()
            }
        
        action.accessibilityIdentifier = "RestartButton"
        alert.addAction(action)
        alert.view.accessibilityIdentifier = "Game Result"
        
        vc.present(alert, animated: true, completion: nil)
    }
}
