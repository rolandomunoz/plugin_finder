# Filter a query table
#
# Written by Rolando Muñoz A. (15 Sep 2017)
#
# This script is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/1>.
#
include ../procedures/get_tier_number.proc
query = Read from file: "../../local/query.Table"
form Filter_query
  word Tier_name et
  word Search_for_(regex) ^CS$
endform
Append column: "temp"

for i to Object_'query'.nrow
  getTierNumber.return[tier_name$] = 0
  file_path$ = object$[query, i, "file_path"]
  tmin = object[query, i, "tmin"]
  tmax = object[query, i, "tmax"]
  tmid = (tmax + tmin)*0.5
  tg = Read from file: file_path$
  @getTierNumber
  tier = getTierNumber.return[tier_name$]
  if tier
    interval = Get interval at time: tier, tmid
    interval_label$ = Get label of interval: tier, interval
    if index_regex(interval_label$, search_for$)
      selectObject: query
      Set numeric value: i, "temp", 1
    endif
  endif
  removeObject: tg
endfor
selectObject: query
query_extracted = Extract rows where column (number): "temp", "equal to", 1
Rename: "query"
Remove column: "temp"

removeObject: query
selectObject: query_extracted
Save as text file: "../../local/query.Table"
pauseScript: "Completed successfully"