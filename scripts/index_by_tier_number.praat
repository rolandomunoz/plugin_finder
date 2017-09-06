# Copyright 2017 Rolando Muñoz Aramburú

include ../procedures/config.proc

@config.init: "../.preferences"

beginPause: "index"
  sentence: "Textgrid folder", config.init.return$["textgrids_dir"]
  natural: "Tier number", number(config.init.return$["tier_number"])
  sentence: "Search for", config.init.return$["match_pattern"]
  optionMenu: "Mode", 1
    option: "is equal to"
    option: "contains"
    option: "matches (regex)"
clicked = endPause: "Continue", "Quit", 1
if clicked = 2
  exitScript()
endif

@config.setField: "textgrids_dir", textgrid_folder$
@config.setField: "tier", string$(tier_number)
@config.setField: "match_pattern", search_for$
@config.setField: "open_file.row", "1"
index = Create Table with column names: "index", 0, "tmin text tier tmax filename filename_directory"
fileList = Create Strings as file list: "fileList", textgrid_folder$ + "/*.TextGrid"

selectObject: fileList
n = Get number of strings

for i to n
  fileName$ = object$[fileList, i]
  tgDir$ = textgrid_folder$ + "/" + fileName$

  tgID = Read from file: tgDir$
  nTiers = Get number of tiers
  if tier_number <= nTiers
    nIntervals = Get number of intervals: tier_number
    for interval to nIntervals
      selectObject: tgID
      interval_text$ = Get label of interval: tier_number, interval

      # if match_pattern$ matches the interval text, then add interval info to the index
      if mode = 1
        eval = if interval_text$ = search_for$ then 1 else 0 fi
      elsif mode = 2
        eval = index(interval_text$, search_for$)
      elsif mode = 3
        eval = index_regex(interval_text$, search_for$)
      endif
      if eval
        tier_name$ = Get tier name: tier_number
        tmin = Get start time of interval: tier_number, interval
        tmax = Get end time of interval: tier_number, interval
        # Add data to the index table
        selectObject: index
        Append row
        row = Object_'index'.nrow
        Set string value: row, "text", interval_text$
        Set string value: row, "filename", fileName$
        Set string value: row, "filename_directory", textgrid_folder$
        Set string value: row, "tier", tier_name$
        Set numeric value: row, "tmin", tmin
        Set numeric value: row, "tmax", tmax
      endif
    endfor
  endif
  removeObject: tgID
endfor
removeObject: fileList

if Object_'index'.nrow
  selectObject: index
  Save as text file: preferencesDirectory$ + "/local/index.Table"
  pauseScript: "Completed successfully"
else
  selectObject: index
  deleteFile: preferencesDirectory$ + "/local/index.Table"
  pauseScript: "The index is empty. Try again."
endif