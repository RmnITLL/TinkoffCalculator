    //
    //  AlertView.swift
    //  TinkoffCalculator
    //
    //  Created by R Kolos on 27.01.2025.
    //

import UIKit

class AlertView: UIView {

    var alertText: String? {
        didSet {
            label.text = alertText
        }
    }

    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        addSubview(label)
        backgroundColor = .orange
        layer.cornerRadius = 25
        layer.masksToBounds = true

        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(hide))
        addGestureRecognizer(tap)
    }

    @objc
    private func hide() {
        removeFromSuperview()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
}
