//
//  ViewController.swift
//  TinkoffCalculator
//
//  Created by R Kolos on 22.01.2025.
//

import UIKit

enum CalculationError: Error {
    case dividedByZero
}

enum Operation: String {
    case add = "+"
    case substract = "-"
    case multiply = "x"
    case divide = "/"

    func calculate(_ number1: Double, _ number2:Double) throws -> Double {
        switch self {
            case .add:
                return number1 + number2
            case .substract:
                return number1 - number2
            case .multiply:
                return number1 * number2
            case .divide:
                if number2 == 0 {
                    throw CalculationError.dividedByZero
                }
                return number1 / number2
        }
    }
}

enum CalculationHistoryItem {
    case number(Double)
    case operation(Operation)
}

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet var historyButton: UIButton!

    var generalResult: String?
    var calculationHistory: [CalculationHistoryItem] = []
    var calculations: [Calculation] = []
    let calculationHistorySorage = CalculationHisoryStorage()

    lazy var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()

        numberFormatter.usesGroupingSeparator = false
        numberFormatter.locale = Locale(identifier: "ru_RU")
        numberFormatter.numberStyle = .decimal

        return numberFormatter
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
            // Do any additional setup after loading the view.

        resetLabelText()
        historyButton.accessibilityIdentifier = "historyButton"
        calculations = calculationHistorySorage.loadHistory()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }



    @IBAction func showCalculationsList(_ sender: Any) {

        let sb = UIStoryboard(name: "Main", bundle: nil)
        let calculationsListVC = sb.instantiateViewController(identifier: "CalculationsListViewController")

        if let vc = calculationsListVC as? CalculationsListViewController {
            vc.calculations = calculations
        }

        navigationController?.pushViewController(calculationsListVC, animated: true)
    }
    

    @IBAction func buttonPressed(_ sender: UIButton) {

        guard let buttonText = sender.titleLabel?.text else { return }

        if buttonText == "," && label.text?.contains(",") == true {
            return
        }

        if label.text == "0" {
            label.text = buttonText
        } else {
            label.text?.append(buttonText)
        }
    }


    @IBAction func clearButtonPressed() {
        calculationHistory.removeAll()
        resetLabelText()
    }


    @IBAction func calculateButtonPressed() {
        guard
            let labelText = label.text,
            let labelNumber = numberFormatter.number(
                from: labelText
            )?.doubleValue
        else { return }

        calculationHistory.append(.number(labelNumber))

        do {
            let result = try calculate()
            label.text = numberFormatter.string(from: NSNumber(value: result))
            generalResult = labelText
            let newCalculations = Calculation(
                expression: calculationHistory,
                result: result)
            calculations.append(newCalculations)
            calculationHistorySorage.setHistory(calculation: calculations)
        } catch {
            label.text = "Ошибка"
        }

        calculationHistory.removeAll()
    }


//    @IBAction func unwindAction(unwindSegue: UIStoryboardSegue) {
//
//    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard segue.identifier == "CALCULATIONS_LIST",
//                let calculatiosListVC = segue.destination as? CalculationsListViewController else {
//            return
//        }
//        calculatiosListVC.calculations = calculations
//    }


    @IBAction func operationButtonPressed(_ sender: UIButton) {

        guard
            let buttonText = sender.titleLabel?.text,
            let buttonOperation = Operation(rawValue: buttonText)
        else { return }

        guard
            let labelText = label.text,
            let labelNumber = numberFormatter.number(from: labelText)?.doubleValue
        else { return }

        calculationHistory.append(.number(labelNumber))
        calculationHistory.append(.operation(buttonOperation))

        resetLabelText()
    }


    func calculate() throws -> Double {
        guard case .number(let firstNumber) = calculationHistory[0] else {
            return 0
         }

        var currectResult = firstNumber

        for index in stride(from: 1, to: calculationHistory.count - 1, by: 2) {
            guard
                case .operation(let operation) = calculationHistory[index],
                case .number(let number) = calculationHistory[index + 1]
            else { break }

            currectResult = try operation.calculate(currectResult, number)
        }

        return currectResult
    }

    func resetLabelText() {
        label.text = "0"
        generalResult = nil
    }

}

