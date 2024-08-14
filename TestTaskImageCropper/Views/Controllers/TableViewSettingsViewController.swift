import UIKit

class TableViewSettingsViewController: UIViewController {
    
    // MARK: List of views
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.identifier)
        return tableView
    }()
    
    
    // MARK: List of data
    private var arrayOfCells: [String] = []
    private let tableDataViewModel = TableDataViewModel()
    
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableDataViewModel.saveData(with: arrayOfCells)
    }
    
    
    // MARK: - Private
    private func configureViewController() {
        configureSuperView()
        configureUI()
        configureBinds()
        loadingData()
    }
    
    private func configureSuperView() {
        setUpNavigationBar()
    }
    
    private func configureUI() {
        addTableView()
    }
    
    private func configureBinds() {
        tableDataViewModel.data.bind { newData in
            self.arrayOfCells = newData
            self.tableView.reloadData()
        }
    }
    
    private func loadingData() {
        tableDataViewModel.upload()
    }
    
    private func addTableView() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setUpNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewCell))
    }
    
    @objc private func addNewCell() {
        showAlertForCells(with: "Об приложении", and: "Введите текст")
    }
}


// MARK: - Extensions
extension TableViewSettingsViewController {
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    private func showAlertForCells(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let textForCell = alert.textFields?.first?.text, !textForCell.isEmpty else { return }
            self.arrayOfCells.append(textForCell)
            self.tableDataViewModel.saveData(with: self.arrayOfCells)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "Your name"
        }
        present(alert, animated: true)
    }
}


extension TableViewSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrayOfCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.identifier, for: indexPath) as? TableViewCell else { return UITableViewCell() }
        cell.configureCell(with: arrayOfCells[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if arrayOfCells[indexPath.row] == "Об приложении" {
            showAlert(title: "Об приложении", message: "iOS Разработчик: \(PersonModel.getInformationAboutPerson().fullName)")
        } else {
            showAlert(title: arrayOfCells[indexPath.row], message: arrayOfCells[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .insert {
            tableView.beginUpdates()
        }
        
        if editingStyle == .delete {
            tableView.beginUpdates()
            arrayOfCells.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
}

