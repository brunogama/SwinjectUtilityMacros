# API Reference

Comprehensive reference for all SwinjectUtilityMacros APIs, protocols, and utilities.

## Overview

SwinjectUtilityMacros provides a rich set of APIs for dependency injection, aspect-oriented programming, and testing. This reference covers all public APIs with detailed descriptions, parameters, and usage examples.

## Core Protocols

### Injectable

The fundamental protocol that all injectable services conform to.

```swift
public protocol Injectable {
    static func register(in container: Container)
}
```

**Purpose**: Provides the contract for automatic service registration in dependency injection containers.

**Automatic Conformance**: Services marked with `@Injectable` automatically conform to this protocol.

**Generated Implementation**: The `@Injectable` macro generates the `register(in:)` method implementation.

**Usage**:
```swift
@Injectable
class UserService: Injectable {
    // Implementation generated automatically
}

// Registration
UserService.register(in: container)
```

### ServiceFactory

Protocol for factory types that create service instances with runtime parameters.

```swift
public protocol ServiceFactory {
    associatedtype ServiceType
    func makeService() -> ServiceType
}
```

**Purpose**: Enables creation of services that require runtime parameters alongside injected dependencies.

**Generated by**: `@AutoFactory` macro creates concrete implementations.

**Custom Method Names**: Actual factory methods have descriptive names like `makeUserService(userId:)`.

### Interceptor

Protocol for implementing aspect-oriented programming interceptors.

```swift
public protocol Interceptor {
    func intercept<T>(_ execution: () throws -> T) rethrows -> T
}
```

**Purpose**: Enables wrapping method execution with cross-cutting concerns.

**Implementation Pattern**:
```swift
struct LoggingInterceptor: Interceptor {
    func intercept<T>(_ execution: () throws -> T) rethrows -> T {
        print("Method starting...")
        defer { print("Method completed") }
        return try execution()
    }
}
```

### PerformanceTracker

Protocol for performance tracking aspects.

```swift
public protocol PerformanceTracker {
    func track<T>(_ operation: String, execution: () throws -> T) rethrows -> T
}
```

**Purpose**: Records performance metrics for method executions.

**Integration**: Used by `@PerformanceTracked` macro for automatic method timing.

## Core Macros

### @Injectable

Automatically generates dependency injection registration code.

```swift
@attached(member, names: named(register))
@attached(extension, conformances: Injectable)
public macro Injectable(
    scope: ObjectScope = .graph,
    name: String? = nil
) = #externalMacro(module: "SwinjectUtilityMacrosImplementation", type: "InjectableMacro")
```

**Parameters**:
- `scope`: Object lifecycle scope (`.graph`, `.container`, `.transient`, `.weak`)
- `name`: Optional named registration for multiple implementations

**Generated Code**:
- Static `register(in:)` method
- `Injectable` protocol conformance
- Automatic dependency resolution

**Usage Examples**:
```swift
// Basic usage
@Injectable
class UserService {
    init(apiClient: APIClient) { }
}

// With scope
@Injectable(scope: .container)
class DatabaseService {
    init() { }
}

// Named registration
@Injectable(name: "primary")
class PrimaryEmailService: EmailService {
    init() { }
}
```

### @AutoFactory

Generates factory protocols and implementations for services with runtime parameters.

```swift
@attached(peer, names: arbitrary)
public macro AutoFactory(
    async: Bool = false,
    throws: Bool = false,
    name: String? = nil
) = #externalMacro(module: "SwinjectUtilityMacrosImplementation", type: "AutoFactoryMacro")
```

**Parameters**:
- `async`: Whether the factory method should be async
- `throws`: Whether the factory method can throw
- `name`: Custom factory protocol name

**Generated Code**:
- Factory protocol with `make<ServiceName>()` method
- Factory implementation class
- Automatic dependency injection for service dependencies

**Usage Examples**:
```swift
// Basic factory
@AutoFactory
class ReportGenerator {
    init(database: DatabaseService, reportType: String) { }
}
// Generates: ReportGeneratorFactory protocol

// Async factory
@AutoFactory(async: true, throws: true)
class AsyncDataProcessor {
    init(apiClient: APIClient, data: Data) async throws { }
}

// Custom name
@AutoFactory(name: "CustomReportFactory")
class ReportService {
    init(database: DatabaseService, reportId: String) { }
}
```

### @TestContainer

Automatically generates test container setup with mocks.

```swift
@attached(member, names: arbitrary)
public macro TestContainer(
    mockPrefix: String = "Mock",
    scope: ObjectScope = .graph,
    autoMock: Bool = true
) = #externalMacro(module: "SwinjectUtilityMacrosImplementation", type: "TestContainerMacro")
```

**Parameters**:
- `mockPrefix`: Prefix for generated mock class names
- `scope`: Default scope for mock registrations
- `autoMock`: Whether to automatically create mock instances

**Generated Code**:
- `setupTestContainer()` method
- Mock registration methods for each service property
- Automatic mock instance creation

**Usage Examples**:
```swift
// Basic test container
@TestContainer
class UserServiceTests: XCTestCase {
    var apiClient: APIClient!
    var database: DatabaseService!
}

// Custom mock prefix
@TestContainer(mockPrefix: "Stub")
class UserServiceTests: XCTestCase {
    var apiClient: APIClient!
}

// Manual mock control
@TestContainer(autoMock: false)
class UserServiceTests: XCTestCase {
    var apiClient: APIClient!
    
    func setUp() {
        container = setupTestContainer()
        registerAPIClient(mock: CustomMockAPIClient())
    }
}
```

## Configuration Types

### ObjectScope

Enumeration defining object lifecycle scopes.

```swift
public enum ObjectScope {
    case graph      // New instance per object graph (default)
    case container  // Singleton within container
    case transient  // New instance every time
    case weak       // Shared while strong references exist
}
```

**Swinject Integration**: Automatically converts to `Swinject.ObjectScope`.

**Usage Guidelines**:
- `.graph`: Default for most services
- `.container`: Expensive resources (database connections, network clients)
- `.transient`: Stateless services
- `.weak`: Services with potential circular references

### DependencyInfo

Structure containing information about detected dependencies.

```swift
public struct DependencyInfo {
    public let name: String
    public let type: String
    public let isOptional: Bool
    public let defaultValue: String?
    public let scopeHint: ObjectScope?
}
```

**Purpose**: Used internally by macros for dependency analysis and code generation.

**Properties**:
- `name`: Parameter name in initializer
- `type`: Swift type name
- `isOptional`: Whether dependency is optional
- `defaultValue`: Default value if present
- `scopeHint`: Suggested scope for this dependency type

## Container Extensions

### Automatic Registration

```swift
extension Container {
    public func registerGeneratedServices()
    public static func testContainer() -> Container
}
```

**registerGeneratedServices()**:
- Registers all services marked with `@Injectable`
- Called automatically by build plugins
- Ensures correct dependency order

**testContainer()**:
- Creates container with mock implementations
- Used by `@TestContainer` macro
- Provides isolated testing environment

### Service Registration Helpers

```swift
extension Container {
    public func registerService<Service>(
        _ serviceType: Service.Type,
        scope: ObjectScope = .graph,
        name: String? = nil,
        factory: @escaping (Resolver) -> Service
    )
    
    public func registerService<Service>(
        _ serviceType: Service.Type,
        scope: ObjectScope = .graph,
        name: String? = nil,
        factory: @escaping (Resolver) -> Service,
        initCompleted: @escaping (Resolver, Service) -> Void
    )
}
```

**Purpose**: Convenience methods for manual service registration with consistent API.

**Features**:
- Automatic scope conversion
- Optional named registration
- Completion handler support for circular dependencies

## Assembly Integration

### AutoRegisterAssembly

Protocol for assemblies with automatic registration support.

```swift
public protocol AutoRegisterAssembly: Assembly {
    func didCompleteAutoRegistration(in container: Container)
}
```

**Purpose**: Provides hook for custom setup after automatic registration.

**Usage**:
```swift
class AppAssembly: AutoRegisterAssembly {
    func assemble(container: Container) {
        container.registerGeneratedServices()
    }
    
    func didCompleteAutoRegistration(in container: Container) {
        // Custom setup after auto-registration
        container.register(SpecialService.self) { _ in
            SpecialServiceImpl()
        }
    }
}
```

## Error Types

### SwinJectError

Enumeration of errors that can occur during dependency injection operations.

```swift
public enum SwinJectError: Error, LocalizedError {
    case dependencyNotFound(String)
    case circularDependency(String)
    case invalidConfiguration(String)
    case macroExpansionFailed(String)
}
```

**Error Cases**:
- `dependencyNotFound`: Service not registered in container
- `circularDependency`: Circular dependency detected
- `invalidConfiguration`: Invalid macro configuration
- `macroExpansionFailed`: Macro expansion error

**Error Messages**: Provides localized, descriptive error messages with context.

## Advanced Features

### Thread Safety

All generated code includes thread-safe dependency resolution:

```swift
// Generated resolver calls use synchronizedResolve
resolver.synchronizedResolve(ServiceType.self)!
```

### Generic Type Support

Macros handle generic types with proper constraint preservation:

```swift
@Injectable
class Repository<T: Codable> {
    init(database: Database) { }
}
// Generates appropriate registration with generic constraints
```

### Optional Dependency Handling

Automatic detection and handling of optional dependencies:

```swift
@Injectable
class AnalyticsService {
    init(logger: LoggerService?, database: DatabaseService) { }
}
// Generates: logger: resolver.synchronizedResolve(LoggerService.self)  // No force unwrap
```

## Migration Guide

### From Manual Swinject

Replace manual registration with macros:

**Before**:
```swift
container.register(UserService.self) { resolver in
    UserService(
        apiClient: resolver.resolve(APIClient.self)!,
        database: resolver.resolve(DatabaseService.self)!
    )
}
```

**After**:
```swift
@Injectable
class UserService {
    init(apiClient: APIClient, database: DatabaseService) { }
}
```

### Breaking Changes

When upgrading between major versions, refer to the changelog for breaking changes and migration instructions.

## Performance Considerations

### Compile-Time Generation

- All code generation happens at compile time
- Zero runtime overhead for dependency injection
- No reflection or dynamic proxy creation

### Memory Efficiency

- Generated code uses direct method calls
- Minimal memory footprint
- Thread-safe without locks in generated code

### Build Performance

- Incremental compilation support
- Macro expansion caching
- Optimized for large codebases

## Troubleshooting

### Common Issues

**Circular Dependencies**:
```
error: Circular dependency detected: UserService -> OrderService -> UserService
```
Solution: Break cycle with protocols or lazy injection.

**Missing Registrations**:
```
error: Dependency not found: APIClient
```
Solution: Ensure all dependencies are registered or marked with `@Injectable`.

**Runtime Parameters in @Injectable**:
```
warning: Runtime parameter 'userId' detected in @Injectable service
```
Solution: Use `@AutoFactory` for services with runtime parameters.

### Debug Support

Enable verbose macro expansion:
```bash
swift build -Xswiftc -Xfrontend -Xswiftc -debug-generic-signatures
```

### Logging

Built-in logging for debugging:
```swift
#if DEBUG
SwinJectLogger.debug("Registering service: \(serviceName)")
#endif
```

## Best Practices

1. **Use appropriate scopes**: `.graph` for business logic, `.container` for resources
2. **Prefer protocols**: Register protocol types rather than concrete implementations
3. **Test with mocks**: Use `@TestContainer` for comprehensive test coverage
4. **Document dependencies**: Clear parameter names help with automatic classification
5. **Avoid circular dependencies**: Design clean dependency graphs

## Version Compatibility

- **Swift 5.9+**: Required for macro support
- **iOS 15.0+ / macOS 12.0+**: Minimum deployment targets
- **Swinject 2.9.1+**: Compatible dependency injection framework
- **SwiftSyntax 509.0.0+**: Required for macro implementation