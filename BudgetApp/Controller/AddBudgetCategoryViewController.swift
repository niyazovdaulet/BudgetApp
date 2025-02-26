import UIKit
import CoreData

class AddBudgetCategoryViewController: UIViewController {
    
    private var persistentContainer: NSPersistentContainer
    
    lazy var nameTextField: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "Budget Name"
        textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textfield.leftViewMode = .always
        textfield.borderStyle = .roundedRect
        return textfield
    }()
    lazy var amountTextField: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "Budget Amount"
        textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textfield.leftViewMode = .always
        textfield.borderStyle = .roundedRect
        return textfield
    }()
    lazy var addBudgetButton: UIButton = {
        var config = UIButton.Configuration.bordered()
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Save", for: .normal)
        button.backgroundColor = .black
        button.tintColor = .white
        button.layer.cornerRadius = 16
        return button
    }()
    lazy var errorMessageLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.red
        label.text = ""
        label.numberOfLines = 0
        return label
    }()
    
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Add Budget"
        setupUI()
    }
    
    private var isFormValid: Bool {
        guard let name = nameTextField.text, let amount = amountTextField.text else  {
            return false
        }
        
        return !name.isEmpty && !amount.isEmpty && amount.isNumeric && amount.isGreaterThan(0)
    }
    
    private func saveBudgetCategory() {
        guard let name = nameTextField.text, let amount = amountTextField.text else  {
            return
        }
        do {
            let BudgetCategory = BudgetCategory(context: persistentContainer.viewContext)
            BudgetCategory.name = name
            BudgetCategory.amount = Double(amount) ?? 0.0
            try persistentContainer.viewContext.save()
            dismiss(animated: true)
        } catch {
            errorMessageLabel.text = "Unable to save  budget category."
        }
    }
    
    @objc private func addBudgetButtonPressed(_ sender: UIButton) {
        if isFormValid {
            saveBudgetCategory()
        } else {
            errorMessageLabel.text = "Unable to save the Budget Category. Kindly double-check the name and the amount."
        }
    }
    
    private func setupUI() {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = UIStackView.spacingUseSystem
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(amountTextField)
        stackView.addArrangedSubview(addBudgetButton)
        stackView.addArrangedSubview(errorMessageLabel)
        
        // Constraints
        nameTextField.widthAnchor.constraint(equalToConstant: 330).isActive = true
        amountTextField.widthAnchor.constraint(equalToConstant: 330).isActive = true
        addBudgetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // Button Click
        addBudgetButton.addTarget(self, action: #selector(addBudgetButtonPressed), for: .touchUpInside)
    }
}
