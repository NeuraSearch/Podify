import os
import os.path
import json
from datetime import timedelta

# This allows the extraction of words rather than sentences
# If set to a higher value, it will extract snippets of transcript of, for example, every 5 seconds.
CUE_SECONDS = 0.00000001

def convert_seconds_to_timestamp(seconds):
    new_time = str(timedelta(milliseconds=seconds*1000))
    if ('.' not in new_time):
        new_time += '.000000'
    return new_time[:-3]

def load_json_transcript(filename):
    json_file = open(filename)
    json_transcript = json.load(json_file)
    json_file.close()

    return json_transcript

def write_to_vtt(vtt_file, cue_number, current_start_time, end_time, sentence):
    vtt_file.write("\n\n{0}\n{1} --> {2}\n{3}".format(
        cue_number,
        convert_seconds_to_timestamp(current_start_time),
        convert_seconds_to_timestamp(end_time),
        sentence))
    cue_number += 1
    return cue_number

def convert_json_to_vtt(json_transcript, filename):
    # Create directory structure if it does not exist already
    os.makedirs(os.path.dirname(filename), exist_ok=True)

    # Create vtt file
    vtt_file = open(filename, 'w')
    vtt_file.write("WEBVTT")

    # Extract results from json transcript
    json_results = json_transcript['results']

    # Helper variables
    current_start_time = ""
    sentence = ""
    end_time = ""
    cue_number = 1

    # Only fetch the last item in the list since it contains the entire transcript
    length = len(json_results)
    json_words = json_results[length - 1]['alternatives'][0]['words']

    # Extract content and save to vtt file. Each line will correspond to a word/sentence
    for json_word in json_words:
        start_time = float(json_word['startTime'].replace("s", ""))
        end_time = float(json_word['endTime'].replace("s", ""))
        if current_start_time == "":
            current_start_time = start_time

        word = json_word['word']
        sentence = sentence + word + " "
        if (end_time - current_start_time >= CUE_SECONDS):
            cue_number = write_to_vtt(vtt_file, cue_number, current_start_time, end_time, sentence)
            current_start_time = end_time
            sentence = ""

    # Save remaining sentence if the condition of the CUE_SECONDS was not met and we reached the end of the transcript
    if sentence != "":
        cue_number = write_to_vtt(vtt_file, cue_number, current_start_time, end_time, sentence)

    vtt_file.close()

### IMPORTANT: this script requires a `podcasts-transcripts` folder.
# Download the tar.gz transcript files from the Spotify Podcast Dataset: `EN/podcasts-no-audio-13GB/`.
# This will create the `podcasts-transcripts` folder.
# A new folder (podcasts-transcripts-words) will be created, containing the VTT transcripts and at a word-level
for dirpath, dirnames, filenames in os.walk("podcasts-transcripts"):
    for filename in [f for f in filenames if f.endswith(".json")]:
        # Create new filename for the transcript
        new_filename = os.path.join(dirpath, os.path.splitext(filename)[0] + ".vtt")
        new_filename = new_filename.replace("podcasts-transcripts", "podcasts-transcripts-{0}-cueseconds".format(CUE_SECONDS), 1)

        # Generate VTT file
        json_transcript = load_json_transcript(os.path.join(dirpath, filename))
        convert_json_to_vtt(json_transcript, new_filename)
