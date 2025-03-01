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
* Create appropriate database schema and scripting to import the streaming history into our PostgreSQL database.
* Use SQL queries, Pandas, and other tooling to conduct data cleaning, exploration and analysis processes. 
## Data Extraction
After using the download link provided in our Spotify email, we received a **16.2** MB zip archive; the extracted folder is named `Spotify Extended Streaming History` with this folder being **217** MB in size. The archive contents are as follows:
* 18 `JSON` files capturing our audio listening history. Each file is approximately **12.3** MB in size and is prefixed with `Streaming_History_Audio_` in their respective file names
* 1 `JSON` file capturing video watching history that is **40** KB in size.
* 1 `ReadMeFirst_ExtendedStreamingHistory.pdf` file containing explanations for each technical field within each `JSON` record.  

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