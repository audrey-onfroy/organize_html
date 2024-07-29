# Organise knit HTML files

This repository contains the necessary to build an `index.html` page, harboring this structure:

        ┌──────────┬───────────────┬───────────┐
        │ top left │     title     │ top right │
        ├───────┬──┴───────────────┴───────────┤
        │       │                              │
        │       │                              │
        │ menu  │           iframe             │
        │       │                              │
        │       │                              │
        └───────┴──────────────────────────────┘

* **top left corner** contains a clickable button to export the iframe content in a new tab
* **top right corner** contains the Github logo, redirecting to my Github home page
* **title** contains a string, redirecting to the `index.html` page itself
* **menu** contains a clickable menu, to open file in the iframe box
* **iframe** embeds a html file

This table was made using [https://plaintexttools.github.io/plain-text-table/](https://plaintexttools.github.io/plain-text-table/).

## Repository content

This repository contains several files and folders:

* `make_index.sh`: bash **executable** file to build the `index.html` page

You may need to make the `make_index.sh` file executable:

```bash
chmod +u+x make_index.s
```

* **index_build**: everything to build the `index.html` page:
        - `index_top.html`: html content to build the first row (top left, title, top right)
        - `index_bottom.html`: html content to build the iframe on the second row
        - `make_tree.sh`: bash **executable** file to build the menu list

You may need to make the `make_tree.sh` file executable:

```bash
chmod +u+x make_tree.sh
```

* **index_layout**: this folder is duplicated in your folder of interest. It contains:
        * **logo**:
                - Github logo for the top right corner
                - favicon for the tab logo, built using [https://favicomatic.com/](https://favicomatic.com/)
        * **pages**: some html pages that are always in the menu
        * `style.css`: for the `index.html` page to look beautiful
        * `functions.js`: JavaScript function to make the `index.html` page dynamic

## Usage

Options of `make_index.sh`:

* **-b**: this directory, containing `make_index.sh` and the necessary files
* **-r**: **root** of the directory to make the menu for
* **-m**: name of the intermediate **menu** file, will be deleted in the end(eg. `site-index.html`)
* **-i**: elements to **ignore** while making the menu
* **-o**: name of the **output** page (eg. `index.html`)

Usage :

```bash
./ make_index.sh \
-b pathto/git_book/ \
-r pathto/dir_of_interest/ \
-m pathto/git_book/site-index.html \
-i "/libs/|/index_layout/|index.html" \
-o pathto/dir_of_interest/index.html \
```

The executable file `make_index.sh` builds the `index.html` page by running `make_tree.sh` file, and concatenaning the three index subfiles (`index_top.html`, then `site-index.html`, then `index_bottom.html`). Everything, except the iframe box content, is written in the `index.html` file. The iframe content is elsewhere on the computer. This is just an embedding.

### Included in `make_index.sh`

The executable file `make_tree.sh` generate the menu, as a list, in a `site-index.html` file. The menu list is not perfect. You may want to edit it, to simplify it, or rename items, directly in the `index.html` file. The executable `make_tree.sh` asks three parameters:

* `-r` is the root directory to make tree on
* `-o` is the output file names, with full path
* `-i` is a regular expression with pattern to ignore in the tree

## Other tools ?

One may be interested in:

* **bookdown**: [https://bookdown.org/](https://bookdown.org/)
* **blogdown**: [https://bookdown.org/yihui/blogdown/](https://bookdown.org/yihui/blogdown/)
* **pkgdown**: [https://pkgdown.r-lib.org/](https://pkgdown.r-lib.org/)
* **gitbook**: [https://gitbook-ng.github.io/](https://gitbook-ng.github.io/)
* **quarto**: [https://quarto.org/docs/websites/](https://quarto.org/docs/websites/)

<br><br><br><br>

| ![CC](https://upload.wikimedia.org/wikipedia/commons/1/12/Cc-by-nc-sa_icon.svg) | Except where otherwise noted, this work is licensed under <br>   [https://creativecommons.org/licenses/by-nc-sa/4.0/](https://creativecommons.org/licenses/by-nc-sa/4.0/) |