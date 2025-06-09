# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Development Commands

- **Build**: `nimble build` - Compiles the application
- **Run**: `nimble run` - Starts the server on port 5000
- **Watch mode**: `mise run serve` - Auto-restarts server on file changes using watchexec
- **Format code**: `nimble format` - Formats all source files with nimpretty
- **Clean**: `nimble sweep` - Removes compiled binaries
- **Tests**: `nimble ut` - Runs unit tests using testament
- **Lint**: `nimble lint` - Runs code formatting and static analysis
- **Check**: `nimble check` - Runs static analysis only
- **Strict check**: `nimble strictcheck` - Runs static analysis with all warnings

## Database Commands

- **Initialize DB**: `nimble db_init` - Drops and recreates SQLite database with migrations
- **Show tables**: `nimble db_show` - Lists all database tables
- **Schema info**: `nimble db_schema` - Parses and displays database schema

## Architecture Overview

This is a Nim web application using a layered architecture with dependency injection:

### Core Structure

- **Entry point**: `src/app.nim` - HTTP server setup and main application loop
- **Routing**: `src/app/router/web.nim` - Main web router with pattern matching and HTML responses
- **Context**: `src/context.nim` - Application context and dependency wiring
- **Dependencies**: `src/dependency.nim` - Dependency injection container

### Architecture Patterns

- **Clean Architecture**: Entities, use cases, adapters, and infrastructure layers
- **Repository Pattern**: Abstract data access with on-memory and RDB implementations
- **Feature-based Organization**: Code organized by business features (user, rental, shopping_cart, etc.)

### Key Components

- **Database**: SQLite with custom ORM-like abstractions in `src/shared/db/conn.nim`
- **Migrations**: SQL files in `src/shared/db/ddl/` executed automatically during setup
- **HTML Generation**: Server-side rendered HTML using `htmlgen` module
- **Request Handling**: Custom routing with regex pattern matching and HTTP method overrides

### Testing

- Uses Testament test framework
- Test files located in `tests/` directory
- Run with `nimble ut` command

The application follows a domain-driven design with clear separation between business logic and infrastructure concerns.

## Code Style Guidelines

### Naming Conventions

- **Variables/Functions**: camelCase (e.g., `getUserById`, `userName`)
- **Types/Enums/Constants**: PascalCase (e.g., `UserEntity`, `StatusCode`)
- **Modules/Files**: snake_case (e.g., `user_service.nim`, `db_conn.nim`)

### Formatting Rules

- **Indentation**: 2 spaces (no tabs)
- **Line Length**: Maximum 100 characters
- **Imports**: Sort and group related imports
- **Comments**: Use `##` for documentation comments

### Code Style Files

- `.nimstyle.toml` - Nim-specific style guidelines
- `.editorconfig` - Editor configuration for consistent formatting
- `nim.cfg` - Compiler configuration with style checks and warnings
