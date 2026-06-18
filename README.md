# tbt: Tiny Build Tool

`tbt` is a small command-line tool that applies a declarative analytics catalog to a local DuckDB database.

The catalog describes a simple warehouse-style pipeline:

- `raw.yml` declares source CSV files that should become `bronze` tables.
- `silver/*.sql` contains cleaned or enriched models built from bronze tables and seed data.
- `gold/*.sql` contains business-facing aggregations built from bronze and silver models.

The goal is to turn the catalog into materialized DuckDB tables in a sensible dependency order, with enough structure that the project could grow beyond this toy example.

## Working Style

This is meant to be interactive. Please talk through what you see, what you are unsure about, and what tradeoffs you are making as you work.

You should write code. It is fine to use Copilot, coding agents, documentation, or search tools, but you should still be ready to explain the resulting design and code.

There is no expectation that everything must be finished. A clear architecture, useful types, data structures and interfaces, and a thoughtful implementation path are more valuable than rushing to make every command pass. The order you choose to tackle things matters: start with the core behavior, then decide what deserves polish.

Expect the session to include discussion. If you see multiple plausible designs, say so. If you think a requirement is ambiguous, ask. If you notice that a quick implementation would work for the current files but would become painful as the catalog grows, call that out and decide what tradeoff you want to make.

## Repository Layout

- `src/tbt/cli.py` contains the Click command-line entry point. The commands are stubbed out.
- `catalog/raw.yml` declares raw source tables and metadata.
- `catalog/silver/` contains SQL models and seed CSV files.
- `catalog/gold/` contains downstream SQL models.
- `fake-s3-bucket/` contains the CSV files referenced by `raw.yml`. Treat it as a local stand-in for external object storage.
- `pyproject.toml` defines the Python package and dependencies.

## Commands

The CLI already exposes the intended shape:

```bash
tbt --source-dir catalog/ --target-db warehouse.db ls
tbt --source-dir catalog/ --target-db warehouse.db run
tbt --source-dir catalog/ --target-db warehouse.db run --filter gold
tbt --source-dir catalog/ --target-db warehouse.db run --filter gold.top_genres
```

`ls` should list the tables known to the catalog.

`run` should materialize tables into the target DuckDB database. Without a filter, it should build the catalog in dependency order. With a filter, it should build only the selected layer or table plus the upstream dependencies required to produce it.

## Dependency Resolution

The tool should not simply apply files alphabetically or by folder. It should infer dependencies between tables and apply each table only after the tables it references have been materialized.

For example, a `gold` model may depend on a `silver` model, which may depend on several `bronze` tables. Running that `gold` model should build the required upstream tables first, in the correct order. If the catalog contains missing references, cycles, or other dependency problems, the tool should report them clearly.

## Catalog Semantics

Use the existing catalog as the source of truth. Some useful behavior can be inferred from it:

- Raw YAML entries from `raw.yml` become `bronze.<name>` tables loaded from CSV files in `fake-s3-bucket`.
- CSV seed files inside model folders, such as `catalog/silver/country_codes.csv`, should be available to SQL models as tables from the appropriate layer.
- SQL files define models named from their path, for example `catalog/silver/customers.sql` becomes `silver.customers`.
- SQL models may reference other models using qualified names like `bronze.customers`, `silver.tracks`, or `gold.top_genres`.
- SQL comments may contain human-readable descriptions and lightweight metadata such as `#owner:data-eng` or `@key:customer_id`.
- Catalog files may contain mistakes or ambiguous cases. Handle them deliberately rather than assuming the input is always perfect.

## What To Prioritize

Good first targets are:

1. Parse the catalog into a useful in-memory representation.
2. Discover table names, source files, SQL bodies, metadata, and model dependencies.
3. Implement `ls` with deterministic ordering.
4. Build a dependency graph and detect invalid states such as missing references or cycles.
5. Materialize runnable tables into DuckDB.
6. Add filtering for a layer or a single table, including required upstream dependencies.
7. Improve diagnostics so catalog problems are understandable.

You do not need to follow this exact order if you see a better path. The important part is to make conscious prioritization decisions and explain them.

## Design Expectations

Aim for code that separates concerns clearly.

This project is intentionally small, but it represents a real-world kind of problem: a catalog may eventually contain many ways to declare tables, dependencies, metadata, and materialization rules. Please do not treat it as a prompt to write one large script with a separate branch for every file or special case.

Prefer small, testable pieces over one large script. Keep the design simple, but leave room for obvious extensions such as more source types, richer metadata, or additional materialization strategies.

There is no single expected architecture. What matters is that the code shows judgment: which concepts you choose to model, where responsibilities belong, how easy the next feature would be to add, and how clearly errors can be understood. It is completely reasonable to sketch or discuss a design before implementing it, especially if you are deciding between a short-term solution and a more extensible one.

## Getting Started

Install dependencies with Poetry:

```bash
poetry install
```

Run the CLI through Poetry:

```bash
poetry run tbt --source-dir catalog/ --target-db warehouse.db ls
```

At the start this will print `not implemented`; that is the expected starting point.

## Notes

The sample data is based on a small music store domain. The business logic is intentionally ordinary so the interesting work stays in the catalog engine: parsing, dependency analysis, execution order, error handling, and choosing the right abstractions.
