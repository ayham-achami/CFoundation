fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios build_xcframework

```sh
[bundle exec] fastlane ios build_xcframework
```

Swiftlint code validation

Build  framework CFoundation

Build ios xcframework

### ios lint

```sh
[bundle exec] fastlane ios lint
```

Build playground

Submit error message to slack

Submit success message to slack

Upload file to slack

Abort script

Check code style, create report html file run "bundle exec fastlane prepareMergeRequest"

### ios buildFramework

```sh
[bundle exec] fastlane ios buildFramework
```

Build CFoundation framework, run "bundle exec fastlane buildFramework"

### ios buildPlayground

```sh
[bundle exec] fastlane ios buildPlayground
```

Build CFoundation playground, run "bundle exec fastlane buildFramework"

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
