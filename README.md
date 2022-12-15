# Use gitbook

The goal is to visualize all the generated HTML files as a website, using `gitbook`.

## How is it done ?

### Install npm

```bash
sudo apt instal npm
sudo npm install gitbook-cli-g
```

### Initialize book

Create an empty folder, go inside and run :

```bash
gitbook init
gitbook build
```

All the pages are stored in the `_book` folder. We do not edit files in this folder by hand.

### Create `book.json`

We create the `book.json` file and write what is inside. To make clean the repository, we add a `docs` folder containing all the files used to generate the site.

### Plugin

#### How to install ?

All the possible plugins are stored at (npmjs.com)[https://www.npmjs.com/search?q=gitbook-plugin "npmjs"] webiste. To use a plugin `plugin-name`, add :

```bash
"plugins": ["plugin-name"]
```

to the `book.json` file. Then, run in the terminal :

```bash
gitbook install
```

and 

```bash
gitbook serve # or build
```

to update the pages.

#### Favorite plugins

|  plugin                                                                                    |    used ?               |  purpose                                                  |
|--------------------------------------------------------------------------------------------|-------------------------|-----------------------------------------------------------|
|  (chapter-numbering)[https://www.npmjs.com/package/gitbook-plugin-chapter-numbering]       | <ul><li>- [ ]</li></ul> |    Number chapter in the output html file from md file    |
|  (intopic-toc)[https://github.com/fzankl/gitbook-plugin-intopic-toc]                       | <ul><li>- [ ]</li></ul> |    Floating table of content (right)                      |
|  (back-to-top-button)[https://github.com/stuebersystems/gitbook-plugin-back-to-top-button] | <ul><li>- [ ]</li></ul> |    Bottom right button to go to page top                  |
|  (folding-chapters)[https://github.com/Yakima-Teng/gitbook-plugin-folding-chapters]        | <ul><li>- [ ]</li></ul> |    Folding chapters in the site table of content (left)   |
|  (wide-page)[https://www.npmjs.com/package/gitbook-plugin-wide-page]                       | <ul><li>- [x]</li></ul> |    HTML pages have very small margins : wide page !       |

Maybe some other interesting plugins :

* (panels)[https://github.com/lhcb/gitbook-plugin-panels]
* (password)[https://github.com/tanghengzhi/gitbook-plugin-password]
