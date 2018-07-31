# Saber

[Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection) (DI) / [Inversion of Control](https://en.wikipedia.org/wiki/Inversion_of_control) (IoC) _command line_ tool for Swift based on __code generation__.

_Saber_ requires __no__ frameworks, just parses sources (via [SourceKitten](https://github.com/jpsim/SourceKitten)), finds [annotations](https://github.com/apleshkov/saber/wiki/Annotations) and generates [containers](https://github.com/apleshkov/saber/wiki/Container).



_NOTE_: _Saber_ is currently in active development, so it's more than welcome to test it and [file](https://github.com/apleshkov/saber/issues) a bug/feature request/...

## Documentation

Please, see [wiki](https://github.com/apleshkov/saber/wiki).

## Installation

Building saber on macOS requires Xcode 9.3+ / Swift 4.1 and Swift Package Manager.

## Development

__Xcode__: clone, run `make xcodeproj` and then open a generated `Saber.xcodeproj`. Use `make docker_linux_test` to test on Linux inside a [docker](https://www.docker.com) container.

__Linux__: `make clean`, `make build` and `make test`

### Homebrew

_TODO_

### Make

Clone & run `make install` in the root directory of this project.

Run `make uninstall` to uninstall.

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

### xcodeproj (only on macOS)

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
