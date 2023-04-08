working_dir=$1
vid=$2
cd $working_dir

# respond to the -h or --help flags if they are anywhere in the command
if [[ "$@" == *"-h"* ]] || [[ "$@" == *"--help"* ]]; then

    printf '%s\n' \
    "Usage: sample_yt.sh <dir to write to> <youtube video url>" \
    "Downloads a youtube video and separates the audio into stems using spleeter." \
    "The stems are written to a subdirectory called splits." \
    "Requires: yt-dlp, docker"
    exit 0
fi

# check if a video url was passed as an argument and exit if it wasn't
if [ -z "$vid" ]; then
    echo "Error: No video url passed as an argument"
    exit 1
fi

# check if docker is running and exit if it isn't
if ! docker info > /dev/null 2>&1; then
    echo "Docker is not running"
    exit 1
fi

title=$(yt-dlp --get-title $vid)
desc=$(yt-dlp --get-description $vid)

title=$(echo "$title" | tr -cd '[:alnum:] ' | tr ' ' '_')

mkdir "$title"
cd "$title"

echo "$title" > "$title.txt"
echo "$desc" >> "$title.txt"

yt-dlp --extract-audio --audio-format wav $vid

mv *.wav "$title".wav

# if we receive an --only-sample flag anywhere in the command we don't run spleeter
if [[ "$@" == *"--only-sample"* ]]; then
    echo "Only sampling, not running spleeter"
    exit 0
fi

docker run -v $working_dir/"$title":/splits \
deezer/spleeter:3.8-5stems separate -o /splits \
-p spleeter:5stems /splits/"$title".wav

open .
