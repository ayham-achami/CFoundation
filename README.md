# **CFoundation**

[![Platforms](https://img.shields.io/badge/Platforms-iOS-yellowgreen?style=flat-square)](https://img.shields.io/badge/Platforms-iOS-Green?style=flat-square)
[![Swift 5](https://img.shields.io/badge/Swift-5-orange.svg)](https://swift.org)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)

Библиотека утилит и компонентов для создания iOS приложения

## Требования

- iOS 11+
- Swift 5

## Установка

### Cocoapods

Чтобы интегрировать CFoundation в проект, просто укажите его в своем `Podfile`:

```ruby
pod 'CFoundation'
```

### Swift Package Manager

В XCode добавьте пакет - File> Swift Packages> Add Package Dependency.

```
git@gitlab.com:ios-space/frameworks/cfoundation.git
```

## Компоненты

- [📁 XCTest](#xctest)
  - [📝 XCTSourceLoader](#xctsourceloader)
- [📁 Sources](#sources)
  - [📝 Keychain](#keychain)
  - [📝 Protected](#protected)
  - [📝 CFoundation](#cfoundation)
  - [📝 ReferenceArray](#referencearray)
  - [📝 JailbreakDetector](#jailbreakdetector)
  - [📝 DeviceSpecifications](#devicespecifications)
  - [📁 Logic](#logic)
    - [📝 PhonePatternBuilder](#phonepatternbuilder)
  - [📁 Errors](#📁-Errors)
    - [📝 CameraPermissionsError](#camerapermissionserror)
  - [📁 Queues](#queues)
    - [📝 DelaySearchPerformer](#delaysearchperformer)
  - [📁 Logging](#logging)
    - [📝 Logger](#logger)
  - [📁 Extensions](#extensions)
    - [📝 String](#string)
    - [📝 DispatchQueue](#dispatchqueue)
  - [📁 Localization](#localization)
    - [📝 Localization+String](#localization+string)
  - [📁 Permissions](#permissions)
    - [📝 CameraPermissions](#camerapermissions)
    - [📝 SettingsRedirectable](#settingsredirectable)
  - [📁 TimersSource](#timerssource)
    - [📝 Timer](#timer)
    - [📝 SourceTimer](#sourcetimer)
    - [📝 TimersSource](#timerssource)
  - [📁 BundleResources](#bundleresources)
    - [📝 SourceLoader](#sourceloader)

___

> ### 📁 XCTest

#### XCTSourceLoader

Ответственен за декодирование объектов при написании тестов

> ### 📁 Sources

#### Keychain

Основные объекты Keychain

#### Protected

Содержит различные блокировки (lock) для защиты

#### CFoundation

Содержит основные модели, протоколы, расширения, необходимые для библиотеки `CFoundation`

#### ReferenceArray

Содержит массив ссылок на объекты, все ссылки слабые

#### JailbreakDetector

Проверка на наличие Jailbreak на устройстве

#### DeviceSpecifications

Содержит характеристики устройства, к которым относится:

- Ориентаия устройства: портрет или пейзаж
- Является ли устройство iPad

> ### 📁 Logic

#### PhonePatternBuilder

Создает паттерн регулярного выражения из маски номера телефона

> ### 📁 Errors

#### CameraPermissionsError

Ошибка доступа к камере

> ### 📁 Queues

#### DelaySearchPerformer

Реализует логику поиска с задержкой

> ### 📁 Logging

#### Logger

Объект логирования

> ### 📁 Extensions

#### String

Расширение для строки: проверяет, является ли строка действительным номером телефона

#### DispatchQueue

Расширение для `DispatchQueue`, которое позволяет отложить задачу на выполнение

> ### 📁 Localization

#### Localization+String

Расширение для локализации строк

> ### 📁 Permissions

#### CameraPermissions

Запрашивает разрешение на использование камеры устройства

#### SettingsRedirectable

Открытие настроек приложения

> ### 📁 TimersSource

#### Timer

Объект таймера

#### SourceTimer

Имплементация объекта таймера

#### TimersSource

Объект источника таймеров

> ### 📁 BundleResources

#### SourceLoader

Содержит в себе протокол, описывающий структуру локальных данных, объект, содержащий ошибки, а также расширение к Bundle для локального ресурса и протокол загрузки/декодирования из локального ресурса
