//
//  ProvidersViewController.swift
//  saltedge-ios_Example
//
//  Created by Vlad Somov.
//  Copyright (c) 2019 Salt Edge. All rights reserved.
//

import UIKit
import SaltEdge
import PKHUD

class ProvidersViewController: UIViewController {
    private var providers: [SEProvider] = []
    private var filteredProviders: [SEProvider] = []
    private let searchController = UISearchController(searchResultsController: nil)
    
    var completion: ((SEProvider) -> Void)?
    
    @IBOutlet weak var tableView: UITableView!

    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        HUD.show(.labeledProgress(title: "Fetching Providers", subtitle: nil))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar

        SERequestManager.shared.getAllProviders { [weak self] response in
            switch response {
            case .success(let value):
                HUD.hide(animated: true)
                guard let strongSelf = self else { return }

                let providers = strongSelf.sortProvidersByCountry(
                    value.data,
                    startingWith: Locale.preferredLanguageCode.uppercased()
                )

                strongSelf.providers = providers
                strongSelf.filteredProviders = providers
                strongSelf.tableView.reloadData()
            case .failure(let error):
                HUD.flash(.labeledError(title: "Error", subtitle: error.localizedDescription), delay: 3.0)
            }
        }
    }

    private func sortProvidersByCountry(_ providers: [SEProvider], startingWith topCountry: String? = nil) -> [SEProvider] {
        return providers.sorted(
            by: {
                if $0.countryCode != $1.countryCode {
                    if $0.countryCode == topCountry || $1.countryCode == topCountry {
                        return $0.countryCode == topCountry
                    }
                    return $0.countryCode < $1.countryCode
                } else {
                    return $0.name < $1.name
                }
            }
        )
    }
}

extension ProvidersViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProviders.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ProviderCell",
            for: indexPath
        ) as? ProviderCell else { return UITableViewCell() }

        cell.provider = filteredProviders[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
}

extension ProvidersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        completion?(filteredProviders[indexPath.row])
        searchController.dismiss(animated: false)
        navigationController?.dismiss(animated: true)
    }
}

extension ProvidersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredProviders = providers.filter { provider in
                return provider.name.lowercased().contains(searchText.lowercased())
            }
        } else {
            filteredProviders = providers
        }
        tableView.reloadData()
    }
}

extension ProvidersViewController {
    static func create(onPick completion: @escaping (SEProvider) -> Void) -> ProvidersViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let vc = storyboard.instantiateViewController(withIdentifier:"ProvidersViewController") as? ProvidersViewController else { return nil }
        
        vc.completion = completion
        return vc
    }
}
