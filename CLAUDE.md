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

## Important Guidelines for Claude

### Library and API Research

**ALWAYS verify library functions and APIs before providing answers:**

1. **Check source code first**: Use tools to read the actual library source code before suggesting functions or methods
2. **Verify function existence**: Never assume a function exists based on other languages or general knowledge
3. **Confirm syntax and usage**: Read the actual implementation to understand correct usage patterns
4. **Provide accurate examples**: Only show examples that work with the verified API

**Process for answering library-related questions:**
1. Read the relevant library source file (e.g., `/home/kazuya/.choosenim/toolchains/nim-2.2.4/lib/pure/collections/sequtils.nim`)
2. Search for the specific function or feature being asked about
3. Confirm the exact function signature and behavior
4. Provide accurate code examples based on the actual API

### Functional Programming Approach

**ALWAYS prefer functional programming patterns when writing code:**

1. **Use high-order functions**: Prefer `mapIt`, `filterIt`, `foldl`, etc. over loops and conditions
2. **Avoid nested control structures**: Replace nested if/for statements with function chains
3. **Prefer pure functions**: Use `func` instead of `proc` when possible (no side effects)
4. **Decompose into small functions**: Break complex logic into small, composable functions
5. **Use immutable data transformations**: Transform data through function pipelines rather than mutation
6. **Chain operations**: Connect multiple transformations using method chaining (`.mapIt().filterIt()`)

**Examples of preferred patterns:**
- `seq.filterIt(condition).mapIt(transform)` instead of nested for/if loops
- Small helper functions combined with `filterIt`/`mapIt` instead of complex inline logic
- `Option` types and `some`/`none` for handling nullable values
- Function composition over imperative control flow

### Naming Conventions for Helper Functions

**Create descriptive, intuitive function names that clearly express their purpose:**

1. **Use action verbs**: `getAtOrDefault`, `parseOrSkip`, `validateAndTransform`
2. **Include the fallback behavior**: Functions that handle edge cases should indicate the fallback in the name
3. **Make intent obvious**: Function names should be self-documenting and explain what they do
4. **Follow patterns**: Use consistent naming patterns across similar functions

**Examples of good helper function names:**
- `getAtOrDefault` - Get element at index or return default value
- `parseOrNone` - Parse value or return None if invalid
- `findAndTransform` - Find element and apply transformation
- `validateThenApply` - Validate input then apply function

### Coding Rules

- コードを書く場合はforとifを組み合わせたネストは2段までになるように書いてください。これをコーディングのルールにしてください。