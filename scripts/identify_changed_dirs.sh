#!/bin/bash

# this script will run in Travis CICD, identify changed files
# and save the directories of the files if a condition is met,
# it will then print the array of directories

top_level_directory='src'
main_branch_name='main'

if [[ "$TRAVIS_EVENT_TYPE" == "push" ]]; then
	# collect only changed files from commit
	mapfile -t files< <(git diff-tree --no-commit-id --name-only -r "$TRAVIS_COMMIT")
elif [[ "$TRAVIS_EVENT_TYPE" == "pull_request" ]]; then
	# collect all changed files from commit range
	mapfile -t files< <(git diff-tree --no-commit-id --name-only -r origin/"$main_branch_name" -r "$TRAVIS_COMMIT")
fi

# create directories list
directories=()

for file in "${files[@]}"; do
	parent_dir=$(dirname -- "$file")

	# I only want to collect files in subdirectories under a top level directory
	# provided at the top of the script, therefore the condition requires that the
	# path has a directory matching the user provided value
	if [[ $parent_dir != "." ]] && [[ $parent_dir == *"$top_level_directory"* ]]; then
		directories+=("$parent_dir")
	fi
done

if [[ ${#directories[@]} -eq 0 ]]; then
	echo "no matches"
else
	printf "'%s'\n" "${directories[@]}"
    # often we want to write to a file so that another script can act on the list
	# write directories to file since arrays cannot be exported
	printf "'%s'\n" "${directories[@]}" > changed_tf_dirs.txt
fi
