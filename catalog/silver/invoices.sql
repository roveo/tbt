/**
Cleaned invoice records with normalized billing country codes and
parsed invoice date.

#owner:data-eng
@key:invoice_id
*/

select
    i.InvoiceId                                  as invoice_id,
    i.CustomerId                                 as customer_id,
    cast(i.InvoiceDate as date)                  as invoice_date,
    i.BillingAddress                             as billing_address,
    i.BillingCity                                as billing_city,
    i.BillingState                               as billing_state,
    i.BillingCountry                             as billing_country,
    cc.iso2                                      as billing_country_iso2,
    cast(i.Total as decimal(10, 2))              as total
from bronze.invoices as i
left join bronze.country_codes as cc
    on i.BillingCountry = cc.country_name
