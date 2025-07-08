# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-07-08

### Changed:

- Securial post install message to include colorized messages

### Security:

- Update dependencies: JWT, Sqlite, Faker, Overcommit

## [1.0.2] - 2025-06-25

### Added:

- Implemented YARD documentation

### Security:

- Update JWT gem

## [1.0.1] - 2025-06-23

### Fixed:

- Running `securial new APP_NAME` would fail for incorrect `admin_role` type.

### Changed:

- Refactor helper modules for improved readability and maintainability.
- Refactor CLI structure by consolidating command handling into a single class.
- Remove deprecated CLI helper methods and integrate functionality directly into the CLI class.
- Enhance configuration validation to ensure proper types and required fields.
- Update tests to reflect changes in CLI structure and configuration.

### Security

- Update development libraries (rubocop, rspec-rails)

## [1.0.0] - 2025-06-18

### Added:

- Initial project structure.
- Basic Rails engine setup.
- _For development_: Setup `Rubocop`, `Overcommit`, `RSpec`
- _For development_: Configure CI pipelines
- _For development_: Add script to run tests
- _For development_: Add generators for models, factory bot, scaffold, JBuilder
- Add a simple smoke test
- Add a status route with controller
- Add `securial` bin script
- Add `UUIDv7` as the default database ID key generator
- Add Custom logger and broadcaster (file and Stdout) module
- Add tags to logger (request Id, IP address, User agent)
- Separate Log files per environment
- Implement `Securial.configuration` method with underlying classes
- Add Configuration and validation for Logging
- Add Configuration and validation for Roles
- Add Configuration and validation for Sessions and Authorization
- Add Configuration and validation for Securial Mailer
- Add Configuration and validation for Password options
- Add Configuration and validation for JSON responses
- Add Configuration and validation for Engine Security
- Add helper modules normalization, and regex validations
- Scaffold the `Role` model and controller.
- Implement `User` management with scaffolding and validations
- Add `RolesHelper`
- Add `RoleAssignment` model to assign and revoke roles to users.
- Created a controller to manage `RoleAssignment`
- Add custom Errors for Config validations, and authorization
- Add a security policy
- Add post-install message
- Implement session management with creation, validation, and refresh logic
- Implement Authentication module with creation, token generation, and JWT encoding/decoding
- Enhance Securial controllers and specs with error handling and authorization checks
- Implement authentication and authorization mechanisms in Securial controllers
- implement authenticate_admin! for actions that require admin/superuser role
- Implement sign-in, sign-out, refresh token, revoke token functionality
- Create a `SecurialMailer` to send notification emails
- Implement forgot password and reset password functionalities
- Add accounts controller
- Templated the engine initializer file. Copied on installation
- Standardized Configuration Signature
- Seed the default Roles and Users
- Add `--help` and `--version` to the `securial` CLI
- Add Keys Transformer
- Always transform request keys (deep transform) to snake_case
- Configurable: transform response keys to either: snake_case, lowerCamelCase, or UpperCamelCase
- Implement request rate limiting using Rack::Attack
- Add Securial's response headers
- Update all dependencies to latest versions
- Add tests for the CLI

---
