GRANT ALL PRIVILEGES ON DATABASE spotify_streaming TO spotify_postgres_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO spotify_postgres_user; 
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO spotify_postgres_user;
-- Via pgAdmin GUI
GRANT ALL ON DATABASE spotify_streaming TO spotify_postgres_user;


DROP table spotify_data;

CREATE TABLE spotify_data (
    id integer GENERATED ALWAYS AS IDENTITY,
    timestamp_column timestamp with time zone,
    platform varchar(100),
    ms_played integer,
    conn_country varchar(2),
    ip_addr varchar(50),
    track_name varchar(300),
    artist_name varchar(300),
    album_name varchar(300),
    spotify_track_uri varchar(50),
    episode_name varchar(150),
    episode_show_name varchar(100),
    spotify_episode_uri varchar(50),
    audiobook_title varchar(100),
    audiobook_uri varchar(50),
    audiobook_chapter_uri varchar(50),
    audiobook_chapter_title varchar(100),
    reason_start varchar(30),
    reason_end varchar(30),
    shuffle BOOLEAN DEFAULT false,
    skipped BOOLEAN DEFAULT false,
    offline BOOLEAN DEFAULT false,
    offline_timestamp timestamp with time zone,
    incognito_mode BOOLEAN DEFAULT false
)




-- Change column
ALTER TABLE spotify_data
ALTER COLUMN artist_name TYPE varchar(300);

-- Change column
ALTER TABLE spotify_data
ALTER COLUMN album_name TYPE varchar(300);

-- Change column
ALTER TABLE spotify_data
ALTER COLUMN track_name TYPE varchar(300);

-- Change column
ALTER TABLE spotify_data
ALTER COLUMN platform TYPE varchar(100);


-- Change column
ALTER TABLE spotify_data
ALTER COLUMN episode_name TYPE varchar(150);


-- Change column for ipv6
ALTER TABLE spotify_data
ALTER COLUMN ip_addr TYPE varchar(50);


-- Create indexes on search-heavy columns
CREATE INDEX artist_name_idx ON spotify_data (artist_name);
CREATE INDEX track_name_idx ON spotify_data (track_name);
CREATE INDEX album_name_idx ON spotify_data (album_name);


SELECT * FROM spotify_data LIMIT 10;

SELECT DISTINCT ip_addr, timestamp_column FROM spotify_data
ORDER BY timestamp_column ASC;


SELECT DISTINCT reason_start, COUNT(reason_start) AS count_reason_start FROM spotify_data
GROUP BY reason_start
ORDER BY count_reason_start DESC

SELECT DISTINCT reason_end, COUNT(reason_end) AS count_reason_end FROM spotify_data
GROUP BY reason_end
ORDER BY count_reason_end DESC


SELECT DISTINCT reason_end FROM spotify_data;

SELECT offline_timestamp from spotify_data WHERE offline_timestamp IS NOT NULL;

-- Count records
SELECT COUNT(*) FROM spotify_data

-- Clean and restart 
DELETE FROM spotify_data;

-- Restart with id 
ALTER TABLE spotify_data ALTER COLUMN id RESTART with 1;


SELECT * FROM spotify_data WHERE ms_played > 5000 LIMIT 10;


-- Find top artist by number of streams ordered by year and count
--SELECT artist_name, COUNT(*) AS stream_count
--FROM soptify_data
--WHERE year IN (year1, year2, year3)  -- replace with your specific years
--GROUP BY artist
--ORDER BY record_count DESC, year DESC;

SELECT COUNT(*) FROM spotify_data

-- Find top artist by number of streams ordered by year and count
SELECT artist_name, COUNT(*) AS stream_count, date_part('year', timestamp_column) AS year
FROM spotify_data
-- WHERE year IN (year1, year2, year3)  -- replace with your specific years
GROUP BY artist_name, year
ORDER BY stream_count DESC, year DESC
LIMIT 50;


-- Find top artist by number of streams ordered by year and count

SELECT artist_name,
	COUNT(*) AS stream_count,
	date_part('year', timestamp_column) AS year,
	DENSE_RANK() OVER (PARTITION BY year ORDER BY stream_count)
FROM spotify_data
LIMIT 5;

-- WHERE year IN (year1, year2, year3)  -- replace with your specific years
GROUP BY artist_name, year
ORDER BY stream_count DESC, year DESC
LIMIT 50;


-- https://dba.stackexchange.com/questions/229436/top-10-each-year
WITH artists_stream_count (artist_name, stream_count, year)
AS
(
SELECT artist_name,
	COUNT(*) AS stream_count,
	date_part('year', timestamp_column) AS year
FROM spotify_data
GROUP BY artist_name, year
ORDER BY stream_count DESC
)
SELECT artist_name, 
	   stream_count, 
	   year
FROM artists_stream_count
GROUP BY artist_name, stream_count, year
ORDER BY year, stream_count DESC, artist_name
LIMIT 20;
--RANK() OVER (PARTITION BY YEAR ORDER BY stream_count)
--ORDER BY year, RANK() OVER (PARTITION BY YEAR ORDER BY stream_count);





-- https://dba.stackexchange.com/questions/229436/top-10-each-year
WITH artists_stream_count (artist_name, stream_count, year)
AS
(
SELECT artist_name,
	COUNT(*) AS stream_count,
	date_part('year', timestamp_column) AS year
FROM spotify_data
GROUP BY artist_name, year
ORDER BY stream_count DESC
)
SELECT artist_name, 
	   stream_count, 
	   year,
	   RANK() OVER (PARTITION BY year ORDER BY stream_count DESC) AS ranking
FROM artists_stream_count
GROUP BY artist_name, stream_count, year 
--WHERE RANK() <=10
--ORDER BY year, RANK() OVER (PARTITION BY YEAR ORDER BY stream_count);
ORDER BY year, ranking DESC;


--ORDER BY year, stream_count DESC, artist_name
--RANK() OVER (PARTITION BY YEAR ORDER BY stream_count)
--ORDER BY year, RANK() OVER (PARTITION BY YEAR ORDER BY stream_count);





-- https://dba.stackexchange.com/questions/229436/top-10-each-year
WITH artists_stream_count (artist_name, stream_count, year)
AS
(
SELECT artist_name,
	COUNT(*) AS stream_count,
	date_part('year', timestamp_column) AS year
FROM spotify_data
WHERE ms_played >=5000
GROUP BY artist_name, year
ORDER BY stream_count DESC
),
ranking_table (artist_name, stream_count, year, ranking) AS
(
SELECT artist_name, 
	   stream_count, 
	   year,
	   RANK() OVER (PARTITION BY year ORDER BY stream_count DESC) AS ranking
FROM artists_stream_count
GROUP BY artist_name, stream_count, year 
--WHERE RANK() <=10
--ORDER BY year, RANK() OVER (PARTITION BY YEAR ORDER BY stream_count);
ORDER BY year, ranking DESC
)

SELECT artist_name, 
	   stream_count, 
	   year,
	   ranking
FROM ranking_table
WHERE ranking <=15
ORDER BY year, ranking ASC;


-- Find unique artist listened to, per year
-- Did we not use Spotify for two years?

WITH distinct_artists (artist_name, year)
AS
(
SELECT DISTINCT artist_name, date_part('year', timestamp_column) AS year
FROM spotify_data
)
SELECT COUNT(artist_name), year
FROM distinct_artists
GROUP BY year
ORDER BY year


-- Did we not use Spotify for two years?
SELECT COUNT(*), date_part('year', timestamp_column) AS year 
FROM spotify_data
WHERE ms_played >=5000
--AND year IN (2014, 2015)
GROUP BY year
ORDER BY year ASC


SELECT COUNT(*), date_part('year', timestamp_column) AS year
FROM spotify_data
GROUP BY year
LIMIT 5

SELECT * FROM spotify_data
ORDER BY timestamp_column DESC
LIMIT 5

SELECT COUNT(*) FROM spotify_data;

SELECT DISTINCT artist_name
, date_part('year', timestamp_column) AS year_streamed
, COUNT(timestamp_column) AS ts_count FROM spotify_data 
GROUP BY artist_name, year_streamed
LIMIT 3;


--- Find unique artists streamed per year. Use songs playing longer than 5 seconds.
WITH distinct_artist_year (artist_name, year_streamed, ts_count) 
AS (
	SELECT DISTINCT artist_name
	, date_part('year', timestamp_column) AS year_streamed
	, COUNT(timestamp_column) AS ts_count 
	FROM spotify_data
	WHERE ms_played > 5000
	GROUP BY artist_name, year_streamed
)
SELECT year_streamed, COUNT(*) as unique_artist_count
FROM distinct_artist_year
GROUP BY year_streamed 
ORDER BY year_streamed ASC


-- Estimate how many streams in 2025 based on the current number
SELECT COUNT(*) FROM spotify_data
WHERE  timestamp_column > '2024-12-31'
AND ms_played > 5000;
 

SELECT artist_name, timestamp_column
FROM spotify_data
WHERE artist_name ILIKE '%!!!%'


-- Top Artist For Each Year
-- This seems a variant of our unique artist query but grouping by artist

SELECT DISTINCT artist_name
, date_part('year', timestamp_column) AS year_streamed
, COUNT(timestamp_column) AS ts_count 
FROM spotify_data
WHERE ms_played > 5000
AND
timestamp_column BETWEEN '2021-12-31' AND '2023-01-01'
GROUP BY artist_name, year_streamed
ORDER BY ts_count DESC, year_streamed ASC;

-- Confirm how many times an individual artist was played in particular year
SELECT COUNT(*) FROM spotify_data
WHERE artist_name = '#Relajante'
AND timestamp_column BETWEEN '2021-12-31' AND '2023-01-01'

-- Find the top artists per year by stream count. We use a lateral JOIN to avoid unneccessary row scans.
WITH yearly_counts AS (
    SELECT 
        artist_name, 
        date_part('year', timestamp_column) AS year_streamed, 
        COUNT(*) AS ts_count
    FROM spotify_data
    WHERE ms_played > 5000
    GROUP BY artist_name, year_streamed
)
SELECT y.year_streamed, top_artist.artist_name, top_artist.ts_count
FROM (
    SELECT DISTINCT date_part('year', timestamp_column) AS year_streamed
    FROM spotify_data
) y
LEFT JOIN LATERAL (
    SELECT artist_name, ts_count
    FROM yearly_counts yc
    WHERE yc.year_streamed = y.year_streamed
    ORDER BY ts_count DESC
    LIMIT 5
) top_artist ON true
ORDER BY y.year_streamed ASC;


-- Who is Ron Basejam and what songs did we listen to from him?
SELECT artist_name, track_name FROM spotify_data
WHERE artist_name LIKE '%Basejam%'


--What we listened to in 2015?
SELECT artist_name, track_name, COUNT(track_name) AS stream_count FROM spotify_data
WHERE artist_name IN ('Lars Behrenroth', 'Pelican', 'Prof.Sakamoto', 'Scott Walker', 'Tef Poe')
AND timestamp_column BETWEEN '2014-12-31' AND '2016-01-01'
GROUP BY artist_name, track_name
ORDER BY stream_count DESC


--Milliseconds spent listening to the number 1 artists.
-- 1. Isolate number one artist per year
-- Find the top artist per year by stream count. We use a lateral JOIN to avoid unneccessary row scans.
WITH yearly_counts AS (
    SELECT 
        artist_name, 
        date_part('year', timestamp_column) AS year_streamed, 
        COUNT(*) AS ts_count
    FROM spotify_data
    WHERE ms_played > 5000
    GROUP BY artist_name, year_streamed
)
SELECT y.year_streamed, top_artist.artist_name, top_artist.ts_count
FROM (
    SELECT DISTINCT date_part('year', timestamp_column) AS year_streamed
    FROM spotify_data
) y
LEFT JOIN LATERAL (
    SELECT artist_name, ts_count
    FROM yearly_counts yc
    WHERE yc.year_streamed = y.year_streamed
    ORDER BY ts_count DESC
    LIMIT 1
) top_artist ON true
ORDER BY y.year_streamed ASC;



-- 2. Aggregate all songs associated with that artist (Use ILIKE in case they have collabs)

SELECT DISTINCT date_part('year', timestamp_column) AS year_streamed, artist_name, SUM(ms_played)
FROM spotify_data
WHERE artist_name ILIKE '%Ron Basejam%'
AND date_part('year', timestamp_column) = 2014
GROUP BY year_streamed, artist_name


-- Generated code from notebook.
-- 2014 Ron Basejam

SELECT DISTINCT date_part('year', timestamp_column) AS year_streamed, artist_name, SUM(ms_played) AS total_artist_ms_played
FROM spotify_data
WHERE artist_name ILIKE '%Ron Basejam%'
AND date_part('year', timestamp_column) = 2014
GROUP BY year_streamed, artist_name;

SELECT date_part('year', timestamp_column) AS year, SUM(ms_played) AS total_ms_played
FROM spotify_data
WHERE date_part('year', timestamp_column) = 2014
GROUP BY year
    
-- 2015 Lars Behrenroth

SELECT DISTINCT date_part('year', timestamp_column) AS year_streamed, artist_name, SUM(ms_played) AS total_artist_ms_played
FROM spotify_data
WHERE artist_name ILIKE '%Lars Behrenroth%'
AND date_part('year', timestamp_column) = 2015
GROUP BY year_streamed, artist_name;

SELECT date_part('year', timestamp_column) AS year, SUM(ms_played) AS total_ms_played
FROM spotify_data
WHERE date_part('year', timestamp_column) = 2015
GROUP BY year
    
-- 2017 Brian Eno

SELECT DISTINCT date_part('year', timestamp_column) AS year_streamed, artist_name, SUM(ms_played) AS total_artist_ms_played
FROM spotify_data
WHERE artist_name ILIKE '%Brian Eno%'
AND date_part('year', timestamp_column) = 2017
GROUP BY year_streamed, artist_name;

SELECT date_part('year', timestamp_column) AS year, SUM(ms_played) AS total_ms_played
FROM spotify_data
WHERE date_part('year', timestamp_column) = 2017
GROUP BY year
    
-- 2018 Brian Eno

SELECT DISTINCT date_part('year', timestamp_column) AS year_streamed, artist_name, SUM(ms_played) AS total_artist_ms_played
FROM spotify_data
WHERE artist_name ILIKE '%Brian Eno%'
AND date_part('year', timestamp_column) = 2018
GROUP BY year_streamed, artist_name;

SELECT date_part('year', timestamp_column) AS year, SUM(ms_played) AS total_ms_played
FROM spotify_data
WHERE date_part('year', timestamp_column) = 2018
GROUP BY year
    
-- 2019 Darius

SELECT DISTINCT date_part('year', timestamp_column) AS year_streamed, artist_name, SUM(ms_played) AS total_artist_ms_played
FROM spotify_data
WHERE artist_name ILIKE '%Darius%'
AND date_part('year', timestamp_column) = 2019
GROUP BY year_streamed, artist_name;

SELECT date_part('year', timestamp_column) AS year, SUM(ms_played) AS total_ms_played
FROM spotify_data
WHERE date_part('year', timestamp_column) = 2019
GROUP BY year
    
-- 2020 Dexta Daps

SELECT DISTINCT date_part('year', timestamp_column) AS year_streamed, artist_name, SUM(ms_played) AS total_artist_ms_played
FROM spotify_data
WHERE artist_name ILIKE '%Dexta Daps%'
AND date_part('year', timestamp_column) = 2020
GROUP BY year_streamed, artist_name;

SELECT date_part('year', timestamp_column) AS year, SUM(ms_played) AS total_ms_played
FROM spotify_data
WHERE date_part('year', timestamp_column) = 2020
GROUP BY year
    
-- 2021 StreamBeats by Harris Heller

SELECT DISTINCT date_part('year', timestamp_column) AS year_streamed, artist_name, SUM(ms_played) AS total_artist_ms_played
FROM spotify_data
WHERE artist_name ILIKE '%Harris Heller%'  --Modified to be just "Harry Heller"
AND date_part('year', timestamp_column) = 2021
GROUP BY year_streamed, artist_name;

SELECT date_part('year', timestamp_column) AS year, SUM(ms_played) AS total_ms_played
FROM spotify_data
WHERE date_part('year', timestamp_column) = 2021
GROUP BY year
    
-- 2022 StreamBeats by Harris Heller

SELECT DISTINCT date_part('year', timestamp_column) AS year_streamed, artist_name, SUM(ms_played) AS total_artist_ms_played
FROM spotify_data
WHERE artist_name ILIKE '%Harris Heller%'
AND date_part('year', timestamp_column) = 2022
GROUP BY year_streamed, artist_name;

SELECT date_part('year', timestamp_column) AS year, SUM(ms_played) AS total_ms_played
FROM spotify_data
WHERE date_part('year', timestamp_column) = 2022
GROUP BY year
    
-- 2023 StreamBeats by Harris Heller

SELECT DISTINCT date_part('year', timestamp_column) AS year_streamed, artist_name, SUM(ms_played) AS total_artist_ms_played
FROM spotify_data
WHERE artist_name ILIKE '%StreamBeats by Harris Heller%'
AND date_part('year', timestamp_column) = 2023
GROUP BY year_streamed, artist_name;

SELECT date_part('year', timestamp_column) AS year, SUM(ms_played) AS total_ms_played
FROM spotify_data
WHERE date_part('year', timestamp_column) = 2023
GROUP BY year
    
-- 2024 Green Piccolo

SELECT DISTINCT date_part('year', timestamp_column) AS year_streamed, artist_name, SUM(ms_played) AS total_artist_ms_played
FROM spotify_data
WHERE artist_name ILIKE '%Green Piccolo%'
AND date_part('year', timestamp_column) = 2024
GROUP BY year_streamed, artist_name;

SELECT date_part('year', timestamp_column) AS year, SUM(ms_played) AS total_ms_played
FROM spotify_data
WHERE date_part('year', timestamp_column) = 2024
GROUP BY year
    
-- 2025 Green Piccolo

SELECT DISTINCT date_part('year', timestamp_column) AS year_streamed, artist_name, SUM(ms_played) AS total_artist_ms_played
FROM spotify_data
WHERE artist_name ILIKE '%Green Piccolo%'
AND date_part('year', timestamp_column) = 2025
GROUP BY year_streamed, artist_name;

SELECT date_part('year', timestamp_column) AS year, SUM(ms_played) AS total_ms_played
FROM spotify_data
WHERE date_part('year', timestamp_column) = 2025
GROUP BY year


-- Finding the genres per year
-- We need to create a dedicated artist table and a join table to link it to the spotify_data table

WITH distinct_artist (artist_name) 
AS (
	SELECT DISTINCT artist_name
	FROM spotify_data
)
SELECT COUNT(*) FROM distinct_artist;
 

-- Or avoid CTE entirely?
SELECT COUNT(DISTINCT artist_name) FROM spotify_data;



-- This will give each artist plus how many times seen in the data
SELECT DISTINCT artist_name, COUNT(artist_name) FROM spotify_data
GROUP BY artist_name;


-- See if we can get the ID and the artist at the same time
-- SELECT DISTINCT(id, artist_name), artist_name FROM spotify_data LIMIT 3;

-- We don't need distinct anything
SELECT id, artist_name FROM spotify_data LIMIT 3;

-- Create an artist table: https://www.postgresql.org/docs/current/arrays.html#ARRAYS-DECLARATION
-- Use unique ID
-- Use genres as an array
CREATE TABLE artists (
    id integer GENERATED ALWAYS AS IDENTITY,
	artist_name varchar(300),
	genres text[]
)


GRANT ALL ON TABLE public.artists TO spotify_postgres_user;

-- Create an index on the id column for artists
CREATE INDEX artist_idx ON artists (id);

-- Create an inverted index for data values with multiple component values
CREATE INDEX genres_idx ON artists USING GIN (genres);

-- Test insert 1
INSERT INTO artists (artist_name, genres)
    VALUES ('Brian Eno',
		      ARRAY['ambient', 'art rock', 'krautrock', 'minimalism', 'drone', 'glam rock']);

-- Test insert 2
INSERT INTO artists (artist_name, genres)
    VALUES ('Green Piccolo ',
		      ARRAY['lo-fi beats']);


SELECT * FROM artists LIMIT 10;

-- Search for a genre
-- Can search via index
SELECT artist_name FROM artists WHERE 'lo-fi beats' = ANY (genres);

SELECT artist_name FROM artists WHERE 'lo-fi beats' = ALL (genres);

-- Select unique artist + insert their values into artists table

WITH distinct_artists (artist_name) AS (
	SELECT DISTINCT artist_name 
	FROM spotify_data 
)
INSERT INTO artists (artist_name)
SELECT da.artist_name
FROM distinct_artists AS da
LEFT JOIN artists AS a 
ON da.artist_name = a.artist_name
WHERE a.artist_name IS NULL;



-- Alter the spotify_data and artists table and add a UNIQUE constraint to its `id` column
ALTER TABLE spotify_data ADD CONSTRAINT sd_id_unique PRIMARY KEY (id);
ALTER TABLE artists ADD CONSTRAINT artists_id_unique PRIMARY KEY (id);
-- ALTER TABLE spotify_data DROP CONSTRAINT id_unique;


-- After adding a table constraint to `spotify_data` we create join table between 
-- spotify_data and artists.
-- * Automatically delete related rows based on foreign key in spotify_data table
-- * Create a composite primary key as a natural key
CREATE TABLE sd_artists_join (
	artist_name text,
	sd_id integer REFERENCES spotify_data (id) ON DELETE CASCADE,
	artist_id integer REFERENCES artists (id),
	CONSTRAINT sd_artist_key PRIMARY KEY (sd_id, artist_id)
)


GRANT ALL ON TABLE public.sd_artists_join TO spotify_postgres_user;

DROP TABLE sd_artist_join;

-- Create indexes on sd_artists_join
CREATE INDEX sd_artists_join_name_idx ON sd_artists_join (artist_name);
CREATE INDEX sd_artists_join_sd_idx ON sd_artists_join (sd_id);
CREATE INDEX sd_artists_join_artist_idx ON sd_artists_join (artist_id);


-- Test query for data we want to insert into join table.
SELECT sd.artist_name, sd.id AS spotify_data_id, a.id AS artist_id
FROM spotify_data as SD
LEFT JOIN  artists as A
ON sd.artist_name = a.artist_name
LIMIT 3

-- Populate the sd_artists_join table
INSERT INTO sd_artists_join (artist_name, sd_id, artist_id)
SELECT sd.artist_name, sd.id AS spotify_data_id, a.id AS artist_id
FROM spotify_data as SD
LEFT JOIN  artists as A
ON sd.artist_name = a.artist_name
WHERE a.id IS NOT NULL


SELECT * FROM sd_artists_join
WHERE artist_name = 'Brian Eno'
LIMIT 30;

-- Reset table
DELETE FROM artists;
-- Restart with id 
ALTER TABLE artists ALTER COLUMN id RESTART with 1;

-- Basic Ranking
SELECT artist_name, COUNT(track_name) 
FROM spotify_data
GROUP BY artist_name
LIMIT 5;


SELECT artist_name, track_name, COUNT(track_name) AS track_count
FROM spotify_data
GROUP BY artist_name, track_name
ORDER BY artist_name, track_count DESC
LIMIT 20;


SELECT artist_name, track_name, COUNT(track_name) AS track_count
FROM spotify_data
RANK() OVER (PARTITION BY artist_name ORDER BY COUNT(artist_name)) 
GROUP BY artist_name, track_name
ORDER BY artist_name, track_count DESC
LIMIT 20;

SELECT * FROM artists
--WHERE genres IS NULL
ORDER BY id
LIMIT 5


SELECT * FROM artists
WHERE genres IS NULL
OR genres = '{}'
ORDER BY ID ASC
--AND genres IS NOT NULL
LIMIT 10;

SELECT COUNT(*) FROM artists;

SELECT id FROM artists
ORDER BY id DESC
LIMIT 3

--ORDER BY id
--LIMIT 5

-- Find Phonk

SELECT artist_name
FROM artists
WHERE 'phonk' = ANY (genres)
LIMIT 3;

SELECT (COUNT(*) * 0.25) / 3600 AS total_minutes_api  FROM artists ;


SELECT id, artist_name, genres 
FROM artists 
WHERE artists.genres = '{}'
LIMIT 5

-- Unnest the genres and then count them

SELECT unnest(genres) as genre_unnested 
FROM artists 
--WHERE artists.genres = '{}'
LIMIT 20


SELECT * FROM spotify_data LIMIT 1
SELECT * FROM artists LIMIT 1
SELECT * FROM sd_artists_join LIMIT 1

-- First try with multiple joins
SELECT a.artist_name, sd.timestamp_column, a.genres 
FROM artists AS a
LEFT JOIN sd_artists_join as sdj
ON a.id = sdj.artist_id
LEFT JOIN spotify_data AS sd
ON sdj.sd_id = sd.id
ORDER BY a.id
LIMIT 3

-- First try with multiple joins
SELECT a.artist_name, sd.timestamp_column, UNNEST(a.genres) AS genre_list 
FROM artists AS a
LEFT JOIN sd_artists_join as sdj
ON a.id = sdj.artist_id
LEFT JOIN spotify_data AS sd
ON sdj.sd_id = sd.id
ORDER BY a.id
LIMIT 20

-- First try with multiple joins
WITH genre_list (genres) AS (
	SELECT UNNEST(a.genres)
	FROM artists AS a
	LEFT JOIN sd_artists_join as sdj
	ON a.id = sdj.artist_id
	LEFT JOIN spotify_data AS sd
	ON sdj.sd_id = sd.id
	--LIMIT 200
)
SELECT genres, COUNT(genres) as genre_count
FROM genre_list
GROUP BY genres
ORDER BY genre_count DESC


-- First try with multiple joins
WITH genre_list (genres, ts) AS (
	--SELECT UNNEST(a.genres), sd.timestamp_column as ts
	SELECT UNNEST(a.genres), date_part('year',sd.timestamp_column) as stream_year
	FROM artists AS a
	LEFT JOIN sd_artists_join as sdj
	ON a.id = sdj.artist_id
	LEFT JOIN spotify_data AS sd
	ON sdj.sd_id = sd.id
	--LIMIT 200
)
SELECT genres, COUNT(genres) as genre_count
FROM genre_list
--RANK() OVER (PARTITION BY stream_year ORDER BY genre_count)
GROUP BY genres
ORDER BY genre_count DESC



-- First try with multiple joins
WITH genre_list (genres, stream_year) AS (
	--SELECT UNNEST(a.genres), sd.timestamp_column as ts
	SELECT UNNEST(a.genres), date_part('year',sd.timestamp_column) as stream_year
	FROM artists AS a
	LEFT JOIN sd_artists_join as sdj
	ON a.id = sdj.artist_id
	LEFT JOIN spotify_data AS sd
	ON sdj.sd_id = sd.id
	--LIMIT 200
)
SELECT genres, COUNT(genres) as play_count, stream_year
FROM genre_list
GROUP BY genres, stream_year
ORDER BY stream_year DESC, play_count DESC

-- Find unique genres played per year 
WITH genre_year_pairs AS (
    SELECT DISTINCT UNNEST(a.genres) AS genre, date_part('year', sd.timestamp_column) AS stream_year
    FROM artists AS a
    JOIN sd_artists_join AS sdj ON a.id = sdj.artist_id
    JOIN spotify_data AS sd ON sdj.sd_id = sd.id
    WHERE 
	a.genres IS NOT NULL AND
	a.genres != '{}' AND
	sd.ms_played > 5000
)
SELECT stream_year, COUNT(*) AS unique_genre_count
FROM genre_year_pairs
GROUP BY stream_year
ORDER BY stream_year DESC;

-- Output how often a genre was played each year
WITH genre_year_cte AS (
    SELECT
        UNNEST(a.genres) AS genre,
        date_part('year', sd.timestamp_column) AS stream_year
    FROM artists a
    JOIN sd_artists_join sdj ON a.id = sdj.artist_id
    JOIN spotify_data sd ON sdj.sd_id = sd.id
    WHERE a.genres IS NOT NULL
	AND a.genres != '{}'
)
SELECT
    stream_year,
    genre,
    COUNT(*) AS genre_play_count
FROM genre_year_cte
GROUP BY stream_year, genre
ORDER BY stream_year DESC, genre_play_count DESC;


-- Obtain the top 15 genres by play count
WITH genre_year_cte AS (
    SELECT
        UNNEST(a.genres) AS genre,
        date_part('year', sd.timestamp_column) AS stream_year
    FROM artists a
    JOIN sd_artists_join sdj ON a.id = sdj.artist_id
    JOIN spotify_data sd ON sdj.sd_id = sd.id
    WHERE a.genres IS NOT NULL
	AND a.genres !='{}'
),
-- Another clause to process the previous CTE. We select all the current
-- columns, generate another column for the play count, and then RANK
-- by the play count, and use the stream_year as the windo
ranked_genres AS(
	SELECT stream_year, genre, COUNT(*) AS genre_play_count,
	RANK() OVER (
		PARTITION BY stream_year ORDER BY COUNT(*) DESC
		) AS genre_rank
	FROM genre_year_cte
	GROUP BY stream_year, genre
)
-- We then just process ranked_genres
SELECT
    stream_year
    ,genre
    ,genre_play_count
	genre_rank
FROM ranked_genres
WHERE genre_rank <= 10
ORDER BY stream_year DESC, genre_play_count DESC;


-- Install tablefunc https://stackoverflow.com/questions/3002499/postgresql-crosstab-query
CREATE EXTENSION IF NOT EXISTS tablefunc;

-- Create a crosstab: Attempt 1. Fails because crosstab requires CTE inlined
WITH genre_year_cte (genre, stream_year) AS (
    SELECT
        UNNEST(a.genres) AS genre,
        date_part('year', sd.timestamp_column) AS stream_year
    FROM artists a
    JOIN sd_artists_join sdj ON a.id = sdj.artist_id
    JOIN spotify_data sd ON sdj.sd_id = sd.id
    WHERE a.genres IS NOT NULL
	AND a.genres != '{}'
), 
genre_year_playcount_cte (stream_year, genre, genre_play_count ) AS(
	SELECT
	    stream_year,
	    genre,
	    COUNT(*) AS genre_play_count
	FROM genre_year_cte
	GROUP BY stream_year, genre
	ORDER BY stream_year DESC, genre_play_count DESC
)
-- SELECT * FROM genre_year_playcount_cte LIMIT 5;
SELECT *
FROM crosstab('SELECT genre,
                      stream_year,
					  genre_play_count
			   FROM genre_year_playcount_cte
			   GROUP BY genre, stream_year
			   ORDER BY genre',

			  'SELECT stream_year
			  FROM genre_year_playcount_cte
			  GROUP BY stream_year
			  ORDER BY stream_year')
AS (genre text,
    "2014" integer,
	"2015" integer,
	"2016" integer,
	"2017" integer,
	"2018" integer,
	"2019" integer,
	"2020" integer,
	"2021" integer,
	"2022" integer,
	"2023" integer,
	"2024" integer,
	"2025" integer
);

-- Create a crosstab: Attempt 2
SELECT *
FROM crosstab('SELECT genre,
                      stream_year,
					  genre_play_count
			   FROM (
						WITH genre_year_cte (genre, stream_year) AS (
						    SELECT
						        UNNEST(a.genres) AS genre,
						        date_part(''year'', sd.timestamp_column) AS stream_year
						    FROM artists a
						    JOIN sd_artists_join sdj ON a.id = sdj.artist_id
						    JOIN spotify_data sd ON sdj.sd_id = sd.id
						    WHERE a.genres IS NOT NULL
							AND a.genres != ''{}''
						), 
						genre_year_playcount_cte (stream_year, genre, genre_play_count ) AS(
							SELECT
							    stream_year,
							    genre,
							    COUNT(*) AS genre_play_count
							FROM genre_year_cte
							GROUP BY stream_year, genre
							ORDER BY stream_year DESC, genre_play_count DESC
						)
						SELECT * FROM genre_year_playcount_cte

			   )
			   GROUP BY genre, stream_year, genre_play_count
			   ORDER BY genre',

			  'SELECT stream_year
			  FROM (
						WITH genre_year_cte (genre, stream_year) AS (
						    SELECT
						        UNNEST(a.genres) AS genre,
						        date_part(''year'', sd.timestamp_column) AS stream_year
						    FROM artists a
						    JOIN sd_artists_join sdj ON a.id = sdj.artist_id
						    JOIN spotify_data sd ON sdj.sd_id = sd.id
						    WHERE a.genres IS NOT NULL
							AND a.genres != ''{}''
						), 
						genre_year_playcount_cte (stream_year, genre, genre_play_count ) AS(
							SELECT
							    stream_year,
							    genre,
							    COUNT(*) AS genre_play_count
							FROM genre_year_cte
							GROUP BY stream_year, genre
							ORDER BY stream_year DESC, genre_play_count DESC
						)
						SELECT * FROM genre_year_playcount_cte




			  )
			  GROUP BY stream_year
			  ORDER BY stream_year')
AS (genre text,
    "2014" integer,
	"2015" integer,
	--"2016" integer,
	"2017" integer,
	"2018" integer,
	"2019" integer,
	"2020" integer,
	"2021" integer,
	"2022" integer,
	"2023" integer,
	"2024" integer,
	"2025" integer
);



date_part('year', sd.timestamp_column) AS stream_year
-- Top Podcasts For Each Year

-- Find overall unique episodes and their count.
SELECT DISTINCT episode_show_name, COUNT(*) AS episode_count 
FROM spotify_data
WHERE episode_name IS NOT NULL
AND episode_show_name IS NOT NULL
GROUP BY episode_show_name
ORDER BY episode_count DESC 

-- Find overall unique episodes and their count, by year
SELECT date_part('year', timestamp_column) AS stream_year, episode_show_name, COUNT(*) AS episode_count 
FROM spotify_data
WHERE episode_name IS NOT NULL
AND episode_show_name IS NOT NULL
GROUP BY stream_year, episode_show_name
ORDER BY stream_year, episode_count DESC 

-- Find the sum of podcast episodes streamed broken down by year.
WITH podcast_ep_data (stream_year, episode_show_name, episode_count) AS (
	SELECT date_part('year', timestamp_column) AS stream_year, episode_show_name, COUNT(*) AS episode_count 
	FROM spotify_data
	WHERE episode_name IS NOT NULL
	AND episode_show_name IS NOT NULL
	GROUP BY stream_year, episode_show_name
	ORDER BY stream_year, episode_count DESC 
)
SELECT stream_year, SUM(episode_count) AS podcasts_streamed
FROM podcast_ep_data
GROUP BY stream_year
ORDER BY stream_year ASC

-- Show all Podcasts and Episodes
SELECT DISTINCT episode_show_name, episode_name 
FROM spotify_data
WHERE episode_name IS NOT NULL
AND episode_show_name IS NOT NULL
GROUP BY episode_show_name , episode_name
ORDER BY episode_show_name ASC, episode_name ASC

-- Fix pg_dump perms issues
GRANT USAGE, SELECT ON SEQUENCE public.artists_id_seq TO spotify_postgres_user;
GRANT USAGE, SELECT ON SEQUENCE public.spotify_data_id_seq TO spotify_postgres_user;
--GRANT USAGE, SELECT ON SEQUENCE public.sd_artists_join_id_seq TO spotify_postgres_user;



-- Output how often a genre was played each year
WITH genre_year_cte AS (
    SELECT
        UNNEST(a.genres) AS genre,
        date_part('year', sd.timestamp_column) AS stream_year
    FROM artists a
    JOIN sd_artists_join sdj ON a.id = sdj.artist_id
    JOIN spotify_data sd ON sdj.sd_id = sd.id
    WHERE a.genres IS NOT NULL
	AND a.genres != '{}'
	AND sd.ms_played > 5000
)
SELECT
    stream_year,
    genre
FROM genre_year_cte
GROUP BY stream_year, genre
ORDER BY stream_year ASC
--ORDER BY stream_year DESC, genre_play_count DESC;


-- Find how many unique genres were played per year 
WITH genre_year_cte AS (
    SELECT
        DISTINCT UNNEST(a.genres) AS genre,
        date_part('year', sd.timestamp_column) AS stream_year
    FROM artists a
    JOIN sd_artists_join sdj ON a.id = sdj.artist_id
    JOIN spotify_data sd ON sdj.sd_id = sd.id
    WHERE a.genres IS NOT NULL
      AND a.genres != '{}'
      AND sd.ms_played > 5000
),
distinct_genres_per_year AS (
    SELECT stream_year, genre
    FROM genre_year_cte
    GROUP BY stream_year, genre
)
SELECT
    stream_year,
    COUNT(*) AS unique_genre_count
FROM distinct_genres_per_year
GROUP BY stream_year
ORDER BY stream_year ASC;

