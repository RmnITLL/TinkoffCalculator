//
//  CalculationsListViewController.swift
//  TinkoffCalculator
//
//  Created by R Kolos on 03.05.2024.
//

import UIKit

class CalculationsListViewController: UIViewController {
    
    var result: String?
    
    @IBOutlet weak var calculationLabel: UILabel!
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        modalPresentationStyle = .fullScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calculationLabel.text = result
    }
}
