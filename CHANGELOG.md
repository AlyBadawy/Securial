# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added:

- Initial project structure.
- Basic Rails engine setup.
- For development: Setup Rubocop, Overcommit, Rspec
- Add a simple smoke test
- Add a status route with controller
- For development: Configure CI pipelines
- Add `securial` bin script
- For development: Add script to run tests
- For development: Add generators for models, factory bot, scaffold, jbuilder
- Add UUIDv7 as the default database key generator
- Add Custom logger and broadcaster module
- Add tags to logger (request Id, IP address, User agent)
- Separate Log files per environment
- Implement `Securial.configuration` method with underlying classes
- Implement configuration validation for logger settings
- Add helper modules normalization, and regex validations
- Add Configuration and validation for Logging
- Add Configuration and validation for Roles
- Add Configuration and validation for Sessions and Authorization
- Add Configuration and validation for Securial Mailer
- Add Configuration and validation for Password options
- Add Configuration and validation for JSON responses
- Add Configuration and validation for Engine Security
- Scaffold the `Role` model and controller.
- Implement `User` management with scaffolding and validations
- Add RolesHelper
- Add `RoleAssignment` model to assign and revoke roles to users.
- Created a controller to manage `RoleAssignment`
- Add custom Errors for Config validations, and authorization
- Add a security policy
- Add post-install message
- Implement session management with creation, validation, and refresh logic
- Implement Authentication module with creation, token generation, and JWT encoding/decoding
- Enhance Securial controllers and specs with error handling and authorization checks
