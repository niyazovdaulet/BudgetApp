import UIKit
import CoreData

class BudgetDetailsViewController: UIViewController {
    private var persistentContainer: NSPersistentContainer
    private var fetchedResultsController: NSFetchedResultsController<Transaction>!
    private var budgetCategory: BudgetCategory
    
    lazy var nameTextField: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "Transaction Name"
        textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textfield.leftViewMode = .always
        textfield.borderStyle = .roundedRect
        return textfield
    }()
    
    lazy var amountTextField: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "Transaction Amount"
        textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textfield.leftViewMode = .always
        textfield.borderStyle = .roundedRect
        return textfield
    }()
    
    lazy var tableView: UITableView = {
        let tableview = UITableView()
        tableview.translatesAutoresizingMaskIntoConstraints = false
        tableview.dataSource = self
        tableview.delegate = self
        tableview.backgroundColor = .clear
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "TransactionTableViewCell")
        return tableview
    }()
    
    lazy var saveTransactionButton: UIButton = {
        var config = UIButton.Configuration.bordered()
        let button = UIButton(configuration: config)
        button.setTitle("Save Transaction", for: .normal)
        button.backgroundColor = .black
        button.tintColor = .white
        button.layer.cornerRadius = 16
        
        button.addTarget(self, action: #selector(saveTransactionButtonPressed), for: .touchUpInside)
        return button
    }()
    
    lazy var errorMessageLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.red
        label.text = ""
        label.numberOfLines = 0
        return label
    }()
    
    lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.text = budgetCategory.amount.formatAsCurrency()
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        return label
    }()
    
    lazy var transactionsTotalLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        return label
    }()
    
    lazy var clearButton: UIButton = {
        var config = UIButton.Configuration.plain()
        let button = UIButton(configuration: config)
        button.setTitle("Clear", for: .normal)
        button.setTitleColor(.systemRed, for: .normal) // Red color for emphasis
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(clearButtonPressed), for: .touchUpInside)
        return button
    }()

    @objc private func clearButtonPressed() {
        let context = persistentContainer.viewContext
        
        for transaction in fetchedResultsController.fetchedObjects ?? [] {
            context.delete(transaction)
        }
        
        do {
            try context.save()
            tableView.reloadData()
            updateTransactionTotal()
        } catch {
            errorMessageLabel.text = "Unable to clear transactions."
        }
    }

    
    private func updateTransactionTotal() {
        transactionsTotalLabel.text = budgetCategory.transactionTotal.formatAsCurrency()
    }
    
    private func resetForm() {
        nameTextField.text = ""
        amountTextField.text = ""
        errorMessageLabel.text = ""
    }
    
    init(persistentContainer: NSPersistentContainer, budgetCategory: BudgetCategory) {
        self.persistentContainer = persistentContainer
        self.budgetCategory = budgetCategory
        super.init(nibName: nil, bundle: nil)
        
        let request = Transaction.fetchRequest()
        request.predicate = NSPredicate(format: "category = %@", budgetCategory)
        request.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            errorMessageLabel.text = "Unable to fetch transactions."
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateTransactionTotal()
    }
    
    private var isFormValid: Bool {
        guard let name = nameTextField.text, let amount = amountTextField.text else {
            return false
        }
        return !name.isEmpty && !amount.isEmpty && amount.isNumeric && amount.isGreaterThan(0)
    }
    
    private func deleteTransaction(_ transaction: Transaction) {
        persistentContainer.viewContext.delete(transaction)
        do {
            try persistentContainer.viewContext.save()
        } catch {
            errorMessageLabel.text = "Unable to delete a transaction."
        }
    }
    
    private func saveTransaction() {
        guard let name = nameTextField.text, let amount = amountTextField.text else {
            return
        }
        
        let transaction = Transaction(context: persistentContainer.viewContext)
        transaction.name = name
        transaction.amount = Double(amount) ?? 0.01
        transaction.category = budgetCategory
        transaction.dateCreated = Date()
        
        do {
            try persistentContainer.viewContext.save()
            resetForm()
            tableView.reloadData()
        } catch {
            errorMessageLabel.text = "Unable to save the transaction."
        }
    }
    
    @objc private func saveTransactionButtonPressed(_ sender: UIButton) {
        if isFormValid {
           saveTransaction()
        } else {
            errorMessageLabel.text = "Make sure the name and the amount is valid."
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground // Adjust for dark mode
        navigationController?.navigationBar.prefersLargeTitles = true
        title = budgetCategory.name
        navigationController?.navigationBar.tintColor = .label // Back button color adapts to theme
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        stackView.addArrangedSubview(amountLabel)
        stackView.setCustomSpacing(30, after: amountLabel)
        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(amountTextField)
        stackView.addArrangedSubview(saveTransactionButton)
        stackView.addArrangedSubview(errorMessageLabel)
        stackView.addArrangedSubview(transactionsTotalLabel)
        
        
        
        view.addSubview(stackView)
        stackView.addArrangedSubview(clearButton)

        // Align to the right side
        clearButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -10).isActive = true

        view.addSubview(tableView)
        
        // StackView Constraints
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
            
        ])
        
        // TableView Constraints
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            tableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
}

extension BudgetDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell", for: indexPath)
        
        let transaction = fetchedResultsController.object(at: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = transaction.name
        content.secondaryText = transaction.amount.formatAsCurrency()
        cell.contentConfiguration = content
        
        return cell
    }
}

extension BudgetDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let transaction = fetchedResultsController.object(at: indexPath)
            deleteTransaction(transaction)
        }
    }
}

extension BudgetDetailsViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateTransactionTotal()
        tableView.reloadData()
    }
}
