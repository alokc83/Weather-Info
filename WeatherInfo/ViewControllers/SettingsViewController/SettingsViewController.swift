//
//  SettingsViewController.swift
//  WeatherInfo
//
//  Created by Alok Choudhary on 8/3/18.
//  Copyright © 2018 Mt Aden LLC. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate: class {
    func controllerDidChangeTimeNotation(controller: SettingsViewController)
    func controllerDidChangeUnitsNotation(controller: SettingsViewController)
    func controllerDidChangeTemperatureNotation(controller: SettingsViewController)
}

class SettingsViewController: UIViewController {

    // MARK: - Properties

    @IBOutlet var tableView: UITableView!

    // MARK: -

    weak var delegate: SettingsViewControllerDelegate?

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Settings"

        setupView()
    }

    // MARK: - View Methods

    private func setupView() {
        setupTableView()
    }

    private func updateView() {

    }

    // MARK: -

    private func setupTableView() {
        tableView.separatorInset = UIEdgeInsets.zero
    }

}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {

    private enum Section: Int {
        case time
        case units
        case temperature

        var numberOfRows: Int {
            return 2
        }

        var title: String {
            switch self {
            case .time: return " Time:"
            case .units: return " Speed:"
            case .temperature: return " Temprature: "
            }
        }
        
        static var count: Int {
            return (Section.temperature.rawValue + 1)
        }

    }

    // MARK: - Table View Data Source Methods

    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { fatalError("Unexpected Section") }
        return section.numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { fatalError("Unexpected Section") }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.reuseIdentifier, for: indexPath) as? SettingsTableViewCell else { fatalError("Unexpected Table View Cell") }

        var viewModel: SettingsRepresentable?
        
        switch section {
        case .time:
            guard
                let timeNotation = TimeNotation(rawValue: indexPath.row)
            else { fatalError("Unexpected IndexPath") }
            
            viewModel = SettingsTimeViewModel(timeNotation: timeNotation)

        case .units:
            guard
                let unitsNotation = UnitsNotation(rawValue: indexPath.row)
                else { fatalError("Unexpected IndexPath") }
            
            viewModel = SettingsUnitsViewModel(unitsNotation: unitsNotation)

        case .temperature:
            guard
                let temperatureNotation = TemperatureNotation(rawValue: indexPath.row)
                else { fatalError("Unexpected IndexPath") }
            
            viewModel = SettingsTemperatureViewModel(temperatureNotation: temperatureNotation)

        }
        
        if let viewModel = viewModel {
            cell.configure(with: viewModel)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else { return "" }
        return section.title
    }
    
    // MARK: - Table View Delegate Methods

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let section = Section(rawValue: indexPath.section) else { fatalError("Unexpected Section") }

        switch section {
        case .time:
            let timeNotation = UserDefaults.timeNotation()
            guard indexPath.row != timeNotation.rawValue else { return }

            if let newTimeNotation = TimeNotation(rawValue: indexPath.row) {
                // Update User Defaults
                UserDefaults.setTimeNotation(timeNotation: newTimeNotation)

                // Notify Delegate
                delegate?.controllerDidChangeTimeNotation(controller: self)
            }
        case .units:
            let unitsNotation = UserDefaults.unitsNotation()
            guard indexPath.row != unitsNotation.rawValue else { return }

            if let newUnitsNotation = UnitsNotation(rawValue: indexPath.row) {
                // Update User Defaults
                UserDefaults.setUnitsNotation(unitsNotation: newUnitsNotation)

                // Notify Delegate
                delegate?.controllerDidChangeUnitsNotation(controller: self)
            }
        case .temperature:
            let temperatureNotation = UserDefaults.temperatureNotation()
            guard indexPath.row != temperatureNotation.rawValue else { return }

            if let newTemperatureNotation = TemperatureNotation(rawValue: indexPath.row) {
                // Update User Defaults
                UserDefaults.setTemperatureNotation(temperatureNotation: newTemperatureNotation)

                // Notify Delegate
                delegate?.controllerDidChangeTemperatureNotation(controller: self)
            }
        }

        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
    }

}
