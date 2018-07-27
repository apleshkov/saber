# Saber

Dependency injection (DI) & Inversion of Control (IoC) command line tool for Swift based on code generation.

_Saber_ requires __no__ frameworks, just parses sources (via [SourceKitten](https://github.com/jpsim/SourceKitten)), finds [annotations](wiki/Annotations) and generates [DI-containers](wiki/Container).

## Installation

Building saber on macOS requires Xcode 9.3+ / Swift 4.1 and Swift Package Manager.

### Homebrew

_TODO_

### Make

Clone & run `make install` in the root directory of this project.

## Usage

```
$ saber help
Available commands:

   help        Display general or command-specific help
   sources     Generate containers from sources
   version     Print current version
   xcodeproj   Generate containers from Xcode project
```

### sources

The tool traverses swift-files `--from` __recursively__ and generates container classes to `--out`.

Example: `saber --workDir . --from Sources --out Sources/Saber`

```
$ saber help sources
Generate containers from sources

[--workDir (string)]
	Working directory (optional)

[--from (string)]
	Directory with sources (is relative to --workDir if any)

[--out (string)]
	Output directory (is relative to --workDir if any)

[--config (string)]
	Path to *.yml or YAML text (optional)

[--log (string)]
	Could be 'info' (by default) or 'debug' (optional)
```

### xcodeproj

The tool parses Xcode project at `--path`, traverses enumerated `--targets` and generates container classes to `--out`.

Example: `saber --workDir . --path MyProject.xcodeproj --targets Target1,Target2 --out Sources/Saber`

```
$ saber help xcodeproj
Generate containers from Xcode project

[--workDir (string)]
	Working directory (optional)

[--path (string)]
	Path to *.xcodeproj (is relative to --workDir if any)

[--targets (string)]
	Comma-separated list of project target names

[--out (string)]
	Output directory (is relative to --workDir if any)

[--config (string)]
	Path to *.yml or YAML text (optional)

[--log (string)]
	Could be 'info' (by default) or 'debug' (optional)
```

### Configuration

Provide it via `--config` as text or file:
```
# Access level for generated classes (internal by default)
accessLevel: internal # public, open, ...
# Identation for generated files (4 spaces by default)
indentation:
    type: space # or tab
    size: 4

```

Example configuration: [config.example.yml](config.example.yml)

## License

MIT
