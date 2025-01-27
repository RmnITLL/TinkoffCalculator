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

        addDateHeaderToTableView(tableView: tableView)

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

    private func addDateHeaderToTableView(tableView: UITableView) {
        let headerView = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: tableView.bounds.size.width,
            height: 50
        ))

        headerView.backgroundColor = UIColor.systemBackground

        let headerLabel = UILabel(
            frame: CGRect(
                x: 16,
                y: 0,
                width: tableView.bounds.size.width - 32,
                height: 50
            )
        )
        headerLabel.textColor = UIColor.label
        headerLabel.textAlignment = .center
        headerLabel.font = UIFont.systemFont(ofSize: 16)

        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "dd.MM.yyyy  hh:mm"
        let currentDate = dateFormater.string(from: Date())
        headerLabel.text = currentDate

        headerView.addSubview(headerLabel)
        tableView.tableHeaderView = headerView
    }
}

extension CalculationsListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

extension CalculationsListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calculations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "HistoryTableViewCell",
            for: indexPath
        ) as! HistoryTableViewCell
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.gray.cgColor

        let historyItem = calculations[indexPath.row]
        cell.configure(
                with: expressionToString(historyItem.expression),
                result: String(historyItem.result)
            )

        return cell
    }
}
