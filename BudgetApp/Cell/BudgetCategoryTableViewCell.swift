import UIKit
import SwiftUI

class BudgetTableViewCell: UITableViewCell {
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var amountLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var remainingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.alpha = 0.5
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        let stackView = UIStackView()
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 44)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.spacing = UIStackView.spacingUseSystem
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true

        stackView.addArrangedSubview(nameLabel)
        
        let vStackView = UIStackView()
        vStackView.axis = .vertical
        vStackView.alignment = .trailing
        vStackView.addArrangedSubview(amountLabel)
        vStackView.addArrangedSubview(remainingLabel)
        
        stackView.addArrangedSubview(vStackView)
        self.addSubview(stackView)
        
        stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        
    }
    func configure(_ budgetCategory: BudgetCategory) {
        nameLabel.text = budgetCategory.name
        amountLabel.text = budgetCategory.amount.formatAsCurrency()
        remainingLabel.text = "Remaining: \(budgetCategory.remainingAmount.formatAsCurrency())"
    }
}

struct BudgetTableViewCellRepresentable: UIViewRepresentable {
    
    func makeUIView(context: Context) -> some UIView {
        BudgetTableViewCell(style: .default, reuseIdentifier: "BudgetTableViewCell")
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

struct BudgetTableViewCell_Previews: PreviewProvider {
    static var previews: some View {
        BudgetTableViewCellRepresentable()
    }
}
