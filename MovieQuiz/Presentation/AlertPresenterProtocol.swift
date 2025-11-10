//
//  AlertPresenterProtocol.swift
//  MovieQuiz
//
//  Created by Irina Muravyeva on 05.11.2025.
//
import UIKit

protocol AlertPresenterProtocol: AnyObject {
    func show(in vc: UIViewController, model: AlertModel)
}
