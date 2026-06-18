# tbt: Tiny Build Tool

`tbt` is a small command-line tool that applies a declarative analytics catalog to a local DuckDB database.

The catalog describes a small warehouse-style pipeline:

- `raw.yml` declares source CSV files that should become `bronze` tables.
- `silver/*.sql` contains cleaned or enriched models built from bronze tables and seed data.
- `gold/*.sql` contains business-facing aggregations built from bronze and silver models.

Your goal is to turn that catalog into materialized DuckDB tables in the correct dependency order.

## Working Style

This is meant to be interactive. Talk through what you see, what you are unsure about, and what tradeoffs you are making as you work. If you see multiple plausible designs, say so. If something is ambiguous, ask.

You should write code. It is fine to use Copilot, coding agents, documentation, or search tools, but you should still be ready to explain the resulting design and code.

There is no expectation that everything must be finished. A clear architecture, useful types, data structures and interfaces, and a thoughtful implementation path are more valuable than rushing to make every command pass. The order you choose to tackle things matters: start with what you think is core, then decide what deserves polish.

This project is intentionally small, but it represents a real-world kind of problem: a catalog may eventually contain many ways to declare tables, dependencies, metadata, and materialization rules. Please do not treat it as a prompt to write one large script with a separate branch for every file or special case.

There is no single expected architecture. What matters is the judgment in the code: which concepts you choose to model, where responsibilities belong, how easy the next feature would be to add, and how clearly errors can be understood. It is completely reasonable to sketch or discuss a design before implementing it, especially if you are deciding between a short-term solution and a more extensible one.

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

## Repository Layout

- `src/tbt/cli.py` contains the Click command-line entry point. The commands are stubbed out.
- `catalog/raw.yml` declares raw source tables and metadata.
- `catalog/silver/` contains SQL models and seed CSV files.
- `catalog/gold/` contains downstream SQL models.
- `fake-s3-bucket/` contains the CSV files referenced by `raw.yml`. Treat it as a local stand-in for external object storage.
- `pyproject.toml` defines the Python package and dependencies.

## Catalog Rules

Use the existing catalog as the source of truth. The intended behavior can be inferred from the files in `catalog/`:

- Raw YAML entries from `raw.yml` become `bronze.<name>` tables loaded from CSV files in `fake-s3-bucket`.
- CSV seed files inside model folders, such as `catalog/silver/country_codes.csv`, should be available to SQL models as tables from the appropriate layer.
- SQL files define models named from their path, for example `catalog/silver/customers.sql` becomes `silver.customers`.
- SQL models may reference other models using qualified names like `bronze.customers`, `silver.tracks`, or `gold.top_genres`.
- SQL comments may contain human-readable descriptions and lightweight metadata such as `#owner:data-eng` or `@key:customer_id`.
- Catalog files may contain mistakes or ambiguous cases. Handle them deliberately rather than assuming the input is always perfect.

## Target Behavior

The CLI already exposes the intended shape:

```bash
tbt --source-dir catalog/ --target-db warehouse.db ls
tbt --source-dir catalog/ --target-db warehouse.db run
tbt --source-dir catalog/ --target-db warehouse.db run --filter gold
tbt --source-dir catalog/ --target-db warehouse.db run --filter gold.top_genres
```

`ls` should list the tables known to the catalog.

`run` should materialize tables into the target DuckDB database.

- Without a filter, `run` should build the catalog in dependency order.
- With a layer filter such as `gold`, `run` should build that layer and the upstream dependencies required by it.
- With a table filter such as `gold.top_genres`, `run` should build that table and the upstream dependencies required by it.

Dependency resolution is core behavior. The tool should not simply apply files alphabetically or by folder. It should infer references between tables and apply each table only after the tables it depends on have been materialized. If the catalog contains missing references, cycles, or other dependency problems, the tool should report them clearly.

## Notes

The sample data is based on a small music store domain. The business logic is intentionally ordinary so the interesting work stays in the catalog engine: parsing, dependency analysis, execution order, error handling, and choosing the right abstractions.
