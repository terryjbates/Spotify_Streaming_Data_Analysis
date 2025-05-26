# Spotify_Streaming_Data_Analysis

![Empty Dash](./images/)
# Executive Summary
* TBD
# Introduction

This analysis will cover my complete Spotify music streaming history up until January 27, 2025. We will explore what artists, songs, and genres were the most listened to, what time of day songs were listened to, how often I explored new artists, and uncovering any interesting trends typifying my musical tastes. We will see if it is possible to generate my "listening persona" based on the data we explore. 

# Methodology
## Summary
* Request extended streaming history data from Spotify. 
* Download and extract streaming history data archive locally after receiving notification of report compilation.
* Extract the archive and peruse dataset to answer the following questions:
    * What does each record represent?
    * What are the key measures?
    * What are the key dimensions?
* Create appropriate database schema to import raw streaming history data into our PostgreSQL database.
* Use SQL queries, Pandas, and other tooling to conduct data cleaning, exploration and analysis processes. 
## Data Extraction
After using the download link provided in our Spotify email, we received a **16.2** MB zip archive; the extracted folder is named `Spotify Extended Streaming History` with this folder being **217** MB in size. The archive contents are as follows:
* **18** `JSON` files capturing our audio listening history. Each file is approximately **12.3** MB in size and is prefixed with `Streaming_History_Audio_` in their respective file names
* **1** `JSON` file capturing video watching history that is **40** KB in size.
* **1** `ReadMeFirst_ExtendedStreamingHistory.pdf` file containing explanations for each technical field within each `JSON` record.  

### Sample JSON Record
```
{'ts': '2014-02-08T08:19:05Z',
 'platform': 'WebPlayer (websocket RFC6455)',
 'ms_played': 345730,
 'conn_country': 'US',
 'ip_addr': 'XXX.XXX.XXX.XXX',
 'master_metadata_track_name': 'Get Closer',
 'master_metadata_album_artist_name': 'Ron Basejam',
 'master_metadata_album_album_name': 'Trax 3lLascivious SummerlSelected by Eric Pajot',
 'spotify_track_uri': 'spotify:track:4qD4HNcdFGihp5Mn8JTgTB',
 'episode_name': None,
 'episode_show_name': None,
 'spotify_episode_uri': None,
 'audiobook_title': None,
 'audiobook_uri': None,
 'audiobook_chapter_uri': None,
 'audiobook_chapter_title': None,
 'reason_start': 'clickrow',
 'reason_end': 'unknown',
 'shuffle': False,
 'skipped': False,
 'offline': False,
 'offline_timestamp': None,
 'incognito_mode': False}
``` 

Most fields are self-explanatory via their naming. We will obscure the IP address deliberately in our final results to prevent data leakage regarding previous listening locations.

### Database Table Creation

We will be using PostgreSQL to load the data, as-is, into a database table. 
```
-- Create table
CREATE TABLE spotify_data (
    id integer GENERATED ALWAYS AS IDENTITY,
    timestamp_column timestamp with time zone,
    platform varchar(100),
    ms_played integer,
    conn_country varchar(2),
    ip_addr varchar(15),
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

-- Create indexes on columns we know will be frequently queried
CREATE INDEX artist_name_idx ON spotify_data (artist_name);
CREATE INDEX track_name_idx ON spotify_data (track_name);
CREATE INDEX album_name_idx ON spotify_data (album_name);

```

# Findings and Analysis

# Recommendations

## Repository Structure
* `data/`: Contains the original CSV files and associated database files used in the analysis.
* `notebooks/`: Jupyter or Quarto notebooks documenting the analysis process.
* `reports/`: Generated reports, including the Final Report and Summary.
* `notebooks/`:
* `reports/Project_Overview_and_Insights.md`: Front-end document with generalized project information.
* `README.md`: This document.

# Appendix
## Spotify Record Technical Fields
ts
:  Timestamp in UTC when the tracked stopped playing

username
: Spotify Username

platform
: Platform used when streaming the track (e.g. Android OS, Google Chromecast)

ms_played
: Number of milliseconds stream was played.

conn_country
: Country code where stream was played.

ip_addr
: IP address logged when stream was played.

master_metadata_track_name
: Name of the track.

master_metadata_album_artist_name
: Name of the artist.

master_metadata_album_album_name
: Name of the album.

spotify_track_uri
: Resource identifier that can used for Desktop client search to locate artist, album, or track.

episode_name
: Name of the podcast.

episode_show_name
: Name of the show of the podcasat.

spotify_episode_uri
: Unique podcast episode identifier that can be used within Desktop client search.

audiobook_title
: Title of audiobook

audiobook_uri
:  Resource identifier that can used for Desktop client search to locate the audiobook 

audiobook_chapter_uri
:  Resource identifier that can used for Desktop client search to locate the audiobook chapter

audiobook_chapter_title
: Name of the audiobook title.

reason_start
: Value telling why the track started (e.g."clickrow", "trackdone").

reason_end
: Value telling why the track ended (e.g."endplay").


shuffle
: Boolean value if shuffle mode used when playing track.

skipped
: Boolean value if use skipped to the next song.

offline
: Boolean value if track played in offline mode.

offline_timestamp
: Timestamp if/when offline mode was used.

incognito_mode
:false