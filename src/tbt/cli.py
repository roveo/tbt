import click


@click.group()
@click.option(
    "--source-dir",
    required=True,
    type=click.Path(exists=True, file_okay=False),
    help="Path to the catalog directory (contains raw.yml, silver/, gold/).",
)
@click.option(
    "--target-db",
    required=True,
    type=click.Path(),
    help="Path to the DuckDB database file to create or update.",
)
@click.pass_context
def main(ctx: click.Context, source_dir: str, target_db: str) -> None:
    """tbt — tiny bronze transformer.

    Applies a catalog definition to a DuckDB database.

    The catalog directory contains three things:

    \b
      raw.yml          declares CSV files to load into the bronze layer
      silver/*.sql     transformations on top of bronze tables
      gold/*.sql       aggregations and business-logic on top of silver

    Each SQL file is a SELECT that references other tables as
    <layer>.<table> (e.g. FROM silver.customers). tbt resolves the
    dependency order automatically and materialises every table in sequence.

    \b
    Examples
    --------
      $ tbt --source-dir catalog/ --target-db warehouse.db ls
      $ tbt --source-dir catalog/ --target-db warehouse.db run
    """
    ctx.ensure_object(dict)
    ctx.obj["source_dir"] = source_dir
    ctx.obj["target_db"] = target_db


@main.command()
@click.pass_obj
def ls(obj: dict) -> None:
    """List all tables known to the catalog.

    Prints one line per table in the form <layer>.<table>, ordered by
    layer (bronze → silver → gold) and then alphabetically within each layer.

    \b
    Example
    -------
      $ tbt --source-dir catalog/ --target-db warehouse.db ls
      bronze.customers
      bronze.invoices
      silver.customers
      gold.customer_revenue
    """
    print("not implemented")


@main.command()
@click.option(
    "--filter", "filter_",
    default=None,
    metavar="LAYER[.TABLE]",
    help=(
        "Limit execution to a layer (e.g. gold) or a single table "
        "(e.g. gold.customer_revenue). Omit to run everything."
    ),
)
@click.pass_obj
def run(obj: dict, filter_: str | None) -> None:
    """Materialise tables and print their results.

    Without --filter every table is built in dependency order.
    With --filter only the matching tables are built — along with any
    upstream dependencies they require.

    \b
    Examples
    --------
      $ tbt --source-dir catalog/ --target-db warehouse.db run
      $ tbt --source-dir catalog/ --target-db warehouse.db run --filter gold
      $ tbt --source-dir catalog/ --target-db warehouse.db run --filter gold.top_genres
    """
    print(f"not implemented (filter={filter_!r})")
