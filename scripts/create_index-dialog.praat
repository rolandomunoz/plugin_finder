# Index all the TextGrids in a Table object
#
# Written by Rolando Munoz A. (08 Sep 2017)
# Last modified on 24 Feb 2021
#
# This script is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/1>.
#
tempObject# = selected#()
@config.init: "../preferences.txt"
selectObject: tempObject#

beginPause: "Create index"
	comment: "The directories where your files are stored..."
	text: "Folder with annotation files", config.init.return$["textgrids_dir"]
	word: "Annotation file extension:", "TextGrid"
	boolean: "Process subfolders as well", number(config.init.return$["create_index.process_subfolders_as_well"])
	comment: "Next step..."
	optionMenu: "Do", number(config.init.return$["create_index.do"])
		option: ""
		option: "Search..."
clicked = endPause: "Cancel", "Apply", "Ok", 3, 1

if clicked = 1
	exitScript()
endif

@config.setField: "textgrids_dir", folder_with_annotation_files$
@config.setField: "create_index.do", string$(do)
@config.setField: "create_index.process_subfolders_as_well", string$(process_subfolders_as_well)
@config.setField: "search.tier_name_option", "1"
@config.setField: "search.search_for", ""
@config.setField: "search.mode", "1"
@config.setField: "search.do", "1"
@config.setField: "filter_search.tier_name_option", "1"
@config.setField: "filter_search.search_for", ""
@config.setField: "filter_search.do", "1"
@config.setField: "open_file.row", "1"
@config.setField: "sounds_dir", "."
@config.setField: "extract_files.save_in", ""

# Remove previous indexes if any
indexList = Create Strings as file list: "fileList", "../temp/*.Table"
nFiles = Get number of strings
for i to nFiles
	filename$ = object$[indexList, i]
	deleteFile: "../temp/" + filename$
endfor
removeObject: indexList

# List all the files in the root directory
@createStringAsFileList: "fileList", folder_with_annotation_files$ + "/*.'annotation_file_extension$'", process_subfolders_as_well
fileList = selected("Strings")
nFiles = Get number of strings
# If no file are listed, exit the script
if not nFiles
	removeObject: fileList
	writeInfoLine: "The source folder does not contain any TextGrid file"
	if clicked = 2
		runScript: "create_index.praat"
	endif
	exitScript()
endif

# Split the number of files in groups of 1000. (This is so because Praat only admits 40000 files loaded at the same time in Object window)
step = 1000
residual_step = if (nFiles mod step) > 0 then 1 else 0 fi
number_of_steps = (nFiles div step) + residual_step

file_min = 1 - step
file_max = 0

# Join all the TextGrids into index tables
for i to number_of_steps
	file_min += step
	file_max += step
	file_max = if file_max > nFiles then nFiles else file_max fi
	for file_number from file_min to file_max
		tg_path$= folder_with_annotation_files$ + "/" + object$[fileList, file_number]
		tg = Read from file: tg_path$
		tb[file_number] = Down to Table: "no", 16, "yes", "no"
		Append column: "path"

		@normpath: tg_path$
		Formula: "path", ~ normpath.return$
		removeObject: tg
	endfor

	# Select all Tables
	for file_number from file_min to file_max
		if file_number = 1
			selectObject: tb[file_number]
		else
			plusObject: tb[file_number]
		endif
	endfor
	
	# Join all tables
	index[i] = Append

	# Remove Tables
	for file_number from file_min to file_max
		removeObject: tb[file_number]
	endfor
endfor
removeObject: fileList

# Select all the index tables
for i to number_of_steps
	if i = 1
		selectObject: index[i]
	else
		plusObject: index[i]
	endif
endfor

# Merge all the index tables in a single index
index = Append
Rename: "index"

# Remove all the previous index tables
for i to number_of_steps
	removeObject: index[i]
endfor

# Save indexes
selectObject: index
Append column: "notes"
tb_tiers = Collapse rows: "tier", "", "", "", "", ""
Save as text file: "../temp/tier_summary.Table"
numberOfTiers = object[tb_tiers].nrow
for i to numberOfTiers
	tier_name$= object$[tb_tiers, i, "tier"]
	selectObject: index
	tb_extracted_tier = Extract rows where column (text): "tier", "is equal to", tier_name$
	case$[i]= tier_name$
	case[i]= object[tb_extracted_tier].nrow
	Save as text file: "../temp/index_'tier_name$'.Table"
	removeObject: tb_extracted_tier
endfor
removeObject: tb_tiers

# Save the index
selectObject: index
Save as text file: "../temp/index.Table"

# Print in the Info window
writeInfoLine: "Create index... Done!"
appendInfoLine: ""
appendInfoLine: "Tiers:"
for i to numberOfTiers
	appendInfoLine: "	", case$[i], " (labels = ", case[i], ")"
endfor

removeObject: index

if do = 2
	runScript: "search.praat"
endif

if clicked = 2
	runScript: "create_index.praat"
endif

include ../procedures/config.proc
include ../procedures/list_recursive_path.proc
include ../procedures/paths.proc