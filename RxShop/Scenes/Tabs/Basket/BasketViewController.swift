//
//  BasketViewController.swift
//  RxShop
//
//  Created by Greg Price on 01/02/2021.
//

import UIKit
import RxSwift
import RxDataSources

extension BasketViewController: Storyboarded {
    static var storyboard: Storyboard = .basket
}

class BasketViewController: UIViewController, HasViewModel {
  
    @IBOutlet weak var checkoutBottom: NSLayoutConstraint!
    @IBOutlet weak var checkoutContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var checkoutButton: UIButton!
    
    private var disposeBag: DisposeBag!
    var viewModelFactory: (BasketInput) -> BasketOutput = { _ in fatalError("Missing view model factory.") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        let checkout = checkoutButton.rxTap()
            .withUnretained(self)
            .flatMapLatest { s, _ in s.checkoutAlert() }
            .filter { $0 == .default }
            .asVoid()
        
        let input = BasketInput(
            delete: tableView.rxItemDeleted(),
            checkout: checkout)
        
        let viewModel = viewModelFactory(input)
        
        disposeBag = DisposeBag {
            tableView.rx.setDelegate(self)
            viewModel.basket.bind(to: tableView.rx.items(dataSource: dataSource()))
            viewModel.basketTotal.bind(to: amountLabel.rx.text)
            viewModel.basketEmpty.bind(to: tableView.rx.isEmpty(message: "Your basket is empty"))
            viewModel.checkoutVisible
                .bind { [weak self] in
                    self?.animateCheckoutContainer(visible: $0.visible, animated: $0.animated)
                }
        }
    }
    
    private func configureUI() {
        title = "Basket"
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0)
        tableView.tableFooterView = UIView()
        tableView.register(BasketCell.reuseIdentifier)

        checkoutContainer.layer.cornerRadius = 12
        totalLabel.style(.title)
        amountLabel.style(.title)
        amountLabel.textColor = .rxShopRed
        checkoutButton.style(.red)
    }
    
    private func animateCheckoutContainer(visible: Bool, animated: Bool) {
        let offset: CGFloat = visible ? 12 : -200
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.checkoutBottom.constant = offset
                self.view.layoutIfNeeded()
            }
        } else {
            checkoutBottom.constant = offset
            view.layoutIfNeeded()
        }
    }
    
    private func checkoutAlert() -> Observable<UIViewController.AlertAction> {
        return alert(title: "Complete Order",
                     message: "Would you like to checkout now and complete your order?",
                     defaultTitle: "Checkout",
                     cancelTitle: "Cancel")
    }
}

extension BasketViewController {
    func dataSource() -> RxTableViewSectionedAnimatedDataSource<BasketSection> {
        let animationConfiguration = AnimationConfiguration(insertAnimation: .left, reloadAnimation: .fade, deleteAnimation: .right)
        return RxTableViewSectionedAnimatedDataSource(animationConfiguration: animationConfiguration,
              
          configureCell: { _, tableView, indexPath, item in
            return BasketCellConfigurator.cellFrom(tableView, at: indexPath, configuredWith: item)
          },
              
          canEditRowAtIndexPath: { _, _ in
            return true
          })
    }
}

extension BasketViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
}
