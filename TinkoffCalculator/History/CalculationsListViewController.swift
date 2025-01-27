    //
    //  CalculationsListViewController.swift
    //  TinkoffCalculator
    //
    //  Created by R Kolos on 22.01.2025.
    //

import UIKit


class CalculationsListViewController: UIViewController {


    var calculations:[Calculation] = []

        //@IBOutlet weak var calculationLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    override init(
        nibName nibNameOrNil: String?,
        bundle nibBundleOrNil: Bundle?
    ) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initalize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initalize()
    }



    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        let nib = UINib(nibName: "HistoryTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "HistoryTableViewCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: false)
    }


    private func initalize() {
        modalPresentationStyle = .fullScreen
    }


    @IBAction func dismissVC(_ sender: Any) {

        navigationController?.popViewController(animated: true)
    }


    private func expressionToString(
        _ expression: [CalculationHistoryItem]
    ) -> String {

        var result = " "

        for operand in expression {
            switch operand {
                case let .number(value):
                    result += String(value) + " "
                case let .operation(value):
                    result += value.rawValue + " "
            }
        }
        return result
    }
}


extension CalculationsListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.lightGray

        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "dd.MM.yyyy hh:mm"

        let label = UILabel()
        label.text = dateFormater.string(from: calculations[section].date)
        label.textColor = UIColor.white

        headerView.addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor
            .constraint(
                equalTo: headerView.leadingAnchor,
                constant: 10.0
            ).isActive = true
        label.centerYAnchor
            .constraint(equalTo: headerView.centerYAnchor).isActive = true

        return headerView
    }
}

extension CalculationsListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return calculations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "HistoryTableViewCell",
            for: indexPath
        ) as! HistoryTableViewCell
        cell.layer.cornerRadius = 4
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.gray.cgColor

        let historyItem = calculations[indexPath.section]
        cell.configure(
            with: expressionToString(historyItem.expression),
            result: String(historyItem.result)
        )
        return cell
    }
}
