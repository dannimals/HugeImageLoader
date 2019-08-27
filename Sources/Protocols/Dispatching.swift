
import Foundation

public protocol CancellableAction {

    func cancel()

}
extension DispatchWorkItem: CancellableAction {}

protocol Dispatching: class {

    func async(_ block: @escaping () -> Void)
    func delay(_ seconds: TimeInterval, completion: @escaping () -> Void)
    func delayWorker(_ seconds: TimeInterval, workerBlock: @escaping () -> Void) -> CancellableAction

}

extension DispatchQueue: Dispatching {

    public func async(_ block: @escaping () -> Void) {
        self.async(group: nil, execute: block)
    }

    public func delay(_ seconds: TimeInterval, completion: @escaping () -> Void) {
        self.asyncAfter(deadline: .now() + seconds, execute: completion)
    }

    public func delayWorker(_ seconds: TimeInterval, workerBlock: @escaping () -> Void) -> CancellableAction {
        let workItem = DispatchWorkItem(block: workerBlock)
        asyncAfter(deadline: .now() + seconds, execute: workItem)
        return workItem
    }

}
