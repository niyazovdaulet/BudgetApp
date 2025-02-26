import UIKit
import CoreData

class EditBudgetCategoryViewController: UIViewController {
    private var persistentContainer: NSPersistentContainer
    private var budgetCategory: BudgetCategory
//    var delegate: BudgetCategoryUpdatedDelegate? // Delegate to notify BudgetDetailsViewController
    
    weak var delegate: BudgetCategoryUpdatedDelegate?


    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Edit Budget Category"
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Budget Category"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        return label
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.text = "Budget Amount"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        return label
    }()
    
    private lazy var amountTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        return textField
    }()
    
    private lazy var saveButton: UIButton = {
        var config = UIButton.Configuration.bordered()
        let button = UIButton(configuration: config)
        button.setTitle("Save", for: .normal)
        button.backgroundColor = .black
        button.tintColor = .white
        button.layer.cornerRadius = 16
        
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        var config = UIButton.Configuration.filled()
        let button = UIButton(configuration: config)
        button.setTitle("Cancel", for: .normal)
        button.backgroundColor = .black
        button.tintColor = .white
        button.layer.cornerRadius = 16
        
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    init(persistentContainer: NSPersistentContainer, budgetCategory: BudgetCategory) {
        self.persistentContainer = persistentContainer
        self.budgetCategory = budgetCategory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        nameTextField.text = budgetCategory.name
        amountTextField.text = "\(budgetCategory.amount)"
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            nameLabel, nameTextField,
            amountLabel, amountTextField,
            saveButton, cancelButton
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 14
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40)
        ])
    }
    
    @objc private func saveButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let amountText = amountTextField.text, let amount = Double(amountText), amount > 0 else {
            showAlert(title: "Invalid Input", message: "Please enter a valid name and positive budget amount.")
            return
        }
        
        if amount < budgetCategory.transactionTotal {
            let alert = UIAlertController(
                title: "Warning",
                message: "New budget is lower than the total of existing transactions. Do you want to proceed?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Proceed", style: .destructive) { _ in
                self.updateCategory(name: name, amount: amount)
            })
            present(alert, animated: true)
        } else {
            updateCategory(name: name, amount: amount)
        }
    }
    
    private func updateCategory(name: String, amount: Double) {
        let context = persistentContainer.viewContext
        budgetCategory.name = name
        budgetCategory.amount = amount
        
        do {
            try context.save()
            delegate?.didUpdateBudgetCategory() // Notify BudgetDetailsViewController
            navigationController?.popViewController(animated: true)
        } catch {
            showAlert(title: "Error", message: "Unable to update category.")
        }
    }

    
    @objc private func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
