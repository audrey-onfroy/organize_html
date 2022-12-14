#!/bin/bash

# ---------------------------------
#          Install npm
# ---------------------------------

sudo apt instal npm
sudo npm install gitbook-cli-g

# ---------------------------------
#  Initialize book in empty folder
# ---------------------------------

gitbook init
gitbook build

# ---------------------------------
#    Done without command lines
# ---------------------------------

# Fill book.json
# Create the docs directory and move all .md files inside

# ---------------------------------
#              Plugins
# ---------------------------------

# Add "chapter-numbering" plugin in book.json
#gitbook install # to install the plugin, in ./node_modules folder
#cd ./node_modules/gitbook-plugin-chapter-numbering
#npm install --save cheerio
#cd ../../

# Add "intopic-toc" plugin in book.json, and corresponding pluginsConfig
# https://github.com/fzankl/gitbook-plugin-intopic-toc
gitbook install

# Add "back-to-top-button" plugin in book.json, and corresponding pluginsConfig
# https://github.com/stuebersystems/gitbook-plugin-back-to-top-button
gitbook install


# Add "folding-chapters" plugin in book.json, and corresponding pluginsConfig
# https://github.com/Yakima-Teng/gitbook-plugin-folding-chapters
gitbook install


# Add "wide-page" plugin in book.json
# https://www.npmjs.com/package/gitbook-plugin-wide-page
gitbook install



# "intopic-toc@1.1.1", "back-to-top-button", 



# ---------------------------------
#           Other plugins
# ---------------------------------

# https://www.npmjs.com/search?q=gitbook-plugin

# https://github.com/lhcb/gitbook-plugin-panels
# https://github.com/tanghengzhi/gitbook-plugin-password



