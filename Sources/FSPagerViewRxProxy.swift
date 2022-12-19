//
//  RxProxy.swift
//  
//
//  Created by Hanwe LEE on 2022/12/19.
//

import RxSwift
import RxCocoa
import Foundation

class FSPagerViewDelegateProxy: DelegateProxy<FSPagerView, FSPagerViewDelegate>, DelegateProxyType, FSPagerViewDelegate {
  
  static func registerKnownImplementations() {
    self.register { (viewController) -> FSPagerViewDelegateProxy in
      FSPagerViewDelegateProxy(parentObject: viewController, delegateProxy: self)
    }
  }
  
  static func currentDelegate(for object: FSPagerView) -> FSPagerViewDelegate? {
    return object.delegate
  }
  
  static func setCurrentDelegate(_ delegate: FSPagerViewDelegate?, to object: FSPagerView) {
    object.delegate = delegate
  }
  
}

extension Reactive where Base == FSPagerView {
  
  var delegate: DelegateProxy<FSPagerView, FSPagerViewDelegate> {
    return FSPagerViewDelegateProxy.proxy(for: self.base)
  }
  
  public var didSelectedItem: Observable<Int> {
    return delegate.methodInvoked(#selector(FSPagerViewDelegate.pagerView(_:didSelectItemAt:)))
      .map { param in
        return param[1] as? Int ?? 0
      }
  }
  
  public typealias ConfigureCell<S: Sequence, Cell> = (Int, S.Iterator.Element, Cell) -> Void
  
  public func items<S: Sequence, Cell: FSPagerViewCell, O: ObservableType>(
    cellIdentifier: String,
    cellType: Cell.Type = Cell.self
  ) -> (_ source: O) -> (_ configureCell: @escaping ConfigureCell<S, Cell>) -> Disposable
  where O.Element == S {
    base.collectionView.dataSource = nil
    return { source in
      let source = source.observe(on: ConcurrentDispatchQueueScheduler(queue: .global()))
        .map { sequence -> [S.Element] in
          let items: [S.Element] = {
            var items = Array(sequence)
            if items.count > 0 {
              let lastItem = items.last!
              let firstItme = items.first!
              items.insert(lastItem, at: 0)
              items.append(firstItme)
            }
            return items
          }()
          if base.isInfinite {
            if items.count == 0 {
              base.numberOfItems = 0
            } else if items.count == 1 {
              base.numberOfItems = 1
            } else {
              base.numberOfItems = Int(items.count - 2)
            }
          } else {
            base.numberOfItems = items.count
          }
          return items
        }
      return self.base.collectionView.rx.items(
        cellIdentifier: cellIdentifier,
        cellType: cellType
      )(source)
    }
  }
  
}
