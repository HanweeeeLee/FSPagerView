//
//  FSPagerView+Rx.swift
//  RxFSPagerView
//
//  Created by hanwe lee on 2022/2/09.
//

import RxSwift
import RxCocoa
import Foundation

public extension Reactive where Base: FSPagerView {
  
  typealias FSConfigureCell<S: Sequence, Cell> = (Int, S.Iterator.Element, Cell) -> Void
  
  func items<S: Sequence, Cell: FSPagerViewCell, O: ObservableType>(
      cellIdentifier: String,
      cellType: Cell.Type = Cell.self
    ) -> (_ source: O) -> (_ configureCell: @escaping FSConfigureCell<S, Cell>) -> Disposable
    where O.Element == S {
      base.collectionView.dataSource = nil
      return { source in
        let source = source.observe(on: ConcurrentDispatchQueueScheduler(queue: .global()))
          .map { sequence -> [S.Element] in
            let items: [S.Element] = {
              var items = Array(sequence)
              if items.count > 0 {
                let lastItem = items.last!
                let lastBeforeItem: S.Element = {
                  if items.count > 1 {
                    return items[items.count - 2]
                  } else {
                    return items.last!
                  }
                }()
                let firstItme = items.first!
                let firstAfterItem: S.Element = {
                  if items.count > 1 {
                    return items[1]
                  } else {
                    return items.first!
                  }
                }()
                items.insert(lastItem, at: 0)
                items.insert(lastBeforeItem, at: 0)
                items.append(firstItme)
                items.append(firstAfterItem)
              }
              return items
            }()
            base.numberOfItems = items.count
            return items
          }
        return self.base.collectionView.rx.items(
          cellIdentifier: cellIdentifier,
          cellType: cellType
        )(source)
      }
    }
}
