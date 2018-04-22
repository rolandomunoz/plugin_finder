# Copyright 2017 Rolando Munoz Aramburú

if praatVersion < 6039
  appendInfoLine: "Plug-in name: Indexer"
  appendInfoLine: "Warning: This plug-in only works on Praat version 6.0.39 or later. Please, get a more recent version of Praat."
  appendInfoLine: "Praat website: http://www.fon.hum.uva.nl/praat/"
endif

# Static menu
Add menu command: "Objects", "Goodies", "Indexer", "", 0, ""
Add menu command: "Objects", "Goodies", "Create index...", "Indexer", 1, "scripts/create_index.praat"
Add menu command: "Objects", "Goodies", "-", "Indexer", 1, ""

## Query section
Add menu command: "Objects", "Goodies", "Query by tier name...", "Indexer", 1, "scripts/query_by_tier_name.praat"
Add menu command: "Objects", "Goodies", "Export query...", "Indexer", 1, "scripts/index_export.praat"
Add menu command: "Objects", "Goodies", "Import query...", "Indexer", 1, "scripts/index_import.praat"

## Do section
Add menu command: "Objects", "Goodies", "-", "Indexer", 1, ""
Add menu command: "Objects", "Goodies", "Do", "Indexer", 1, ""
Add menu command: "Objects", "Goodies", "View & Edit files...", "Do", 2, "scripts/open_files.praat"
Add menu command: "Objects", "Goodies", "Extract files...", "Do", 2, "scripts/extract_files.praat"
Add menu command: "Objects", "Goodies", "Open script template", "Do", 2, "scripts/open_script_template.praat"
Add menu command: "Objects", "Goodies", "", "Do", 2, ""
Add menu command: "Objects", "Goodies", "Filter query...", "Do", 2, "scripts/filter_query.praat"

## About section
Add menu command: "Objects", "Goodies", "-", "Indexer", 1, ""
Add menu command: "Objects", "Goodies", "About", "Indexer", 1, "scripts/about.praat"

# Dynamic menu
Add action command: "Table", 1, "", 0, "", 0, "Indexer", "", 0, ""
Add action command: "Table", 1, "", 0, "", 0, "Import query", "Indexer", 0, "scripts/index_import_from_praat_objects.praat"

## Create a local directory
createDirectory: "./temp"