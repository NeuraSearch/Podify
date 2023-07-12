# Podify: A Podcast Streaming Platform with Automatic Logging of User Behaviour for Academic Research

Podify is the first podcast streaming service specifically designed for academic research. With high resemblances to existing modern streaming services, and a scalable design to accommodate large-scale user studies, it implements a customisable catalogue search, with manual playlist creation and curation, podcast listening, and explicit and implicit feedback collection mechanisms. With all user interactions automatically logged by the platform and easily exportable in a readable format for subsequent analysis, Podify aims to reduce the overhead researchers face when conducting user studies.

This repository contains the source code for the platform outlined in the Demonstration Paper [Podify: A Podcast Streaming Platform with Automatic Logging of User Behaviour for Academic Research](https://pureportal.strath.ac.uk/en/publications/podify-a-podcast-streaming-platform-with-automatic-logging-of-use), accepted at the _46th International ACM SIGIR Conference on Research and Development in Information Retrieval_ ([SIGIR2023](https://sigir.org/sigir2023/)).

For the YouTube presentation of this platform, please click [here](https://www.youtube.com/watch?v=k9Z5w_KKHr8).

To know more about our research activities at NeuraSearch Laboratory, please follow us on Twitter ([@NeuraSearch](https://twitter.com/NeuraSearch)) and to get notified of future uploads please subscribe to our [YouTube channel](https://www.youtube.com/@neurasearch)!

# Installation

1. [Ruby](https://www.ruby-lang.org/en/documentation/installation/)
    - It is recommended to use a version manager such as [rbenv](https://github.com/rbenv/rbenv)
3. Bundler:
    - `gem install bundler`
4. Ruby on Rails:
    - `cd Podify`
    - `bundle install`
5. [Redis](https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-redis-on-ubuntu-22-04)
6. [Docker](https://docs.docker.com/engine/install/)
7. [FFmpeg](https://ffmpeg.org/download.html)
8. geoip-database
    - It is preinstalled on Heroku
    - `sudo apt-get install geoip-database`
9. Tailwind CSS
    - `cd Podify`
    - `./bin/rails tailwindcss:install`

# Run Podify
In a terminal window, and from the root folder (`cd Podify`), run:
```
./bin/dev
```

Navigate to `localhost:3000` from your local browser. Before interacting with Podify, however, please complete the all the steps outlined below.

## Elastic Search Instance
Run the following command prior to creating and seeding the database.
```
docker run \
    -d \
    --name elasticsearch-podify \
    --publish 9200:9200 \
    --env "discovery.type=single-node" \
    --env "cluster.name=elasticsearch-rails" \
    --env "cluster.routing.allocation.disk.threshold_enabled=false" \
    --rm \
    docker.elastic.co/elasticsearch/elasticsearch-oss:7.6.0
```

# The Database

## Creation and Seeding
Create and seed the PostgreSQL database, as specified in `db/seeds.rb`:
```
rails db:reset
```
In this step, an admin user is also created, with the following credentials:
- Username: *admin@example.com*
- Password: *password*

These credentials can be used to access the admin dashboard, available at: `localhost:3000/admin`

## Amazon Web Services (AWS)
Podify uses AWS S3 Buckets to generate the catalogue as well as downloading and storing the audio, transcript, and image files.

Please create a S3 Bucket and then edit the following credentials. Please make sure to provide the _access_key_id_, _secret_access_key_, _region_, and _bucket_name_ values:
```
EDITOR="code --wait" bin/rails credentials:edit
```

## Data Pre-Processing

Since Podify expects RSS feeds, it does not restrict its usage to only, for example, the [Spotify Podcast Dataset](https://podcastsdataset.byspotify.com/). However, the
RSS feeds originating from the Spotify Podcast Dataset were used for the demonstration paper. Thus, in order to pre-process the data for creation of the catalogue, the following scripts have to be executed:
1. `python3 utils/1-extract_episodes.py`
    - [Requirement]: **metadata.tsv** of the [Spotify Podcast Dataset](https://podcastsdataset.byspotify.com/)
    - This script creates **episodes.json** from _metadata.tsv_. Only the episodes with valid metadata and RSS feed are included in the JSON file. This list of episodes will be the catalogue.
2. `python3 utils/2-download_audio_files.py`
    - [Requirement]: setup [rclone](https://rclone.org/) as documented in the Spotify Podcast Dataset _README.md_ file
    - This script creates a new folder and it downloads the audio files from the Spotify Podcast Dataset for the episodes listed in **episodes.json**
3. `python3 utils/3-convert_transcripts_to_vtt.py`
     - [Requirement]: a folder (_podcasts-transcripts_) that contains all the transcript files of the Spotify Podcast Dataset. The tar.gz files have to be extracted. The resulting _podcasts-transcripts_ folder will be used by this script
     - This script converts the transcripts to a VTT format and to a word-level representation. The transcript will be uploaded during the catalogue creation to be indexed by the Elastic Search instance
4. `python3 utils/4-extract_transcript_files.py`
     - This script, similar to step (2), creates a new folder and it fetches only the transcript files that are listed in **episodes.json**

Whilst Podify is built in Ruby on Rails, these scripts have been provided in Python. This is to ease the researchers' job of customising and adapting these procedures to their own needs.

## Catalogue Creation Procedure

In a terminal window, and from the root folder (`cd Podify`), run [Sidekiq](https://sidekiq.org/):
```
bundle exec sidekiq
```

With Sidekiq operating and ready to accept incoming jobs, the following task will create the catalogue. Please be aware that this process may take some time, depending on the number of episodes that are going to be uploaded onto Podify.
```
rails episodes:seed_episodes bucket_segments_object_key="episodes.json"
```

Once the catalogue is fully created (the pending jobs, if any, can be found in `localhost:3000/admin/sidekiq`), the Sidekiq process can be stopped and the terminal closed. Although user behaviour can be manually downloaded via the admin dashboard, a cron schedule is also implemented to avoid any potential data loss. Please note that this requires a running Sidekiq process.

# Deployment (Heroku)

Install the **Heroku CLI** with the following guide: https://devcenter.heroku.com/articles/heroku-cli

Once the CLI is installed, and you are logged in (`heroku login`), run the following:
```
cd Podify
heroku apps:create --stack=heroku-20 neurasearch-podify
heroku buildpacks:set heroku/nodejs --index 1
heroku buildpacks:set heroku/ruby --index 2
heroku buildpacks:add --index 3 https://github.com/jonathanong/heroku-buildpack-ffmpeg-latest.git
git push heroku main
heroku run rake db:migrate
heroku ps:scale web=1
heroku open
```
