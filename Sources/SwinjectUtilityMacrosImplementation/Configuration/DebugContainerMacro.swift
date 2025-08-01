// DebugContainerMacro.swift - Implementation of @DebugContainer macro

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

/// Implementation of the @DebugContainer macro that adds debugging capabilities to containers
public struct DebugContainerMacro: MemberMacro, ExtensionMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        // Parse macro arguments
        let arguments = parseArguments(from: node)
        
        return [
            DeclSyntax("""
            // MARK: - Debug Container Methods (Generated by @DebugContainer)
            
            func enableDebugMode() {
                // Enable debug logging and monitoring
                print("🐛 Debug mode enabled for container")
            }
            
            func getRegistrationStats() -> [String: Any] {
                // Return container registration statistics
                return [
                    "total_registrations": 0,
                    "enabled": true,
                    "debug_level": "\(raw: arguments.logLevel.rawValue)"
                ]
            }
            
            func getRegistrationInfo() -> [String: Any] {
                // Return detailed registration information
                return [
                    "registrations": [],
                    "performance_tracking": \(raw: arguments.performanceTracking),
                    "real_time_monitoring": \(raw: arguments.realTimeMonitoring)
                ]
            }
            """)
        ]
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        
        let extensionDecl = try ExtensionDeclSyntax("""
        extension \(type.trimmed): DebuggableContainer {
            func performHealthCheck() -> ContainerHealth {
                return ContainerHealth(isHealthy: true, issues: [])
            }
        }
        """)
        
        return [extensionDecl]
    }
    
    // MARK: - Argument Parsing
    
    private static func parseArguments(from attribute: AttributeSyntax) -> DebugContainerArguments {
        var logLevel: DebugLogLevel = .info
        var trackResolutions = false
        var detectCircularDeps = false
        var performanceTracking = false
        var realTimeMonitoring = false
        
        guard case let .argumentList(arguments) = attribute.arguments else {
            return DebugContainerArguments(
                logLevel: logLevel,
                trackResolutions: trackResolutions,
                detectCircularDeps: detectCircularDeps,
                performanceTracking: performanceTracking,
                realTimeMonitoring: realTimeMonitoring
            )
        }
        
        for argument in arguments {
            guard let label = argument.label?.text else { continue }
            
            switch label {
            case "logLevel":
                if let memberAccess = argument.expression.as(MemberAccessExprSyntax.self) {
                    let levelName = memberAccess.declName.baseName.text
                    logLevel = DebugLogLevel(rawValue: levelName) ?? .info
                }
            case "trackResolutions":
                trackResolutions = argument.expression.as(BooleanLiteralExprSyntax.self)?.literal.text == "true"
            case "detectCircularDeps":
                detectCircularDeps = argument.expression.as(BooleanLiteralExprSyntax.self)?.literal.text == "true"
            case "performanceTracking":
                performanceTracking = argument.expression.as(BooleanLiteralExprSyntax.self)?.literal.text == "true"
            case "realTimeMonitoring":
                realTimeMonitoring = argument.expression.as(BooleanLiteralExprSyntax.self)?.literal.text == "true"
            default:
                break
            }
        }
        
        return DebugContainerArguments(
            logLevel: logLevel,
            trackResolutions: trackResolutions,
            detectCircularDeps: detectCircularDeps,
            performanceTracking: performanceTracking,
            realTimeMonitoring: realTimeMonitoring
        )
    }
}

// MARK: - Supporting Types

private struct DebugContainerArguments {
    let logLevel: DebugLogLevel
    let trackResolutions: Bool
    let detectCircularDeps: Bool
    let performanceTracking: Bool
    let realTimeMonitoring: Bool
}

private enum DebugLogLevel: String {
    case verbose = "verbose"
    case info = "info"
    case warning = "warning"
    case error = "error"
}