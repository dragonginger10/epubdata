output := "build"
name := "epubdata"
binary := output / name

build:
    mkdir {{output}} || true
    go build -o {{output}}/{{name}}

clean:
    rm -r {{output}} || true

seven: 
    #!/usr/bin/env nu
    {{binary}} ...(ls ~/Documents/EPUB/*.epub | first 7 | get name) | from json

total:
    #!/usr/bin/env nu
    {{binary}} ...(ls ~/Documents/EPUB/*.epub | get name) | from json

timed:
    #!/usr/bin/env nu
    time {{binary}} ...(ls ~/Documents/EPUB/*.epub | get name) 
