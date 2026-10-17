#!/usr/bin/env nu
epubdata ...(
  ls ~/Documents/EPUB/*.epub 
  | sort-by modified -r 
  | get name
) 
| from json 
| to csv --separator ';'
| tail -n +2 
| fzf -d ';' --with-nth '{1}, by {2}' --preview 'epy --dump ~/Documents/EPUB/{3}' --bind='enter:become:epy ~/Documents/EPUB/{3}'
