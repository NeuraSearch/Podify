import json
import requests
import xmltodict

from collections import OrderedDict
from difflib import SequenceMatcher

def extract_rss(rss_link, episode_name, counter):
    try:
        # download rss from `rss_link`
        response = requests.get(rss_link)
        response.raise_for_status()

        try:
            response = xmltodict.parse(response.content)
            # filter out xml information
            response = response["rss"]["channel"]

            # find episode from the episodes list and remove all the other
            # exit if there no "items" in the rss (i.e. episodes)
            if ("item" not in response) or (not episode_name):
                return None

            matched_item = retrieve_match(episode_name, response["item"])
            if matched_item is None:
                return None
            response["item"] = matched_item

            # in `response`, download episodes' image and save them to `images` sub-folder
            update_episode_image_link(response, counter)

            return response
        except xmltodict.expat.ExpatError as e:
            print("ExpatError: ", e)
    except requests.exceptions.HTTPError as e:
        print("Http Error: ", e)
    except requests.exceptions.ConnectionError as e:
        print("Error Connecting: ", e)
    except requests.exceptions.Timeout as e:
        print("Timeout Error: ", e)
    except requests.exceptions.RequestException as e:
        print("General Request Error: ", e)

    return None

def retrieve_match(episode_name, items):
    # find the closest match between currently selected episode and all available ones in the rss
    episode_name = episode_name.replace('"', '')

    best_ratio = 0
    item = None
    if "title" in items:
        title = items["title"]
        # avoid empty titles, that would case exceptions
        if title is not None:
            best_ratio = SequenceMatcher(None, episode_name, items["title"]).ratio()
            item = items
    else:
        best_match_index = 0
        for i, x in enumerate(items):
            title = x["title"]
            # avoid empty titles, that would case exceptions
            if title is not None:
                ratio = SequenceMatcher(None, episode_name, title).ratio()
                if ratio > best_ratio:
                    best_ratio = ratio
                    best_match_index = i
        item = items[best_match_index]

    # check quality of similarity. Only accept good scores (>= 0.9)
    if best_ratio < 0.9:
        return None

    return item

def update_episode_image_link(response, counter):
    # get remote image url
    if "itunes:image" not in response["item"]:
        response["item"]["itunes:image"] = response["itunes:image"]

    itunes_image_val = response["item"]["itunes:image"]

    # occasionally it can happen that `itunes_image_val` is a list of OrderedDict rather than an OrderedDict
    if isinstance(itunes_image_val, list):
        itunes_image_val = itunes_image_val[0]

    # if it's just a string, create OrderedDict so that we keep the same format
    if isinstance(itunes_image_val, str):
        response["item"]["itunes:image"] = OrderedDict([("@href", itunes_image_val)])
        itunes_image_val = response["item"]["itunes:image"]

    # update href reference, to point now to the local image
    # occasionally it can happen that `itunes_image_val` is a list of OrderedDict rather than an OrderedDict
    if isinstance(response["item"]["itunes:image"], list):
        response["item"]["itunes:image"] = response["item"]["itunes:image"][0]

def tsv2json(input_file, output_file):
    arr = []
    file = open(input_file, "r")
    a = file.readline()

    # The first line consist of headings of the record
    # so we will store it in an array and move to
    # next line in input_file.
    titles = [t.strip() for t in a.split("\t")]

    # use a counter, to save progress to file after n iterations
    n = 0
    tot_episodes = 0
    for line in file:
        d = {}
        for t, f in zip(titles, line.split("\t")):
            # Convert each row into dictionary with keys as titles
            d[t] = f.strip()

        # Augment with rss feed information, only if the rss is found. If not, ignore this episode
        # i.e. do not add it to the final list of episodes
        rss_information = extract_rss(d["rss_link"], d["episode_name"], n)

        if rss_information is not None:
            d["rss_information"] = rss_information
            arr.append(d)
            n += 1

        tot_episodes += 1

        if (tot_episodes % 10000) == 0:
            print("Saving progress so far...")
            print("We are at episode: {0}".format(d["episode_name"]))
            save_to_json(output_file, arr)
            tot_episodes = 0

    # We will append all the individual dictionaires into list and dump into file
    print("Final save...")
    print("Total of {0} episodes were saved".format(n))
    save_to_json(output_file, arr)

def save_to_json(output_file, arr):
    with open(output_file, 'w+', encoding='utf-8') as output_file:
        output_file.write(json.dumps(arr, indent=4))

# Convert the `metadata.tsv` file to `episodes.json`
# We go through each episode, download the RSS feed, parse it, and create a json representation.
# During this process, if the RSS feed is not found, the episode is removed from the final list of
# "valid" episodes. This is because Podify requires the metadata contained within the RSS feed.
input_filename = "metadata.tsv"
output_filename = "episodes.json"
tsv2json(input_filename, output_filename)
