/**
Revenue and track sales volume aggregated by music genre.
Joins invoice lines through tracks to reach genre.

#owner:data-eng
@key:genre
*/

select
    t.genre,
    count(distinct il.InvoiceLineId)            as units_sold,
    count(distinct il.InvoiceId)                as invoices,
    round(sum(il.UnitPrice * il.Quantity), 2)   as total_revenue
from bronze.invoice_lines as il
join silver.tracks as t on il.TrackId = t.track_id
group by t.genre
order by total_revenue desc
