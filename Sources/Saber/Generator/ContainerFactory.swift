//
//  ContainerFactory.swift
//  Saber
//
//  Created by Andrew Pleshkov on 30/05/2018.
//

import Foundation

public class ContainerFactory {

    private let repo: TypeRepository

    private var processingDeclarations: Set<DeclKey> = []

    private var declarationValues: [DeclKey : DeclValue] = [:]
    
    init(repo: TypeRepository) {
        self.repo = repo
    }
}

extension ContainerFactory {

    public static func make(from dataFactory: ParsedDataFactory) throws -> [Container] {
        let data = dataFactory.make()
        let repo = try TypeRepository(parsedData: data)
        let factory = ContainerFactory(repo: repo)
        return try factory.make()
    }

    func make() throws -> [Container] {
        var result: [Container] = []
        for (_, scope) in repo.scopes {
            Logger?.info("Making '\(scope.container.fullName(modular: true))' (scope: '\(scope.name)')...")
            var container = Container(name: scope.container.name, protocolName: scope.container.protocolName)
            container.dependencies = try makeDependencies(for: scope)
            container.externals = try makeContainerExternals(for: scope)
            container.services = try makeServices(for: scope)
            container.isThreadSafe = scope.container.isThreadSafe
            container.imports = scope.container.imports
            result.append(container)
            Logger?.debug("'\(scope.container.fullName(modular: true))' is ready!")
            Logger?.debug("- thread-safe: \(container.isThreadSafe)")
            Logger?.debug("- imports: \(container.imports)")
        }
        return result
    }

    private func makeContainerExternals(for scope: TypeRepository.Scope) throws -> [ContainerExternal] {
        Logger?.info("Making externals...")
        var result: [ContainerExternal] = []
        for key in scope.externals {
            let usage = try makeTypeUsage(from: key, in: scope)
            let external = ContainerExternal(type: usage)
            result.append(external)
            Logger?.debug("External: '\(key)'")
        }
        return result
    }

    private func makeServices(for scope: TypeRepository.Scope) throws -> [Service] {
        Logger?.info("Making services...")
        var result: [Service] = []
        for key in scope.keys {
            let info = try repo.find(by: key)
            let value: DeclValue
            do {
                value = try ensure(info: info, in: scope)
            } catch (error: Throwable.noParsedType(_)) {
                Logger?.debug("Service '\(key)': no declaration found, skipping")
                continue
            }
            let typeResolver = TypeResolver<TypeDeclaration>.explicit(value.declaration)
            let service = Service(
                typeResolver: typeResolver,
                storage: value.isCached ? .cached : .none
            )
            result.append(service)
            Logger?.debug("Service '\(key)' as explicit; cached: \(value.isCached)")
        }
        for (providerKey, data) in scope.providers {
            let typeUsage = try makeTypeUsage(from: data.of, in: scope)
            let typeProvider = try makeTypeProvider(key: providerKey, in: scope)
            let typeResolver = TypeResolver<TypeDeclaration>.provided(typeUsage, by: typeProvider)
            let service = Service(
                typeResolver: typeResolver,
                storage: .none
            )
            result.append(service)
            Logger?.debug("Service '\(typeUsage.fullName(modular: true))' provided by '\(providerKey)'; cached: false")
        }
        for (binderKey, mimicKey) in scope.binders {
            let typeUsage = try makeTypeUsage(from: mimicKey, in: scope)
            let binderInfo = try repo.find(by: binderKey)
            let binderValue = try ensure(info: binderInfo, in: scope)
            let typeResolver = TypeResolver<TypeDeclaration>.bound(typeUsage, to: binderValue.declaration)
            let service = Service(
                typeResolver: typeResolver,
                storage: .none
            )
            result.append(service)
            Logger?.debug("Service '\(typeUsage.fullName(modular: true))' bound to '\(binderKey)'; cached: false")
        }
        return result
    }
    
    private func makeDependencies(for scope: TypeRepository.Scope) throws -> [TypeUsage] {
        Logger?.info("Making dependencies...")
        return try scope.dependencies.map {
            guard let dependency = repo.scopes[$0] else {
                throw Throwable.message("Unknown scope: \($0)")
            }
            let container = dependency.container
            Logger?.debug("Dependency: '\(container.fullName(modular: true))' (scope: '\(dependency.name)')")
            return TypeUsage(
                name: container.name,
                moduleName: container.moduleName
            )
        }
    }
}

extension ContainerFactory {

    private func makeTypeProvider(key providerKey: TypeRepository.Key, in scope: TypeRepository.Scope) throws -> TypeProvider {
        guard let data = scope.providers[providerKey] else {
            throw Throwable.message("Unknown provider: '\(providerKey)' not found")
        }
        let method = data.method
        let providerInfo = try repo.find(by: providerKey)
        return TypeProvider(
            decl: try ensure(info: providerInfo, in: scope).declaration,
            methodName: method.name,
            args: try makeArguments(for: method, in: scope)
        )
    }

    private func makeResolver(for typeUsage: TypeUsage,
                              with repoResolver: TypeRepository.Resolver,
                              in scope: TypeRepository.Scope) throws -> TypeResolver<TypeUsage> {
        switch repoResolver {
        case .container:
            return .container
        case .explicit:
            return .explicit(typeUsage)
        case .provider(let providerKey):
            let provider = try makeTypeProvider(key: providerKey, in: scope)
            return .provided(typeUsage, by: provider)
        case .binder(let binderKey):
            let binderInfo = try repo.find(by: binderKey)
            return .bound(typeUsage, to: try makeTypeUsage(from: binderInfo, in: scope))
        case .external:
            return .external(typeUsage)
        case .derived(let fromName, let fromResolver):
            guard let fromScope = repo.scopes[fromName] else {
                throw Throwable.message("Unknown scope: '\(fromName)'")
            }
            let container = fromScope.container
            let typeResolver = try makeResolver(for: typeUsage, with: fromResolver, in: fromScope)
            return .derived(
                from: TypeUsage(
                    name: container.fullName(modular: false),
                    moduleName: container.moduleName
                ),
                typeResolver: typeResolver
            )
        }
    }

    private func makeResolver(for parsedUsage: ParsedTypeUsage, in scope: TypeRepository.Scope) throws -> TypeResolver<TypeUsage> {
        Logger?.debug("Making type resolver for {\(scope.name)} '\(parsedUsage.fullName)'...")
        guard let info = try repo.find(by: parsedUsage.genericName) else {
            // Container?
            if let parsedContainer = repo.container(by: parsedUsage.name) {
                let repoKey = TypeRepository.Key(name: parsedContainer.name, moduleName: parsedContainer.moduleName)
                Logger?.debug("Finding repo resolver for {\(scope.name)} '\(repoKey)'...")
                guard let repoResolver = repo.resolver(for: repoKey, scopeName: scope.name) else {
                    throw Throwable.message("Unknown resolver for '\(parsedContainer.fullName(modular: true))' (scope: '\(scope.name)')")
                }
                Logger?.debug("Repo resolver for {\(scope.name)} '\(repoKey)': \(repoResolver)")
                let typeUsage = TypeUsage(name: parsedContainer.name, moduleName: parsedContainer.moduleName)
                let typeResolver = try makeResolver(for: typeUsage, with: repoResolver, in: scope)
                Logger?.debug("Type resolver for {\(scope.name)} '\(repoKey)': \(typeResolver)")
                return typeResolver
            }
            throw Throwable.message("Unknown type: '\(parsedUsage.fullName)' (scope: '\(scope.name)')")
        }
        Logger?.debug("Finding repo resolver for {\(scope.name)} '\(info.key)'...")
        guard let repoResolver = repo.resolver(for: info.key, scopeName: scope.name) else {
            throw Throwable.message("Unknown resolver for: '\(parsedUsage.fullName)' (scope: '\(scope.name)')")
        }
        Logger?.debug("Repo resolver for {\(scope.name)} '\(info.key)': \(repoResolver)")
        let typeUsage = try makeTypeUsage(from: info, in: scope)
        let typeResolver = try makeResolver(for: typeUsage, with: repoResolver, in: scope)
        Logger?.debug("Type resolver for {\(scope.name)} '\(info.key)': \(typeResolver)")
        return typeResolver
    }
}

extension ContainerFactory {
    
    private func makeArguments(for method: ParsedMethod, in scope: TypeRepository.Scope) throws -> [FunctionInvocationArgument] {
        return try method.args.map {
            let typeResolver = try makeResolver(for: $0.type, in: scope)
            return FunctionInvocationArgument(name: $0.name, typeResolver: typeResolver, isLazy: $0.isLazy)
        }
    }

    private func makeTypeUsage(from key: TypeRepository.Key, in scope: TypeRepository.Scope) throws -> TypeUsage {
        let info = try repo.find(by: key)
        return try makeTypeUsage(from: info, in: scope)
    }

    private func makeTypeUsage(from info: TypeRepository.Info, in scope: TypeRepository.Scope) throws -> TypeUsage {
        switch info.parsed {
        case .type(_):
            let decl = try ensure(info: info, in: scope)
            var usage = TypeUsage(name: decl.declaration.name, moduleName: info.key.moduleName)
            usage.isOptional = decl.declaration.isOptional
            return usage
        case .usage(let parsedUsage):
            return makeTypeUsage(from: parsedUsage)
        case .alias(let alias):
            return try makeTypeUsage(from: alias)
        }
    }
    
    private func makeTypeUsage(from parsedUsage: ParsedTypeUsage) -> TypeUsage {
        var usage = TypeUsage(name: parsedUsage.name)
        usage.isOptional = parsedUsage.isOptional
        usage.generics = parsedUsage.generics.map {
            return makeTypeUsage(from: $0)
        }
        return usage
    }
    
    private func makeTypeUsage(from parsedAlias: ParsedTypealias) throws -> TypeUsage {
        switch parsedAlias.target {
        case .type(let parsedUsage):
            return TypeUsage(name: parsedAlias.name, isOptional: parsedUsage.isOptional)
        case .raw(let str):
            throw Throwable.message("Unable to create 'TypeUsage' from '\(str)'")
        }
    }
}

extension ContainerFactory {

    private func ensure(info: TypeRepository.Info, in scope: TypeRepository.Scope) throws -> DeclValue {
        let key = DeclKey(scopeName: scope.name, key: info.key)
        guard processingDeclarations.contains(key) == false else {
            throw Throwable.message("Cyclic dependency found: '\(info.key)' is still processing")
        }
        if let value = declarationValues[key] {
            return value
        }
        Logger?.debug("Making '\(info.key)' (scope: '\(scope.name)')...")
        guard case .type(let parsedType) = info.parsed else {
            throw Throwable.noParsedType(for: info)
        }
        processingDeclarations.insert(key)
        defer {
            processingDeclarations.remove(key)
        }
        var decl = TypeDeclaration(name: info.key.name, moduleName: info.key.moduleName)
        decl.isReference = parsedType.isReference
        if info.scopeName == nil {
            Logger?.debug("Don't parse `\(info.key)` as a service: no scope defined")
            let value: DeclValue = (decl, false)
            declarationValues[key] = value
            return value
        }
        let isInjectOnly = parsedType.annotations.contains(.injectOnly)
        if isInjectOnly {
            Logger?.debug("Injection \(info.key) ignores initializer: \(TypeAnnotation.injectOnly) found")
        }
        for property in parsedType.properties {
            guard property.annotations.contains(.inject) else {
                Logger?.debug(
                    "Ignoring \(info.key).\(property.name): no \(MethodAnnotation.inject) annotation, but \(property.annotations)"
                )
                continue
            }
            let injection = MemberInjection(
                name: property.name,
                typeResolver: try makeResolver(for: property.type, in: scope),
                isLazy: property.isLazy
            )
            decl.memberInjections.append(injection)
            Logger?.debug(
                "Injection \(info.key).\(property.name): \(injection.typeResolver)"
                    + " -- annotations: \(property.annotations)"
                    + "; lazy: \(injection.isLazy)"
            )
        }
        var didInjectHandlerName: String? = nil
        var parsedInitializers: [ParsedMethod] = []
        for method in parsedType.methods {
            if method.isInitializer {
                if !isInjectOnly {
                    Logger?.debug(
                        "Injection \(info.key) initializer found: \(method.name)("
                            + method.args.map { $0.description }.joined(separator: ", ")
                            + ") -- annotations: \(method.annotations)"
                    )
                    parsedInitializers.append(method)
                }
                continue
            }
            if didInjectHandlerName == nil && method.annotations.contains(.didInject) {
                didInjectHandlerName = method.name
                Logger?.debug("Injection \(info.key).didInjectHandler: \(method.name)")
                continue
            }
            if method.annotations.contains(.inject) {
                let injection = InstanceMethodInjection(methodName: method.name, args: try makeArguments(for: method, in: scope))
                decl.methodInjections.append(injection)
                Logger?.debug(
                    "Injection \(info.key).\(method.name)("
                        + injection.args.map { $0.description }.joined(separator: ", ")
                        + ") -- annotations: \(method.annotations)"
                )
            } else {
                Logger?.debug(
                    "Ignoring \(info.key).\(method.name)("
                        + method.args.map { $0.description }.joined(separator: ", ")
                        + "): no \(MethodAnnotation.inject) annotation, but \(method.annotations)"
                )
            }
        }
        decl.didInjectHandlerName = didInjectHandlerName
        decl.initializer = try {
            if isInjectOnly {
                Logger?.debug("Injection \(info.key) initializer: none")
                return .none
            }
            guard let initializer = try findInitializer(from: parsedInitializers, for: parsedType) else {
                Logger?.debug("Injection \(info.key) initializer: init() by default")
                return .some(args: [])
            }
            decl.isOptional = initializer.isFailableInitializer
            Logger?.debug(
                "Injection \(info.key) initializer: "
                    + "init"
                    + (initializer.isFailableInitializer ? "?" : "")
                    + "("
                    + initializer.args.map { $0.description }.joined(separator: ", ")
                    + ")"
            )
            return .some(args: try makeArguments(for: initializer, in: scope))
        }()
        let isCached = parsedType.annotations.contains(.cached)
        let value: DeclValue = (decl, isCached)
        declarationValues[key] = value
        Logger?.debug("Injection '\(info.key)' (cached: \(isCached)) is ready!")
        return value
    }

    private func findInitializer(from methods: [ParsedMethod], for parsedType: ParsedType) throws -> ParsedMethod? {
        guard methods.count > 0 else {
            return nil
        }
        if methods.count == 1 {
            return methods[0]
        }
        let injected = methods.filter { $0.annotations.contains(.inject) }
        if injected.count > 1 {
            throw Throwable.message("Unable to find initializer for '\(parsedType.fullName(modular: true))': multiple injected-initializers found")
        }
        guard let initializer = injected.first else {
            throw Throwable.message("Unable to find initializer for '\(parsedType.fullName(modular: true))': \(methods.count) initializers found, but none of them ia annotated as \(MethodAnnotation.inject)")
        }
        return initializer
    }
}


private struct DeclKey: Hashable {

    var scopeName: TypeRepository.ScopeName

    var key: TypeRepository.Key
}

private typealias DeclValue = (declaration: TypeDeclaration, isCached: Bool)
