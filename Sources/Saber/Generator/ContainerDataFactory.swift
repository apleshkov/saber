//
//  ContainerDataFactory.swift
//  Saber
//
//  Created by Andrew Pleshkov on 06/05/2018.
//

import Foundation

public class ContainerDataFactory {

    private let config: SaberConfiguration
    
    public init(config: SaberConfiguration) {
        self.config = config
    }

    public func make(from container: Container) -> ContainerData {
        Logger?.debug("Making '\(container.name)' data to render...")
        var data = ContainerData(name: container.name, initializer: ContainerData.Initializer())
        data.imports = ["Foundation"] + container.imports
        Logger?.debug("- imports: \(data.imports)")
        data.inheritedFrom = [container.protocolName]
        Logger?.debug("- inheritedFrom: \(data.inheritedFrom)")
        if container.isThreadSafe {
            Logger?.debug("- is thread safe: appending a lock")
            data.storedProperties.append(["private let lock = NSRecursiveLock()"])
        }
        container.dependencies.forEach {
            let name = memberName(of: $0)
            let typeName = $0.fullName(modular: true)
            data.storedProperties.append(["\(config.accessLevel) unowned let \(name): \(typeName)"])
            data.initializer.storedProperties.append("self.\(name) = \(name)")
            data.initializer.args.append((name: name, typeName: typeName))
            Logger?.debug("- dependency: \(name): \(typeName)")
        }
        container.externals.forEach {
            let name = memberName(of: $0.type)
            let typeName = $0.type.fullName(modular: true)
            data.storedProperties.append(["\(config.accessLevel) let \(name): \(typeName)"])
            data.initializer.args.append((name: name, typeName: typeName))
            data.initializer.storedProperties.append("self.\(name) = \(name)")
            Logger?.debug("- external: \(name): \(typeName)")
        }
        container.services.forEach { (service) in
            let isCached: Bool
            switch service.storage {
            case .cached:
                isCached = true
            case .none:
                isCached = false
            }
            expand(data: &data, typeResolver: service.typeResolver, isCached: isCached, isThreadSafe: container.isThreadSafe, accessLevel: config.accessLevel)
        }
        return data
    }

    private func expand(data: inout ContainerData,
                        some: SomeType,
                        isCached: Bool,
                        isThreadSafe: Bool,
                        accessLevel: String) {
        if isCached {
            let name = memberName(of: some)
            let cachedName = "cached_\(name)"
            let fullTypeName: String = {
                var some = some
                some.isOptional = true
                return some.fullName(modular: true)
            }()
            data.storedProperties.append(["private var \(cachedName): \(fullTypeName)"])
            data.getters.append(
                getter(of: some, accessLevel: accessLevel, cached: (memberName: cachedName, isThreadSafe: isThreadSafe))
            )
        } else {
            data.getters.append(
                getter(of: some, accessLevel: accessLevel)
            )
        }
    }

    private func expand(data: inout ContainerData,
                        provided usage: TypeUsage,
                        by provider: TypeProvider,
                        isCached: Bool,
                        isThreadSafe: Bool,
                        accessLevel: String) {
        let makerName = memberName(of: usage, prefix: "make")
        expand(data: &data, some: usage, isCached: false, isThreadSafe: false, accessLevel: accessLevel)
        let providerDecl = provider.decl
        data.makers.append(
            [
                "private func \(makerName)() -> \(usage.fullName(modular: true)) {",
                "\(config.indent)let provider = \(accessor(of: .explicit(providerDecl), owner: "self"))",
                "\(config.indent)return \(invoked("provider", isOptional: providerDecl.isOptional, with: provider.methodName, args: provider.args))",
                "}"
            ]
        )
        Logger?.debug("- maker: \(makerName)() -> \(usage.fullName(modular: true))")
    }
    
    private func expand(data: inout ContainerData,
                        typeResolver: TypeResolver<TypeDeclaration>,
                        isCached: Bool,
                        isThreadSafe: Bool,
                        accessLevel: String) {
        switch typeResolver {
        case .explicit(let decl):
            let injectorAccessLevel: String
            if let maker = maker(for: decl) {
                expand(data: &data, some: decl, isCached: isCached, isThreadSafe: isThreadSafe, accessLevel: accessLevel)
                data.makers.append(maker)
                injectorAccessLevel = "private"
            } else {
                injectorAccessLevel = accessLevel
            }
            if let injector = injector(for: decl, accessLevel: injectorAccessLevel) {
                data.injectors.append(injector)
            }
        case .provided(let usage, let provider):
            expand(data: &data, provided: usage, by: provider, isCached: isCached, isThreadSafe: isThreadSafe, accessLevel: accessLevel)
        case .bound(let mimicType, let decl):
            data.getters.append([
                "\(accessLevel) var \(memberName(of: mimicType)): \(mimicType.fullName(modular: true)) {",
                "\(config.indent)return \(accessor(of: .explicit(decl), owner: "self"))",
                "}"
                ])
            Logger?.debug("- getter \(memberName(of: mimicType)): \(mimicType.fullName(modular: true)) -- cached: none; thread-safe: false")
        case .derived(_, _):
            break
        case .external(_):
            break
        case .container:
            break
        }
    }

    func memberName(of some: SomeType, prefix: String? = nil) -> String {
        var result: String
        let name = some.name.split(separator: ".").joined()
        if let prefix = prefix {
            result = prefix + name
        } else {
            let first = String(name.first!).lowercased()
            result = first + name.dropFirst()
        }
        if let usage = some as? TypeUsage, usage.generics.count > 0 {
            result += "_"
            result += usage.generics
                .map {
                    let prefix = $0.isOptional ? "Optional" : ""
                    return memberName(of: $0, prefix: prefix)
                }
                .joined(separator: "_")
        }
        return result
    }
    
    func getter(of some: SomeType, accessLevel: String, cached: (memberName: String, isThreadSafe: Bool)? = nil) -> [String] {
        var body: [String] = []
        if let cached = cached {
            if cached.isThreadSafe {
                body.append("self.lock.lock()")
                body.append("defer { self.lock.unlock() }")
            }
            body.append("if let cached = self.\(cached.memberName) { return cached }")
        }
        let maker = "self.\(memberName(of: some, prefix: "make"))()"
        let name = memberName(of: some)
        if let decl = some as? TypeDeclaration, decl.memberInjections.count > 0 || decl.methodInjections.count > 0 {
            let strDecl = decl.isReference ? "let" : "var"
            body.append("\(strDecl) \(name) = \(maker)")
            let providedValue = decl.isReference ? name : "&\(name)"
            if decl.isOptional {
                body.append("if \(strDecl) \(name) = \(name) { self.injectTo(\(name): \(providedValue)) }")
            } else {
                body.append("self.injectTo(\(name): \(providedValue))")
            }
        } else {
            body.append("let \(name) = \(maker)")
        }
        if let cached = cached {
            body.append("self.\(cached.memberName) = \(name)")
        }
        body.append("return \(name)")
        Logger?.debug("- getter \(name): \(some.fullName(modular: true)) -- cached: \(cached?.memberName ?? "none"); thread-safe: \(cached?.isThreadSafe ?? false)")
        return ["\(accessLevel) var \(name): \(some.fullName(modular: true)) {"] + body.map { "\(config.indent)\($0)" } + ["}"]
    }
    
    func maker(for decl: TypeDeclaration) -> [String]? {
        switch decl.initializer {
        case .none:
            Logger?.debug("- no maker for \(memberName(of: decl)): no initializer found")
            return nil
        case .some(let args):
            var lines: [String] = ["private func \(memberName(of: decl, prefix: "make"))() -> \(decl.fullName(modular: true)) {"]
            let invocationArgs: [String] = args.map {
                let valueName = accessor(of: $0.typeResolver, owner: "self")
                guard let name = $0.name else {
                    return valueName
                }
                return "\(name): \(valueName)"
            }
            var initializerName = "\(decl.name)"
            if let moduleName = decl.moduleName {
                initializerName = "\(moduleName).\(initializerName)"
            }
            lines.append("\(config.indent)return \(initializerName)(\(invocationArgs.joined(separator: ", ")))")
            lines.append("}")
            Logger?.debug("- maker \(memberName(of: decl, prefix: "make"))() -> \(decl.fullName(modular: true)) -- initializer: \(initializerName)(\(invocationArgs.joined(separator: ", ")))")
            return lines
        }
    }
    
    func injector(for decl: TypeDeclaration, accessLevel: String) -> [String]? {
        let memberInjections = decl.memberInjections
        let methodInjections = decl.methodInjections
        guard memberInjections.count > 0 || methodInjections.count > 0 else {
            Logger?.debug("- no injector for \(memberName(of: decl)): no member & method injections")
            return nil
        }
        let varName = memberName(of: decl)
        let typeString: String
        if decl.isReference {
            typeString = decl.set(isOptional: false).fullName(modular: true)
        } else {
            typeString = "inout " + decl.set(isOptional: false).fullName(modular: true)
        }
        var lines = ["\(accessLevel) func injectTo(\(varName): \(typeString)) {"]
        memberInjections.forEach {
            let lvalue = "\(varName).\($0.name)"
            let rvalue = self.accessor(of: $0.typeResolver, owner: "self", isLazy: $0.isLazy)
            lines.append("\(config.indent)\(lvalue) = \(rvalue)")
        }
        methodInjections.forEach {
            let invocation = invoked(varName, isOptional: false, with: $0.methodName, args: $0.args)
            lines.append("\(config.indent)\(invocation)")
        }
        if let handlerName = decl.didInjectHandlerName {
            let invocation = invoked(varName, isOptional: false, with: handlerName, args: [])
            lines.append("\(config.indent)\(invocation)")
        }
        lines.append("}")
        Logger?.debug("- injector to \(varName): \(typeString)")
        return lines
    }

    func accessor<T>(of typeResolver: TypeResolver<T>, owner: String, isLazy: Bool) -> String where T: SomeType {
        let expr = accessor(of: typeResolver, owner: owner)
        if isLazy {
            return "{ [unowned \(owner)] in return \(expr) }"
        }
        return expr
    }
    
    func accessor<T>(of typeResolver: TypeResolver<T>, owner: String) -> String where T: SomeType {
        switch typeResolver {
        case .container:
            return owner
        case .explicit(let some):
            return "\(owner).\(memberName(of: some))"
        case .provided(let usage, _):
            return "\(owner).\(memberName(of: usage))"
        case .bound(let usage, _):
            return "\(owner).\(memberName(of: usage))"
        case .derived(let someContainer, let typeResolver):
            return "\(owner).\(accessor(of: typeResolver, owner: memberName(of: someContainer)))"
        case .external(let someExternal, let kind):
            switch kind {
            case .property(let name):
                return "\(owner).\(memberName(of: someExternal)).\(name)"
            case .method(let name, let args):
                let receiver = "\(owner).\(memberName(of: someExternal))"
                return invoked(receiver, isOptional: false, with: name, args: args)
            }
        }
    }
    
    func invoked(_ receiverName: String, isOptional: Bool, with invocationName: String, args: [FunctionInvocationArgument]) -> String {
        var src = receiverName
        if isOptional {
            src += "?"
        }
        let invocationArgs: [String] = args.map {
            let valueName = self.accessor(of: $0.typeResolver, owner: "self", isLazy: $0.isLazy)
            guard let name = $0.name else {
                return valueName
            }
            return "\(name): \(valueName)"
        }
        return "\(src).\(invocationName)(\(invocationArgs.joined(separator: ", ")))"
    }
}
