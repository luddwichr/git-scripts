#!/bin/bash
commits=$(("$(git rev-list --count master)" - 1))
totalChangedFiles=0
totalInsertions=0
totalDeletions=0
for ((i=0; i<$commits; i++))
do
	if [[ $i == $(($commits - 1)) ]] ;
	then
		stats=$(git diff HEAD^..HEAD --shortstat)
	else
		stats=$(git diff HEAD~$((i))..HEAD~$((i+1)) --shortstat)
	fi

	pattern='([0-9]+)[^0-9]+([0-9]+)[ ]([^0-9]+)([0-9]+)?'
	if [[ $stats =~ $pattern ]] ; then
		changedFiles=${BASH_REMATCH[1]}
		secondNumber=${BASH_REMATCH[2]}
		descriptor=${BASH_REMATCH[3]}
		thirdNumber=${BASH_REMATCH[4]}
		
		if [[ $descriptor =~ insert* ]] ;
		then
			insertions=$secondNumber
			deletions=$thirdNumber
		else
			insertions=0
			deletions=$secondNumber
		fi
		echo "commit #$((i+1)): $changedFiles $insertions $deletions"
		totalChangedFiles=$((totalChangedFiles + changedFiles))
		totalInsertions=$((totalInsertions + insertions))
		totalDeletions=$((totalDeletions + deletions))
		echo "commit #$((i+1)): $totalChangedFiles $totalInsertions $totalDeletions"
	else
		echo "no match :/ for " $stats
	fi
done

if [[ $commits > 0 ]] ;
then
	echo "total: $totalChangedFiles changed files, $totalInsertions insertions, $totalDeletions deletions"
	echo "avg: $((totalChangedFiles / commits)) changed files,$((totalInsertions / commits)) insertions, $((totalDeletions / commits)) deletions"
else
	echo "no commits yet"
fi