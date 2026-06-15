/**
Genres ranked by total revenue, enriched with per-artist breakdown metrics.

#owner:data-eng
@key:genre
*/

with artist_counts as (
    select
        genre,
        count(distinct artist_name) as artist_count
    from gold.artist_revenue
    group by genre
)
select
    tg.genre,
    tg.total_revenue,
    tg.units_sold,
    ac.artist_count,
    round(tg.total_revenue / nullif(ac.artist_count, 0), 2) as revenue_per_artist
from gold.top_genres as tg
left join artist_counts as ac using (genre)
order by tg.total_revenue desc
