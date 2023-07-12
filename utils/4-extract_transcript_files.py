import json
import os
import shutil

# Load the json list of episodes for which we want to extract the transcripts
episodes = json.load(open("episodes.json"))

# Create a `transcripts-extracted`` folder
TRANSCRIPTS_FOLDER = "transcripts-extracted"
if not os.path.exists(TRANSCRIPTS_FOLDER):
   os.makedirs(TRANSCRIPTS_FOLDER)

# Go through every episode in the list and download their transcript files in TRANSCRIPTS_FOLDER
for e in episodes:
   show_name = e["show_filename_prefix"]
   episode_filename = e["episode_filename_prefix"]
   show_filename = show_name.split("_")[1]

   # Create path to the VTT file.
   # 1e-08 is the CUE_SECONDS specified in `3-convert_transcripts_to_vtt.py`
   transcript_file_path = "podcasts-transcripts-1e-08-cueseconds/{0}/{1}/{2}/{3}.vtt".format(show_filename[0], show_filename[1].upper(), show_name, episode_filename)
   new_transcript_file_path = "{0}/{1}.vtt".format(TRANSCRIPTS_FOLDER, episode_filename)

   # Make a copy of the transcript
   shutil.copyfile(transcript_file_path, new_transcript_file_path)
