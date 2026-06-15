/**
Total revenue and invoice count per customer, enriched with customer details.
Orders by lifetime revenue descending — useful for identifying top spenders.

#owner:data-eng
@key:customer_id
*/

select
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.country,
    c.country_iso2,
    count(i.invoice_id)                     as invoice_count,
    round(sum(i.total), 2)                  as lifetime_revenue
from silver.customers as c
join silver.invoices as i using (customer_id)
group by
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.country,
    c.country_iso2
order by lifetime_revenue desc
