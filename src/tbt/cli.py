import click


@click.group()
def main() -> None:
    """tbt — tiny bronze transformer.

    Runs a local, file-based layered data warehouse backed by DuckDB.

    The catalog/ directory contains three things:

    \b
      raw.yml          declares CSV files to load into the bronze layer
      silver/*.sql     transformations on top of bronze tables
      gold/*.sql       aggregations and business-logic on top of silver

    Each SQL file is a SELECT that references other tables as
    <layer>.<table> (e.g. FROM silver.customers). tbt resolves the
    dependency order automatically and materialises every table in sequence.
    """


@main.command()
def ls() -> None:
    """List all tables known to the catalog.

    Prints one line per table in the form <layer>.<table>, ordered by
    layer (bronze → silver → gold) and then alphabetically within each layer.

    \b
    Example
    -------
      $ tbt ls
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
def run(filter_: str | None) -> None:
    """Materialise tables and print their results.

    Without --filter every table is built in dependency order.
    With --filter only the matching tables are built — along with any
    upstream dependencies they require.

    \b
    Examples
    --------
      $ tbt run                              # run everything
      $ tbt run --filter gold               # run all gold tables
      $ tbt run --filter gold.top_genres    # run one table
    """
    print(f"not implemented (filter={filter_!r})")
