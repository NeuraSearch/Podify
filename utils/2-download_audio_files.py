import json
import os
import subprocess
import time

# Load the json list of episodes for which we want to extract the transcripts
episodes = json.load(open("episodes.json"))

# Create a `spotify-audio-files` folder
AUDIO_FOLDER = "spotify-audio-files"
if not os.path.exists(AUDIO_FOLDER):
   os.makedirs(AUDIO_FOLDER)

# Go through every episode in the list and download their audio files in AUDIO_FOLDER
for e in episodes:
   show_name = e["show_filename_prefix"]
   episode_filename = e["episode_filename_prefix"]
   show_filename = show_name.split("_")[1]

   # Create rclone command to download from the Spotify Podcast Dataset
   audio_file_path = "trecbox:Spotify-Podcasts/EN/podcasts-audio-only-2TB/podcasts-audio/{0}/{1}/{2}/{3}.ogg".format(show_filename[0], show_filename[1], show_name, episode_filename)
   rclone_audio_command = "rclone copy -P {0} {1}".format(audio_file_path, AUDIO_FOLDER)

   subprocess.Popen(rclone_audio_command.split(" "))
   time.sleep(3)
