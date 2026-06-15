/**
Revenue and sales volume by artist, scoped to genres that appear
in the leaderboard.

#owner:data-eng
@key:artist_name
*/

select
    t.artist_name,
    t.genre,
    count(distinct il.InvoiceLineId)            as units_sold,
    round(sum(il.UnitPrice * il.Quantity), 2)   as total_revenue
from bronze.invoice_lines as il
join silver.tracks        as t  on il.TrackId = t.track_id
join gold.genre_leaderboard as gl on t.genre  = gl.genre
group by t.artist_name, t.genre
order by total_revenue desc
