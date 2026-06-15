/**
Enriched track records joined with genre, album, and artist names.
Duration is converted from milliseconds to seconds.

#owner:data-eng
@key:track_id
*/

select
    t.TrackId                                         as track_id,
    t.Name                                            as track_name,
    al.Title                                          as album_title,
    ar.Name                                           as artist_name,
    g.Name                                            as genre,
    t.Composer                                        as composer,
    round(t.Milliseconds / 1000.0, 1)                 as duration_seconds,
    cast(t.UnitPrice as decimal(10, 2))               as unit_price
from bronze.tracks as t
left join bronze.albums  as al on t.AlbumId    = al.AlbumId
left join bronze.artists as ar on al.ArtistId  = ar.ArtistId
left join bronze.genres  as g  on t.GenreId    = g.GenreId
