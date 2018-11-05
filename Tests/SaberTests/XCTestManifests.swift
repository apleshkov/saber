import XCTest

extension AnnParserTests {
    static let __allTests = [
        ("testBasic", testBasic),
        ("testMultilineComments", testMultilineComments),
        ("testNewlines", testNewlines),
    ]
}

extension BasicContainerTests {
    static let __allTests = [
        ("testImports", testImports),
        ("testInheritance", testInheritance),
        ("testInitArguments", testInitArguments),
        ("testName", testName),
        ("testThreadSafe", testThreadSafe),
    ]
}

extension BoundTypeResolverTests {
    static let __allTests = [
        ("testOptional", testOptional),
        ("testValueWithMemberInjections", testValueWithMemberInjections),
    ]
}

extension ContainerAnnTests {
    static let __allTests = [
        ("testDependencies", testDependencies),
        ("testExternals", testExternals),
        ("testImports", testImports),
        ("testName", testName),
        ("testScope", testScope),
        ("testThreadSafe", testThreadSafe),
    ]
}

extension ContainerParserTests {
    static let __allTests = [
        ("test", test),
        ("testNoName", testNoName),
        ("testNonProtocol", testNonProtocol),
        ("testNoScope", testNoScope),
        ("testSimple", testSimple),
    ]
}

extension DataFactoryAccessorTests {
    static let __allTests = [
        ("testBound", testBound),
        ("testContainer", testContainer),
        ("testDependency", testDependency),
        ("testDerivedContainer", testDerivedContainer),
        ("testExplicit", testExplicit),
        ("testExternalFunction", testExternalFunction),
        ("testExternalProperty", testExternalProperty),
        ("testLazy", testLazy),
        ("testMultipleInheritance", testMultipleInheritance),
        ("testProvidedByType", testProvidedByType),
        ("testType", testType),
    ]
}

extension DataFactoryGetterTests {
    static let __allTests = [
        ("testCachedOptionalTypeUsage", testCachedOptionalTypeUsage),
        ("testCachedReferenceInjections", testCachedReferenceInjections),
        ("testCachedValueInjections", testCachedValueInjections),
        ("testOptionalReferenceInjections", testOptionalReferenceInjections),
        ("testOptionalValueInjections", testOptionalValueInjections),
        ("testReferenceInjections", testReferenceInjections),
        ("testReferenceWithoutMemberInjections", testReferenceWithoutMemberInjections),
        ("testThreadSafeCachedReferenceInjections", testThreadSafeCachedReferenceInjections),
        ("testThreadSafeCachedTypeUsage", testThreadSafeCachedTypeUsage),
        ("testThreadSafeCachedValueInjections", testThreadSafeCachedValueInjections),
        ("testValueInjections1", testValueInjections1),
        ("testValueInjections2", testValueInjections2),
        ("testValueWithoutMemberInjections", testValueWithoutMemberInjections),
    ]
}

extension DataFactoryInjectorTests {
    static let __allTests = [
        ("testDidInjectHandler", testDidInjectHandler),
        ("testLazyInjections", testLazyInjections),
        ("testLazyMethodInjections", testLazyMethodInjections),
        ("testMemberAndMethodInjections", testMemberAndMethodInjections),
        ("testMethodInjections", testMethodInjections),
        ("testNoInjections", testNoInjections),
        ("testOptionalReferenceInjections", testOptionalReferenceInjections),
        ("testOptionalValueInjections", testOptionalValueInjections),
        ("testReferenceInjections", testReferenceInjections),
        ("testValueInjections", testValueInjections),
    ]
}

extension DataFactoryInvokedTests {
    static let __allTests = [
        ("testAllNamedArgs", testAllNamedArgs),
        ("testBound", testBound),
        ("testNotAllNamedArgs", testNotAllNamedArgs),
        ("testProvided", testProvided),
        ("testWithoutArgs", testWithoutArgs),
    ]
}

extension DataFactoryMakerTests {
    static let __allTests = [
        ("testAllNamedArgs", testAllNamedArgs),
        ("testNoInitializer", testNoInitializer),
        ("testNotAllNamedArgs", testNotAllNamedArgs),
        ("testOptionalAndNoArgs", testOptionalAndNoArgs),
    ]
}

extension DataFactoryMemberNameTests {
    static let __allTests = [
        ("testCamelCase", testCamelCase),
        ("testGeneric", testGeneric),
        ("testNested", testNested),
        ("testOptionalGeneric", testOptionalGeneric),
        ("testSimple", testSimple),
        ("testTwoGenerics", testTwoGenerics),
    ]
}

extension ExplicitTypeResolverTests {
    static let __allTests = [
        ("testNoInitializer", testNoInitializer),
        ("testValue", testValue),
        ("testValueWithMemberInjections", testValueWithMemberInjections),
    ]
}

extension ExtensionParserTests {
    static let __allTests = [
        ("testClass", testClass),
        ("testEnum", testEnum),
        ("testMembers", testMembers),
        ("testNested", testNested),
        ("testProtocol", testProtocol),
        ("testStruct", testStruct),
    ]
}

extension FactoryBoundTests {
    static let __allTests = [
        ("testSimple", testSimple),
    ]
}

extension FactoryContainerTests {
    static let __allTests = [
        ("testContainerAsDependency", testContainerAsDependency),
        ("testContainerAsDerivedDependency", testContainerAsDerivedDependency),
        ("testCyclicDependencies", testCyclicDependencies),
        ("testImportsAndThreadSafe", testImportsAndThreadSafe),
        ("testSimple", testSimple),
    ]
}

extension FactoryDerivedTests {
    static let __allTests = [
        ("testBound", testBound),
        ("testExplicit", testExplicit),
        ("testExternal", testExternal),
        ("testProvided", testProvided),
    ]
}

extension FactoryExplicitTests {
    static let __allTests = [
        ("testCached", testCached),
        ("testInjections", testInjections),
        ("testInjectOnly", testInjectOnly),
        ("testNested", testNested),
        ("testOptional", testOptional),
    ]
}

extension FactoryExtensionTests {
    static let __allTests = [
        ("testInit", testInit),
        ("testInjectors", testInjectors),
        ("testUnknown", testUnknown),
    ]
}

extension FactoryExternalTests {
    static let __allTests = [
        ("testIgnoring", testIgnoring),
        ("testInvalidCyclicDependency", testInvalidCyclicDependency),
        ("testUsage", testUsage),
    ]
}

extension FactoryGenericTests {
    static let __allTests = [
        ("testAliasedGeneric", testAliasedGeneric),
        ("testGenericArgs", testGenericArgs),
        ("testGenericExternals", testGenericExternals),
        ("testGenericProvider", testGenericProvider),
        ("testKnownGeneric", testKnownGeneric),
    ]
}

extension FactoryInjectionHandlerTests {
    static let __allTests = [
        ("testSimple", testSimple),
    ]
}

extension FactoryLazyTests {
    static let __allTests = [
        ("testInitializer", testInitializer),
        ("testMethodInjections", testMethodInjections),
        ("testPropertyInjections", testPropertyInjections),
    ]
}

extension FactoryLazyTypealiasTests {
    static let __allTests = [
        ("testInitializer", testInitializer),
        ("testMethodInjections", testMethodInjections),
        ("testPropertyInjections", testPropertyInjections),
    ]
}

extension FactoryProvidedTests {
    static let __allTests = [
        ("testBasic", testBasic),
        ("testNested", testNested),
    ]
}

extension FileParserTests {
    static let __allTests = [
        ("testContainer", testContainer),
        ("testModuleName", testModuleName),
        ("testNestedDecls", testNestedDecls),
    ]
}

extension LambdaParserTests {
    static let __allTests = [
        ("testLambda", testLambda),
    ]
}

extension MethodAnnTest {
    static let __allTests = [
        ("testDidInject", testDidInject),
        ("testInject", testInject),
        ("testProvide", testProvide),
    ]
}

extension MethodParserTests {
    static let __allTests = [
        ("testAccessLevel", testAccessLevel),
        ("testAnnotated", testAnnotated),
        ("testArgs", testArgs),
        ("testDefaultArgs", testDefaultArgs),
        ("testFailableInitializer", testFailableInitializer),
        ("testInitializer", testInitializer),
        ("testLambda", testLambda),
        ("testLazy", testLazy),
        ("testLazyTypealias", testLazyTypealias),
        ("testName", testName),
        ("testStatic", testStatic),
        ("testTuple", testTuple),
        ("testVoid", testVoid),
    ]
}

extension ParentContainerTests {
    static let __allTests = [
        ("testMultipleChildContainers", testMultipleChildContainers),
        ("testParentContainerDependencies", testParentContainerDependencies),
    ]
}

extension ParsedDataTests {
    static let __allTests = [
        ("testContainerCollision", testContainerCollision),
    ]
}

extension PropertyAnnTests {
    static let __allTests = [
        ("testInject", testInject),
    ]
}

extension PropertyParserTests {
    static let __allTests = [
        ("testAnnotations", testAnnotations),
        ("testLazy", testLazy),
        ("testLet", testLet),
        ("testStatic", testStatic),
        ("testVar", testVar),
    ]
}

extension ProvidedTypeResolverTests {
    static let __allTests = [
        ("testCachedTypedProvider", testCachedTypedProvider),
        ("testTypedProvider", testTypedProvider),
    ]
}

extension RendererLazyTests {
    static let __allTests = [
        ("testLazy", testLazy),
    ]
}

extension RendererModuleTests {
    static let __allTests = [
        ("testModules", testModules),
    ]
}

extension RendererTests {
    static let __allTests = [
        ("testComplexInitializer", testComplexInitializer),
        ("testEmptyInitializer", testEmptyInitializer),
        ("testGettersMakersInjectors", testGettersMakersInjectors),
        ("testInheritanceAndImports", testInheritanceAndImports),
        ("testStoredProperties", testStoredProperties),
    ]
}

extension SaberTests {
    static let __allTests = [
        ("testConfigAccessLevel", testConfigAccessLevel),
        ("testConfigSpaceIdentation", testConfigSpaceIdentation),
        ("testConfigTabIdentation", testConfigTabIdentation),
        ("testLock", testLock),
    ]
}

extension TypeAnnTests {
    static let __allTests = [
        ("testBound", testBound),
        ("testCached", testCached),
        ("testInjectOnly", testInjectOnly),
        ("testScope", testScope),
    ]
}

extension TypeParserTests {
    static let __allTests = [
        ("testGenericDecl", testGenericDecl),
        ("testNested", testNested),
        ("testSimpleDecl", testSimpleDecl),
        ("testTypeAnnotations", testTypeAnnotations),
    ]
}

extension TypeRepoModuleTests {
    static let __allTests = [
        ("testExternals1", testExternals1),
        ("testExternalsCollision", testExternalsCollision),
        ("testType", testType),
        ("testTypeCollisions", testTypeCollisions),
    ]
}

extension TypeRepoResolverTests {
    static let __allTests = [
        ("testAlias", testAlias),
        ("testBound", testBound),
        ("testContainer", testContainer),
        ("testDerived", testDerived),
        ("testExplicit", testExplicit),
        ("testExternal", testExternal),
        ("testProvided1", testProvided1),
        ("testProvided2", testProvided2),
        ("testProvided3", testProvided3),
        ("testProvided4", testProvided4),
    ]
}

extension TypeUsageParserTests {
    static let __allTests = [
        ("testGenrics", testGenrics),
        ("testNested", testNested),
        ("testOptional", testOptional),
        ("testSimple", testSimple),
        ("testUnwrapped", testUnwrapped),
    ]
}

extension TypealiasParserTests {
    static let __allTests = [
        ("testAnnotations", testAnnotations),
        ("testGeneric", testGeneric),
        ("testLambda", testLambda),
        ("testSimple", testSimple),
        ("testTuple", testTuple),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AnnParserTests.__allTests),
        testCase(BasicContainerTests.__allTests),
        testCase(BoundTypeResolverTests.__allTests),
        testCase(ContainerAnnTests.__allTests),
        testCase(ContainerParserTests.__allTests),
        testCase(DataFactoryAccessorTests.__allTests),
        testCase(DataFactoryGetterTests.__allTests),
        testCase(DataFactoryInjectorTests.__allTests),
        testCase(DataFactoryInvokedTests.__allTests),
        testCase(DataFactoryMakerTests.__allTests),
        testCase(DataFactoryMemberNameTests.__allTests),
        testCase(ExplicitTypeResolverTests.__allTests),
        testCase(ExtensionParserTests.__allTests),
        testCase(FactoryBoundTests.__allTests),
        testCase(FactoryContainerTests.__allTests),
        testCase(FactoryDerivedTests.__allTests),
        testCase(FactoryExplicitTests.__allTests),
        testCase(FactoryExtensionTests.__allTests),
        testCase(FactoryExternalTests.__allTests),
        testCase(FactoryGenericTests.__allTests),
        testCase(FactoryInjectionHandlerTests.__allTests),
        testCase(FactoryLazyTests.__allTests),
        testCase(FactoryLazyTypealiasTests.__allTests),
        testCase(FactoryProvidedTests.__allTests),
        testCase(FileParserTests.__allTests),
        testCase(LambdaParserTests.__allTests),
        testCase(MethodAnnTest.__allTests),
        testCase(MethodParserTests.__allTests),
        testCase(ParentContainerTests.__allTests),
        testCase(ParsedDataTests.__allTests),
        testCase(PropertyAnnTests.__allTests),
        testCase(PropertyParserTests.__allTests),
        testCase(ProvidedTypeResolverTests.__allTests),
        testCase(RendererLazyTests.__allTests),
        testCase(RendererModuleTests.__allTests),
        testCase(RendererTests.__allTests),
        testCase(SaberTests.__allTests),
        testCase(TypeAnnTests.__allTests),
        testCase(TypeParserTests.__allTests),
        testCase(TypeRepoModuleTests.__allTests),
        testCase(TypeRepoResolverTests.__allTests),
        testCase(TypeUsageParserTests.__allTests),
        testCase(TypealiasParserTests.__allTests),
    ]
}
#endif
