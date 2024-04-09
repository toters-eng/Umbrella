public protocol AnalyticsType {
    associatedtype Event: EventType
    func register(provider: ProviderType)
    func log(_ event: Event)
}

public protocol ProviderType {
    var id: String {get}
    func log(_ eventName: String, parameters: [String: Any]?)
    var manualOnly: Bool {get}
}

public extension ProviderType {
    var manualOnly: Bool {
        return false
    }
}

public protocol EventType {
    func name(for provider: ProviderType) -> String?
    func parameters(for provider: ProviderType) -> [String: Any]?
    var excludedProviderIDs: [String] {get}
    var manualProviderIDs: [String]? {get}
}


public extension EventType {
    var excludedProviderIDs: [String] {
        return []
    }
    var manualProviderIDs: [String]? {
        return nil
    }
}

open class Analytics<Event: EventType>: AnalyticsType {
    private(set) open var providers: [ProviderType] = []
    
    public init() {
        // I'm Analytics 👋
    }
    
    open func register(provider: ProviderType) {
        self.providers.append(provider)
    }
    open func log(event: Event, for providers: [ProviderType]) {
        for provider in providers {
            guard let eventName = event.name(for: provider) else {continue}
            let parameters = event.parameters(for: provider)
            provider.log(eventName, parameters: parameters)
        }
    }
    open func log(_ event: Event) {
        let manualProviders = event.manualProviderIDs?.compactMap { provider in
            return providers.first(where: {$0.id == provider})
        }
        let eventProviders = manualProviders ?? providers.filter { provider in
            let providerIsExcluded = event.excludedProviderIDs.contains(provider.id)
            return !providerIsExcluded && !provider.manualOnly
        }
        log(event: event, for: eventProviders)
    }
}
