# Organise knit HTML files

Files to build the `index.html` page are in **index_build** folder :

* `index_top.html` : everything up to the menu list
* `index_bottom.html` : everything from the menu list
* `make_tree.sh` : executable file to build the menu list
* `site-index.html` : the menu list

The executable file `make_tree.sh` runs alone. It makes a tree of all html files in a specific folder, and print the output as a HTML list in `site-index.html` file. The menu list is not perfectly. You may want to edit it.

**TODO** : Give parameters to make_tree.sh. Currently, the three parameters are set in the header of the file.

The executable file `make_index.sh` builds the index by running `make_tree.sh` file, and concatenaning the three index subfiles. It creates the file `index.html`, which looks like this :

        ┌──────────┬───────────────┬───────────┐
        │ top left │     title     │ top right │
        ├───────┬──┴───────────────┴───────────┤
        │       │                              │
        │       │                              │
        │ menu  │           iframe             │
        │       │                              │
        │       │                              │
        └───────┴──────────────────────────────┘

Everything, except the iframe box, is written in the `index.html` file. The iframe content is elsewhere on the computer.
