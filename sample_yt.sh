cd /Users/chris/Music/samples
vid=$1

# check if a video url was passed as an argument and exit if it wasn't
if [ -z "$vid" ]; then
    echo "Error: No video url passed as an argument"
    exit 1
fi

# respond to the -h or --help flags
if [ "$vid" = "-h" ] || [ "$vid" = "--help" ]; then

    printf '%s\n' \
    "Usage: sample_yt.sh <youtube video url>" \
    "Downloads a youtube video and separates the audio into stems using spleeter." \
    "The stems are written to a subdirectory called splits."
    exit 0
fi

# check if docker is running and exit if it isn't
if ! docker info > /dev/null 2>&1; then
    echo "Docker is not running"
    exit 1
fi

# get the video title and description
title=$(yt-dlp --get-title $vid)
desc=$(yt-dlp --get-description $vid)

# remove spaces and non alphanumeric chars from the title and replace them with underscores
title=$(echo "$title" | tr -cd '[:alnum:] ' | tr ' ' '_')

# create a subdirectory with the video title
mkdir "$title"
cd "$title"

# write the video title and description to a text file
echo "$title" > "$title.txt"
echo "$desc" >> "$title.txt"

# download the video as a wav file
yt-dlp --extract-audio --audio-format wav $vid

# rename the wav file to the video title
mv *.wav "$title".wav

# use docker and spleeter to separate the audio into stems and write the stems to the subdirectory
docker run -v /Users/chris/Music/samples/"$title":/splits \
deezer/spleeter:3.8-5stems separate -o /splits \
-p spleeter:5stems /splits/"$title".wav

# open the subdirectory in finder
open .
