# Contributing

## Repository

```bash
git clone https://github.com/hasanm08/flow_widget.git
cd flow_widget
```

## Local development

Packages are independent and publishable to pub.dev. For local monorepo work,
each package under `packages/` includes a gitignored `pubspec_overrides.yaml`
that maps hosted dependencies back to sibling path packages.

```bash
# Resolve dependencies in a package (overrides apply automatically)
cd packages/flow_widget && dart pub get

# Run the example app (uses path deps to packages/flow_widget)
cd example && flutter pub get && flutter run
```

## Checks

```bash
dart format .
# per package
(cd packages/flow_widget_platform_interface && dart test)
(cd packages/flow_widget && flutter test)
```

## Guidelines

- Follow Effective Dart and the root `analysis_options.yaml`
- Keep platform packages isolated — no cross-imports between `*_android` and `*_ios`
- Add DartDoc on every public API
- Prefer tests that lock channel codecs and API contracts
- Document OS limitations instead of shipping unsupported hacks

## Publishing to pub.dev

Publish federated packages in dependency order (see root README). Each package
must pass `dart pub publish --dry-run` before release. Update `CHANGELOG.md`
and version numbers together across the federation.

## Releases

Semantic versioning. Update `CHANGELOG.md` and package versions together for federated releases.
