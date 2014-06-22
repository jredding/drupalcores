#!/bin/bash

# Create the in_array function to check if a value exists in an array
# @param $1 mixed  Needle  
# @param $2 array  Haystack
# @return  Success (0) if value exists, Failure (1) otherwise
# Usage: in_array "$needle" "${haystack[@]}"
# See: http://fvue.nl/wiki/Bash:_Check_if_array_element_exists
in_array() {
    local hay needle=$1
    shift
    for hay; do
        [[ $hay == $needle ]] && return 0
    done
    return 1
}

# Define the available versions of Drupal
versions=('3.0.x' '4.0.x' '4.1.x' '4.5.x' '4.6.x' '4.7.x' '5.x' '6.x' '7.x' '8.x' '9.x');

# Define default version if no or bad @param given
default_version='8.x'

# Check to ensure argument is within the array, is so use it, otherwise use default
in_array $1 "${versions[@]}" && version=$1 || version='8.x' 

echo $version


echo "Start update of analytics for Drupal version $version"

# Check for existence of an existing git repository
if [ ! -d "./drupal_$version" ]; then
  git clone --branch $version http://git.drupal.org/project/drupal.git drupal_$version
else
  # repo exists, move into it and pull the latest changes
  cd ./drupal_$version
  git pull
  cd ../
fi


# Now that we have a git repository, we're going to generate the HTML pages 
# Pages are placed into a folders for each version of Drupal

# First check to see if we have the gh-pages branch
if [ ! -d "./pages" ]; then
  git clone --branch gh-pages git@github.com:jredding/drupalcores.git pages
else
  # The repository exists so we'll refresh it
  cd ./pages
  git pull
  cd ..
fi

# Check for a folder that will hold the respective Drupal version
if [ ! -d "./pages/drupal_$version" ]; then
  mkdir "./pages/drupal_$version"
fi


echo "Generating user statistics"
./cores.rb $version > ./pages/drupal_$version/index.html

echo "Generating company statistics"
./companies.rb $version > ./pages/drupal_$version/companies.html

echo "Generating json feed"
./json.rb $version > ./pages/drupal_$version/data.json

cd pages
#git commit -am "Update bump."
#git push
