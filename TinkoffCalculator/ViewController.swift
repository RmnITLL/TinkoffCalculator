    //
    //  ViewController.swift
    //  TinkoffCalculator
    //
    //  Created by Chingiz on 27.01.2024.
    //

import UIKit

protocol LongPressViewProtocol {
    var shared: UIView { get }

    func startAnimation()
    func stopAnimation()
}

enum CalculationError: Error {
    case dividedByZero
}

enum Operation: String {
    case add = "+"
    case subtract = "-"
    case multiply = "x"
    case divide = "/"

    func calculate(_ number1: Double, _ number2: Double) throws -> Double {
        switch self {
            case .add:
                return number1 + number2
            case .subtract:
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

final class ViewController: UIViewController {

        // MARK: - IBOutlet

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var historyButton: UIButton!

        // MARK: - Private Properties

    private var calculationHistory: [CalculationHistoryItem] = []
    private var calculations: [Calculation] = []
    private let calculationHistoryStorage = CalculationHistoryStorage()
    private var noCalculate = "NoData"
    private var piValue: Double = 0.0

    private let alertView: AlertView = {
        let screenBounds = UIScreen.main.bounds
        let alertHight: CGFloat = 100
        let alertWidth: CGFloat = screenBounds.width - 40
        let x: CGFloat = screenBounds.width / 2 - alertWidth / 2
        let y: CGFloat = screenBounds.height / 2 - alertHight / 2
        let alertFrame = CGRect(x: x, y: y, width: alertWidth, height: alertHight)
        let alertView = AlertView(frame: alertFrame)
        return alertView
    }()

    lazy var shared: UIView = {
        let screenBounds = UIScreen.main.bounds
        let sharedHeight: CGFloat = screenBounds.height - 40
        let sharedWidth: CGFloat = screenBounds.width - 40
        let x: CGFloat = screenBounds.width / 2 - sharedWidth / 2
        let y: CGFloat = screenBounds.height / 2 - sharedHeight / 2
        let sharedFrame = CGRect(x: x, y: y, width: sharedWidth, height: sharedHeight)
        let sharedView = UIView(frame: sharedFrame)
        sharedView.backgroundColor = .orange
        sharedView.layer.cornerRadius = 30
        sharedView.clipsToBounds = true
        return sharedView
    }()

    private lazy var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.usesGroupingSeparator = false
        numberFormatter.locale = Locale(identifier: "ru_RU")
        numberFormatter.numberStyle = .decimal
        let screenWidth = UIScreen.main.bounds.width
        if screenWidth < 400 {
            numberFormatter.maximumFractionDigits = 8
        } else {
            numberFormatter.maximumFractionDigits = 15
        }
        return numberFormatter
    }()

        // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        resetLabelText()
        historyButton.accessibilityIdentifier = "historyButton"
        calculations = calculationHistoryStorage.loadHistory()
        view.addSubview(alertView)
        alertView.alpha = 0
        alertView.alertText = "Вы нашли пасхалку!"

        view.subviews.forEach {
            if type(of: $0) == UIButton.self {
                $0.layer.cornerRadius = 45
            }
        }

        view.addSubview(shared)
        shared.alpha = 0
        let tap = UILongPressGestureRecognizer()
        tap.addTarget(self, action: #selector(longPressGesture(_:)))
        view.addGestureRecognizer(tap)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

        // MARK: - IBAction

    @IBAction func buttonPressed(_ sender: UIButton) {
        guard let buttonText = sender.currentTitle else { return }

        if label.text == "Ошибка" {
            resetLabelText()
        }

        if buttonText == "," {
            if label.text == "0" {
                label.text = "0,"
            } else if !label.text!.contains(",") {
                label.text?.append(buttonText)
            }
        } else {
            if label.text == "0" {
                label.text = buttonText
            } else {
                label.text?.append(buttonText)
            }
        }

        if label.text == "3,141592" {
            animateAlert()
        }

        sender.animateTap()
    }

    @IBAction func operationButtonPressed(_ sender: UIButton) {
        guard
            let buttonText = sender.currentTitle,
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

    @IBAction func clearButtonPressed(_ sender: UIButton) {
        calculationHistory.removeAll()
        resetLabelText()
    }

    @IBAction func calculateButtonPressed(_ sender: UIButton) {
        guard
            let labelText = label.text,
            let labelNumber = numberFormatter.number(from: labelText)?.doubleValue
        else { return }

        calculationHistory.append(.number(labelNumber))
        do {
            let result = try calculate()
            label.text = numberFormatter.string(from: NSNumber(value: result))
            let newCalculation = Calculation(
                expression: calculationHistory,
                result: result,
                date: Date()
            )
            calculations.append(newCalculation)
            calculationHistoryStorage.setHistory(calculation: calculations)
        } catch {
            label.text = "Ошибка"
            label.shake()
        }
        noCalculate = label.text ?? "NoData"
        if calculationHistory.count == 1 {
            noCalculate = "NoData"
        }
        calculationHistory.removeAll()
    }

    @IBAction func showCalculationsList(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let calculationsListVC = sb.instantiateViewController(identifier: "CalculationsListViewController")
        if let vc = calculationsListVC as? CalculationsListViewController {
            vc.calculations = calculations
        }
        navigationController?.pushViewController(calculationsListVC, animated: true)
    }

    @IBAction func piButtonPressed(_ sender: UIButton) {
        calculatePiWithPrecision(10000000) { pi in
            DispatchQueue.main.async {
                self.label.text = self.numberFormatter.string(from: NSNumber(value: pi))
            }
        }
    }

        // MARK: - Private Methods

    private func calculate() throws -> Double {
        guard case .number(let firstNumber) = calculationHistory[0] else { return 0 }
        var currentResult = firstNumber

        for index in stride(from: 1, through: calculationHistory.count - 1, by: 2) {
            if case .operation(let operation) = calculationHistory[index] {
                if case .number(let number) = calculationHistory[index + 1], operation == .add || operation == .subtract {
                    currentResult = try operation.calculate(currentResult, number)
                } else if case .operation(let nextOperation) = calculationHistory[index + 1], nextOperation == .multiply || nextOperation == .divide {
                    currentResult = try operation.calculate(currentResult, piValue)
                } else if case .number(let number) = calculationHistory[index + 1], operation == .multiply || operation == .divide {
                    currentResult = try operation.calculate(currentResult, number)
                }
            }
        }

        return currentResult
    }

    private func resetLabelText() {
        label.text = "0"
    }

    private func calculatePiWithPrecision(_ precision: Int, completion: @escaping (Double) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let pi = self.calculatePi(precision)
            self.piValue = pi
            DispatchQueue.main.async {
                completion(pi)
            }
        }
    }

    private func calculatePi(_ precision: Int) -> Double {
        var piValue = 0.0
        var denominator = 1.0
        var sign = 1.0
        for _ in 0..<precision {
            piValue += sign * (1.0 / denominator)
            denominator += 2.0
            sign *= -1.0
        }
        return piValue * 4.0
    }

    private func animateAlert() {
        if !view.contains(alertView) {
            alertView.alpha = 0
            alertView.center = view.center
            view.addSubview(alertView)
        }

        UIView.animateKeyframes(withDuration: 2, delay: 0.5) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                self.alertView.alpha = 1
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                var newCenter = self.label.center
                newCenter.y -= self.alertView.bounds.height
                self.alertView.center = newCenter
            }
        }
    }

}

extension UILabel {
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: center.x - 5, y: center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: center.x + 5, y: center.y))

        layer.add(animation, forKey: "position")
    }
}

extension UIButton {
    func animateTap() {
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1, 0.9, 1]
        scaleAnimation.keyTimes = [0, 0.2, 1]

        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.values = [0.4, 0.8, 1]
        opacityAnimation.keyTimes = [0, 0.2, 1]

        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 1.5
        animationGroup.animations = [scaleAnimation, opacityAnimation]

        layer.add(animationGroup, forKey: "groupAnimation")
    }
}

    // MARK: - LongPressViewProtocol

extension ViewController: LongPressViewProtocol {

    @objc
    func longPressGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
            case .began, .changed:
                startAnimation()
            case .ended, .cancelled, .failed:
                stopAnimation()
            default:
                break
        }
    }

    @objc
    func startAnimation() {
        guard !view.contains(shared) else { return }

        shared.alpha = 0
        shared.center = view.center
        view.addSubview(shared)

        UIView.animateKeyframes(withDuration: 5.0, delay: 0.5) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                self.shared.alpha = 1
            }
        }
    }

    func stopAnimation() {
        shared.removeFromSuperview()
    }
}
