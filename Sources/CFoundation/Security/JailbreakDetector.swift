//
//  JailbreakDetector.swift
//

import Foundation

/// Объект проверяющий наличие Jailbreak
@frozen public struct JailbreakDetector {
    
    /// Установлен ли Jailbreak
    public var isJailbroken: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return checkFork() ||
        checkExistenceOfSuspiciousFiles() ||
        checkSuspiciousFilesCanBeOpened() ||
        checkRestrictedDirectoriesWriteable()
        #endif
    }
    
    private var suspiciousFiles: [String] {
        [
            "/usr/sbin/frida-server",
            "/etc/apt/sources.list.d/electra.list",
            "/etc/apt/sources.list.d/sileo.sources",
            "/.bootstrapped_electra",
            "/usr/lib/libjailbreak.dylib",
            "/jb/lzma",
            "/.cydia_no_stash",
            "/.installed_unc0ver",
            "/jb/offsets.plist",
            "/usr/share/jailbreak/injectme.plist",
            "/etc/apt/undecimus/undecimus.list",
            "/var/lib/dpkg/info/mobilesubstrate.md5sums",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/jb/jailbreakd.plist",
            "/jb/amfid_payload.dylib",
            "/jb/libjailbreak.dylib",
            "/usr/libexec/cydia/firmware.sh",
            "/var/lib/cydia",
            "/etc/apt",
            "/private/var/lib/apt",
            "/private/var/Users/",
            "/var/log/apt",
            "/Applications/Cydia.app",
            "/private/var/stash",
            "/private/var/lib/apt/",
            "/private/var/lib/cydia",
            "/private/var/cache/apt/",
            "/private/var/log/syslog",
            "/private/var/tmp/cydia.log",
            "/Applications/Icy.app",
            "/Applications/MxTube.app",
            "/Applications/RockApp.app",
            "/Applications/blackra1n.app",
            "/Applications/SBSettings.app",
            "/Applications/FakeCarrier.app",
            "/Applications/WinterBoard.app",
            "/Applications/IntelliScreen.app",
            "/private/var/mobile/Library/SBSettings/Themes",
            "/Library/MobileSubstrate/CydiaSubstrate.dylib",
            "/System/Library/LaunchDaemons/com.ikey.bbot.plist",
            "/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
            "/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
            "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
            "/Applications/Sileo.app",
            "/var/binpack",
            "/Library/PreferenceBundles/LibertyPref.bundle",
            "/Library/PreferenceBundles/ShadowPreferences.bundle",
            "/Library/PreferenceBundles/ABypassPrefs.bundle",
            "/Library/PreferenceBundles/FlyJBPrefs.bundle",
            "/usr/lib/libhooker.dylib",
            "/usr/lib/libsubstitute.dylib",
            "/usr/lib/substrate",
            "/usr/lib/TweakInject",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/usr/libexec/ssh-keysign",
            "/bin/sh",
            "/etc/ssh/sshd_config",
            "/usr/libexec/sftp-server",
            "/usr/bin/ssh"
        ]
    }
    
    private var suspiciousFilesForOpen: [String] {
        [
            "/.installed_unc0ver",
            "/.bootstrapped_electra",
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/etc/apt",
            "/var/log/apt",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/usr/bin/ssh"
        ]
    }
    
    private let fileManager: FileManager
    
    public init(_ fileManager: FileManager = FileManager.default) {
        self.fileManager = fileManager
    }
    
    /// Проверка на наличие подозрительных файлов
    private func checkExistenceOfSuspiciousFiles() -> Bool {
        suspiciousFiles.contains { fileManager.fileExists(atPath: $0) }
    }
    
    /// Проверка на возможность открыть подозрительные файлы
    private func checkSuspiciousFilesCanBeOpened() -> Bool {
        suspiciousFilesForOpen.contains { fileManager.isReadableFile(atPath: $0) }
    }
    
    /// Проверка на возможность сделать запись в ограниченные репозитории
    private func checkRestrictedDirectoriesWriteable() -> Bool {
        let paths = ["/",
                     "/root/",
                     "/private/",
                     "/jb/"]
        for path in paths {
            do {
                try "Check if we can write something into private folder"
                    .write(toFile: path + UUID().uuidString, atomically: true, encoding: String.Encoding.utf8)
                try fileManager.removeItem(atPath: path)
                return true
            } catch {
                return false
            }
        }
        return false
    }
    
    private func checkFork() -> Bool {
        let pointerToFork = UnsafeMutableRawPointer(bitPattern: -2)
        let forkPtr = dlsym(pointerToFork, "fork")
        typealias ForkType = @convention(c) () -> pid_t
        let fork = unsafeBitCast(forkPtr, to: ForkType.self)
        let forkResult = fork()
        
        guard forkResult >= 0 else { return false }
        if forkResult > 0 {
            kill(forkResult, SIGTERM)
        }
        return true
    }
}
