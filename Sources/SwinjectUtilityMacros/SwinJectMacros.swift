// SwinjectUtilityMacros - Advanced Dependency Injection Utilities for Swift
// Copyright © 2025 SwinjectUtilityMacros. All rights reserved.

import Foundation
import Swinject

/// The main SwinjectUtilityMacros module providing macro-powered dependency injection utilities
/// for the Swinject framework.
///
/// This library provides 25+ compile-time macros that dramatically reduce boilerplate code
/// while ensuring type safety and zero runtime overhead.
///
/// ## Core Macros
/// - ``Injectable`` - Automatic service registration
/// - ``AutoFactory`` - Factory protocol generation
/// - ``TestContainer`` - Test mock generation
///
/// ## AOP Macros
/// - ``Interceptor`` - Method interception with hooks
/// - ``PerformanceTracked`` - Execution time monitoring
///
/// ## SwiftUI Integration
/// - ``EnvironmentInject`` - SwiftUI Environment-based DI
/// - ``ViewModelInject`` - ViewModel dependency injection
///
/// ## Usage
/// ```swift
/// @Injectable
/// class UserService {
///     init(apiClient: APIClient, database: Database) {
///         // Implementation
///     }
/// }
///
/// // Generated registration method:
/// UserService.register(in: container)
/// ```
public struct SwinjectUtilityMacros {
    
    /// Library version
    public static let version = "1.0.0"
    
    /// Minimum supported Swift version
    public static let minimumSwiftVersion = "5.9"
    
    /// Minimum supported Swinject version
    public static let minimumSwinjectVersion = "2.9.1"
}

// MARK: - Core Protocols

/// Protocol that all injectable services must conform to.
/// This protocol is automatically added by the @Injectable macro.
public protocol Injectable {
    /// Registers this service type in the provided container
    static func register(in container: Container)
}

/// Protocol for factory types that create service instances
public protocol ServiceFactory {
    associatedtype ServiceType
    func makeService() -> ServiceType
}

/// Protocol for aspect-oriented programming interceptors
public protocol Interceptor {
    /// Intercepts method execution with optional transformation
    func intercept<T>(_ execution: () throws -> T) rethrows -> T
}

/// Protocol for performance tracking aspects
public protocol PerformanceTracker {
    /// Records performance metrics for the given operation
    func track<T>(_ operation: String, execution: () throws -> T) rethrows -> T
}

// MARK: - Container Extensions

extension Container {
    
    /// Registers all services marked with @Injectable
    /// This is typically called by build plugins or manual registration
    public func registerGeneratedServices() {
        // Implementation will be generated by build plugin
        // This is a placeholder for the generated registration code
    }
    
    /// Creates a test container with mock implementations
    /// Used by @TestContainer macro
    public static func testContainer() -> Container {
        let container = Container()
        // Test-specific registrations will be generated here
        return container
    }
}

// MARK: - Error Types

/// Errors that can occur during dependency injection operations
public enum SwinJectError: Error, LocalizedError {
    case dependencyNotFound(String)
    case circularDependency(String)
    case invalidConfiguration(String)
    case macroExpansionFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .dependencyNotFound(let type):
            return "Dependency not found: \(type)"
        case .circularDependency(let cycle):
            return "Circular dependency detected: \(cycle)"
        case .invalidConfiguration(let message):
            return "Invalid configuration: \(message)"
        case .macroExpansionFailed(let message):
            return "Macro expansion failed: \(message)"
        }
    }
}

// MARK: - Logging

/// Internal logging utility for debugging macro-generated code
internal enum SwinJectLogger {
    static func debug(_ message: String, file: String = #file, line: Int = #line) {
        #if DEBUG
        print("[SwinjectUtilityMacros] \(message) (\(file):\(line))")
        #endif
    }
    
    static func error(_ message: String, file: String = #file, line: Int = #line) {
        print("[SwinjectUtilityMacros ERROR] \(message) (\(file):\(line))")
    }
}

// MARK: - Module Exports

// All macro declarations are part of this module and are automatically available
// Individual macro files (Injectable.swift, AutoFactory.swift, Interceptor.swift, etc.)
// are included as part of the SwinjectUtilityMacros target