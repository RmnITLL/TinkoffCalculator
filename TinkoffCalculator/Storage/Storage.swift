//
//  Storage.swift
//  TinkoffCalculator
//
//  Created by R Kolos on 25.01.2025.
//

import Foundation

struct Calculation {
    let expression: [CalculationHistoryItem]
    let result: Double
}

extension Calculation: Codable {

}

extension CalculationHistoryItem: Codable {
    enum CodingKeys: String, CodingKey {
        case number
        case operation
    }

    func encode(to encoder: Encoder) throws {
        var conteiner = encoder.container(keyedBy: CodingKeys.self)

        switch self {
            case .number(let value):
                try conteiner.encode(value, forKey: CodingKeys.number)
            case .operation(let value):
                try conteiner
                    .encode(value.rawValue, forKey: CodingKeys.operation)
        }
    }

    enum CalculationHistoryItemError: Error {
        case itenNotFound
    }

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let number = try container.decodeIfPresent(Double.self, forKey: .number) {
            self = .number(number)
            return
        }

        if let rawOperation = try container.decodeIfPresent(
            String.self,
            forKey: .operation),
           let opration = Operation(rawValue: rawOperation) {
            self = .operation(opration)
            return
        }

        throw CalculationHistoryItemError.itenNotFound
    }
}

class CalculationHisoryStorage {

    static let calculationHistoryKey = "calculationHistoryKey"

    func setHistory(calculation: [Calculation]) {
        if let encoded = try? JSONEncoder().encode(calculation) {
            UserDefaults.standard
                .set(
                    encoded,
                    forKey: CalculationHisoryStorage.calculationHistoryKey
                )
        }
    }

    func loadHistory() -> [Calculation] {
        if let data = UserDefaults.standard.data(
            forKey: CalculationHisoryStorage.calculationHistoryKey
        ) {
            return (try? JSONDecoder().decode([Calculation].self, from: data)) ?? []
        }
        return []
    }
}
