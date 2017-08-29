

extension DependencyContainer {

    // MARK: 1 Runtime Argument

    /**
     Register factory that accepts one runtime argument of type `A`. You can use up to six runtime arguments.

     - note: You can have several factories with different number or types of arguments registered for same type,
     optionally associated with some tags. When container resolves that type it matches the type,
     __number__, __types__ and __order__ of runtime arguments and optional tag that you pass to `resolve(tag:arguments:)` method.

     - parameters:
     - tag: The arbitrary tag to associate this factory with. Pass `nil` to associate with any tag. Default value is `nil`.
     - scope: The scope to use for this component. Default value is `Shared`.
     - factory: The factory to register.

     - seealso: `register(_:type:tag:factory:)`
     */

    @discardableResult
    public func register<T, A>(_ scope: ComponentScope = .shared,
                               type: T.Type = T.self,
                               tag: DependencyTagConvertible? = nil,
                               factory: @escaping (A) throws -> T) -> Definition<T, A> {
        var definition: Definition<T, A>!

        definition = register(scope: scope,
                              type: type,
                              tag: tag,
                              factory: factory,
                              numberOfArguments: 1) { container, key in

            let a: A = try container.resolve(tag: key.tag)

            if let previouslyResolved: T = container.previouslyResolved(for: definition, key: key) {
                return previouslyResolved
            }

            return try factory(a)
        }

        return definition
    }

    /**
     Resolve type `T` using one runtime argument.

     - note: When resolving a type container will first try to use definition
     that exactly matches types of arguments that you pass to resolve method.
     If it fails or no such definition is found container will try to _auto-wire_ component.
     For that it will iterate through all the definitions registered for that type
     which factories accept any number of runtime arguments and are tagged with the same tag,
     passed to `resolve` method, or with no tag. Container will try to use these definitions
     to resolve a component one by one until one of them succeeds, starting with tagged definitions
     in order of decreasing their's factories number of arguments. If none of them succeds it will
     throw an error. If it finds two definitions with the same number of arguments - it will throw
     an error.

     - parameters:
     - tag: The arbitrary tag to lookup registered definition.
     - arg1: The first argument to pass to the definition's factory.

     - throws: `DipError.DefinitionNotFound`, `DipError.AutoInjectionFailed`, `DipError.AmbiguousDefinitions`

     - returns: An instance of type `T`.

     - seealso: `register(_:type:tag:factory:)`, `resolve(tag:builder:)`
     */
    public func resolve<T, A>(tag: DependencyTagConvertible? = nil, arguments arg1: A) throws -> T {
        return try resolve(tag: tag) { factory in try factory(arg1) }
    }

    /// - seealso: `resolve(_:tag:)`, `resolve(tag:arguments:)`
    public func resolve<A>(_ type: Any.Type, tag: DependencyTagConvertible? = nil, arguments arg1: A) throws -> Any {
        return try resolve(type, tag: tag) { factory in try factory(arg1) }
    }

    // MARK: 2 Runtime Arguments

    /// - seealso: `register(_:type:tag:factory:)`

    @discardableResult
    public func register<T, A, B>(_ scope: ComponentScope = .shared,
                                  type: T.Type = T.self,
                                  tag: DependencyTagConvertible? = nil,
                                  factory: @escaping (A, B) throws -> T) -> Definition<T, (A, B)> {
        var definition: Definition<T, (A, B)>!

        definition = register(scope: scope,
                              type: type,
                              tag: tag,
                              factory: factory,
                              numberOfArguments: 2) { container, key in

            let a: A = try container.resolve(tag: key.tag)
            let b: B = try container.resolve(tag: key.tag)

            if let previouslyResolved: T = container.previouslyResolved(for: definition, key: key) {
                return previouslyResolved
            }

            return try factory(a, b)
        }

        return definition
    }

    /// - seealso: `resolve(tag:arguments:)`
    public func resolve<T, A, B>(tag: DependencyTagConvertible? = nil, arguments arg1: A, _ arg2: B) throws -> T {
        return try resolve(tag: tag) { factory in try factory(arg1, arg2) }
    }

    /// - seealso: `resolve(_:tag:)`, `resolve(tag:arguments:)`
    public func resolve<A, B>(_ type: Any.Type, tag: DependencyTagConvertible? = nil, arguments arg1: A, _ arg2: B) throws -> Any {
        return try resolve(type, tag: tag) { factory in try factory((arg1, arg2)) }
    }

    // MARK: 3 Runtime Arguments

    /// - seealso: `register(_:type:tag:factory:)`

    @discardableResult
    public func register<T, A, B, C>(_ scope: ComponentScope = .shared,
                                     type: T.Type = T.self,
                                     tag: DependencyTagConvertible? = nil,
                                     factory: @escaping (A, B, C) throws -> T) -> Definition<T, (A, B, C)> {
        var definition: Definition<T, (A, B, C)>!

        definition = register(scope: scope,
                              type: type,
                              tag: tag,
                              factory: factory,
                              numberOfArguments: 3) { container, key in

            let a: A = try container.resolve(tag: key.tag)
            let b: B = try container.resolve(tag: key.tag)
            let c: C = try container.resolve(tag: key.tag)

            if let previouslyResolved: T = container.previouslyResolved(for: definition, key: key) {
                return previouslyResolved
            }

            return try factory(a, b, c)
        }

        return definition
    }

    /// - seealso: `resolve(tag:arguments:)`
    public func resolve<T, A, B, C>(tag: DependencyTagConvertible? = nil, arguments arg1: A, _ arg2: B, _ arg3: C) throws -> T {
        return try resolve(tag: tag) { factory in try factory(arg1, arg2, arg3) }
    }

    /// - seealso: `resolve(_:tag:)`, `resolve(tag:arguments:)`
    public func resolve<A, B, C>(_ type: Any.Type, tag: DependencyTagConvertible? = nil, arguments arg1: A, _ arg2: B, _ arg3: C) throws -> Any {
        return try resolve(type, tag: tag) { factory in try factory((arg1, arg2, arg3)) }
    }

    // MARK: 4 Runtime Arguments

    /// - seealso: `register(_:type:tag:factory:)`

    @discardableResult
    public func register<T, A, B, C, D>(_ scope: ComponentScope = .shared,
                                        type: T.Type = T.self,
                                        tag: DependencyTagConvertible? = nil,
                                        factory: @escaping (A, B, C, D) throws -> T) -> Definition<T, (A, B, C, D)> {
        var definition: Definition<T, (A, B, C, D)>!

        definition = register(scope: scope,
                              type: type,
                              tag: tag,
                              factory: factory,
                              numberOfArguments: 4) { container, key in

            let a: A = try container.resolve(tag: key.tag)
            let b: B = try container.resolve(tag: key.tag)
            let c: C = try container.resolve(tag: key.tag)
            let d: D = try container.resolve(tag: key.tag)

            if let previouslyResolved: T = container.previouslyResolved(for: definition, key: key) {
                return previouslyResolved
            }

            return try factory(a, b, c, d)
        }

        return definition
    }

    /// - seealso: `resolve(tag:arguments:)`
    public func resolve<T, A, B, C, D>(tag: DependencyTagConvertible? = nil, arguments arg1: A, _ arg2: B, _ arg3: C, _ arg4: D) throws -> T {
        return try resolve(tag: tag) { factory in try factory(arg1, arg2, arg3, arg4) }
    }

    /// - seealso: `resolve(_:tag:)`, `resolve(tag:arguments:)`
    public func resolve<A, B, C, D>(_ type: Any.Type, tag: DependencyTagConvertible? = nil, arguments arg1: A, _ arg2: B, _ arg3: C, _ arg4: D) throws -> Any {
        return try resolve(type, tag: tag) { factory in try factory((arg1, arg2, arg3, arg4)) }
    }

    // MARK: 5 Runtime Arguments

    /// - seealso: `register(_:type:tag:factory:)`

    @discardableResult
    public func register<T, A, B, C, D, E>(_ scope: ComponentScope = .shared,
                                           type: T.Type = T.self,
                                           tag: DependencyTagConvertible? = nil,
                                           factory: @escaping (A, B, C, D, E) throws -> T) -> Definition<T, (A, B, C, D, E)> {
        var definition: Definition<T, (A, B, C, D, E)>!

        definition = register(scope: scope,
                              type: type,
                              tag: tag,
                              factory: factory,
                              numberOfArguments: 5) { container, key in

            let a: A = try container.resolve(tag: key.tag)
            let b: B = try container.resolve(tag: key.tag)
            let c: C = try container.resolve(tag: key.tag)
            let d: D = try container.resolve(tag: key.tag)
            let e: E = try container.resolve(tag: key.tag)

            if let previouslyResolved: T = container.previouslyResolved(for: definition, key: key) {
                return previouslyResolved
            }

            return try factory(a, b, c, d, e)
        }

        return definition
    }

    /// - seealso: `resolve(tag:arguments:)`
    public func resolve<T, A, B, C, D, E>(tag: DependencyTagConvertible? = nil, arguments arg1: A, _ arg2: B, _ arg3: C, _ arg4: D, _ arg5: E) throws -> T {
        return try resolve(tag: tag) { factory in try factory(arg1, arg2, arg3, arg4, arg5) }
    }

    /// - seealso: `resolve(_:tag:)`, `resolve(tag:arguments:)`
    public func resolve<A, B, C, D, E>(_ type: Any.Type, tag: DependencyTagConvertible? = nil, arguments arg1: A, _ arg2: B, _ arg3: C, _ arg4: D, _ arg5: E) throws -> Any {
        return try resolve(type, tag: tag) { factory in try factory((arg1, arg2, arg3, arg4, arg5)) }
    }

    // MARK: 6 Runtime Arguments

    /// - seealso: `register(_:type:tag:factory:)`

    @discardableResult
    public func register<T, A, B, C, D, E, F>(_ scope: ComponentScope = .shared,
                                              type: T.Type = T.self,
                                              tag: DependencyTagConvertible? = nil,
                                              factory: @escaping (A, B, C, D, E, F) throws -> T) -> Definition<T, (A, B, C, D, E, F)> {
        var definition: Definition<T, (A, B, C, D, E, F)>!

        definition = register(scope: scope,
                              type: type,
                              tag: tag,
                              factory: factory,
                              numberOfArguments: 6) { container, key in

            let a: A = try container.resolve(tag: key.tag)
            let b: B = try container.resolve(tag: key.tag)
            let c: C = try container.resolve(tag: key.tag)
            let d: D = try container.resolve(tag: key.tag)
            let e: E = try container.resolve(tag: key.tag)
            let f: F = try container.resolve(tag: key.tag)

            if let previouslyResolved: T = container.previouslyResolved(for: definition, key: key) {
                return previouslyResolved
            }

            return try factory(a, b, c, d, e, f)
        }

        return definition
    }

    /// - seealso: `resolve(tag:arguments:)`
    public func resolve<T, A, B, C, D, E, F>(tag: DependencyTagConvertible? = nil, arguments arg1: A, _ arg2: B, _ arg3: C, _ arg4: D, _ arg5: E, _ arg6: F) throws -> T {
        return try resolve(tag: tag) { factory in try factory(arg1, arg2, arg3, arg4, arg5, arg6) }
    }

    /// - seealso: `resolve(_:tag:)`, `resolve(tag:arguments:)`
    public func resolve<A, B, C, D, E, F>(_ type: Any.Type, tag: DependencyTagConvertible? = nil, arguments arg1: A, _ arg2: B, _ arg3: C, _ arg4: D, _ arg5: E, _ arg6: F) throws -> Any {
        return try resolve(type, tag: tag) { factory in try factory((arg1, arg2, arg3, arg4, arg5, arg6)) }
    }
}
