import Foundation

class AutosearchTimer {
    private let interval: TimeInterval
    private let callback: () -> Void
    private var timer: Timer?

    init(interval: TimeInterval = 0.8, callback: @escaping () -> Void) {
        self.interval = interval
        self.callback = callback
    }

    func activate() {
        /// Cancel timer if already set, to avoid unnecessary searches
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.fire()
        }
    }

    private func cancel() {
        timer?.invalidate()
        timer = nil
    }

    private func fire() {
        cancel()
        callback()
    }
}
