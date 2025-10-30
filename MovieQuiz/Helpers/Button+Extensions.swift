//
//  Button+Extensions.swift
//  MovieQuiz
//
//  Created by Irina Muravyeva on 29.10.2025.
//

import UIKit

class HighlightButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? .systemGray : .white
        }
    }
}
