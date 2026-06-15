/**
Cleaned customer records with normalized country codes.

Joins the raw customer table against the country_codes seed CSV
to produce 2-letter ISO country codes. Customers without a match
in the seed are kept (country_iso2 will be NULL).

#owner:data-eng
@key:customer_id
*/

select
    c.CustomerId          as customer_id,
    c.FirstName           as first_name,
    c.LastName            as last_name,
    c.Company             as company,
    c.Email               as email,
    c.City                as city,
    c.State               as state,
    c.Country             as country,
    cc.iso2               as country_iso2,
    c.Phone               as phone,
    c.SupportRepId        as support_rep_id
from bronze.customers as c
left join bronze.country_codes as cc
    on c.Country = cc.country_name
