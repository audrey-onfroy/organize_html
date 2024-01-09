# Organise knit HTML files

To do :

- add doc to download the repo
- chmod both .sh files
- explain .sh files purpose
- make version

## Content

This repository contains what is necessary to build an `index.html` page, harboring this structure :

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
* **iframe** embeds a html fil

## Repository content

This repository contains several folders :

* **index_build** : everything to build the index.html` page :
        - `index_top.html` : html content to build the first row (top left, title, top right)
        - `index_bottom.html` : html content to build the iframe on the second row
        - `site-index.html` : html content to build the menu on the second row
        - `make_tree.sh` : executable file to build the menu list
* **logo** :
        - Github logo for the top right corner
        - favicon for the tab logo, built using [https://favicomatic.com/](https://favicomatic.com/)

* **pages** : some html pages that are always in the menu

and several files :

* **make_index.sh** : bash executable file to build the `index.html` page
* **style.css** : `index.html` page looks beautiful
* **functions.js** : JavaScript function to make the `index.html` page dynamic
* **index.html** : the main character of this repository

## Index builder

### Build the menu

Files to build the `index.html` page are in **index_build** folder. The executable file `make_tree.sh` runs alone. It makes a tree of all html files in a specific folder, and print the output as a HTML list in `site-index.html` file. The menu list is not perfect. You may want to edit it, to simplify it, or rename items. The executable `make_tree.sh` asks three parameters :

* `-r` is the root directory to make tree on
* `-o` is the output file names, with full path
* `-i` is a regular expression with pattern to ignore in the tree

### Build the index

The executable file `make_index.sh` builds the `index.html` page by running `make_tree.sh` file, and concatenaning the three index subfiles (`index_top.html`, then `site-index.html`, then `index_bottom.html`). Everything, except the iframe box content, is written in the `index.html` file. The iframe content is elsewhere on the computer. This is just an embedding.

## Other tools ? (ré-écrire ça en mieux)

Avec **bookdown** ou **blogdown**, on peut générer un site en html à partir des Rmd. Il y a aussi **pkgdown** qui permet de générer un site html à partir du contenu (dossier) associé à un package R. C'est la même personne qui a développé tous les packages "..down" (Yihui Xie). Il a utilisé **gitbook** notamment, qui est un outil permettant de générer un site à partir de md. Il n'y a pas de notions de R dans gitbook.

Le problème, c'est que je voudrais faire tourner les Rmd dans un conteneur Singularity, et certains sont très longs à compiler. J'ai une arborescence de Rmd. Parfois, quand il s'agit de juste faire tourner une fonction lourde, comme celle de inferCNV, il y a des scripts R entre les Rmd. Pour faire tourner tout ça en se basant sur le contenu d'un conteneur Singularity, j'utilise Nextflow.

Avec des Rmd, on peut faire :

Rmd -> md -> html

Le md est un fichier intermédiaire qui est supprimé par défaut une fois que le html est généré. On peut le garder avec l'option yml **keep_md: true**.
Ensuite, le html est appelé "self-contained" car il contient tous les styles (css), les petits bouts de Java pour le "code folding" par exemple, et les figures. C'est très pratique pour le partage : on partage juste le html à ses collègues et ils peuvent voir tout le html avec les jolis styles, directement. Inconvénient : le html peut être très lourd (plusieurs dizaines de Mo, voir 100 Mo pour certains). C'est pour ça que la plupart des html que j'ai faits ne sont pas sur GitHub.
On peut demander à ce que les html ne soient pas "self-contained". L'option yml est self_contained: false. On peut spécifier dans quel répertoire on veut sauvegarder les librairies (CSS, java etc) avec l'option **lib_dir: libs**. Pour les figures, je n'ai pas trouvé d'option dans le yml du Rmd, donc je le mets dans les options de knitr, dans un chunk :

knitr::opts_chunk$set(fig.path = "/path/where/to/save/fig")

Remarque : Pour rendre "self-contained" un html qui ne l'est pas, on peut utiliser pandoc dans le terminal avec quelque chose comme ça : pandoc input.html --self-contained

Actuellement, j'ai donc :
- fichier Rmd qui a besoin de pleins de choses pour être compilés (R, les packages dans Singularity, et les fichiers d'entrée)
- fichier md qui a besoin des styles et fonctions java pour générer le html
- fichier html qui n'est pas "self-contained", avec les librairies dans libs/ et les figures dans figs/

Je voudrais faire un site à partir de html existants, ou à partir de md, en faisant appel aux contenus de libs/ et figs/. Cela permettrait de déposer les html sur Github et de les associer à un site avec Github Pages.

Avec gitbook (basé sur du md) :
- Si j'essaie de générer les pages html à partir des fichiers md, il y a plein de problèmes de style. Le java n'est pas pris en compte, les boutons de "code-folding" ne fonctionnent pas bien, et certains chunks sortent sous forme de texte simple, ou certains bouts de texte vont dans des chunks (mauvaise séparation du code et du texte dans le html)
- On peut intégrer un page html dans un fichier md avec !INCLUDE "myhtmlfile.html". Mais, que ce soit avec les html self-contained ou pas, il y a un erreur : RangeError: Maximum call stack size exceeded. Je pense que ça vient des fonctions Java qui sont dans libs/, mais vu que ça fonctionne avec knitr, je ne vois pas pourquoi ça ne fonctionnerait pas avec gitbook... Je ne connais pas du tout Java pour débugger cette erreur.
- On pourrait inclure un faux html dans le md, avec le même nom que le vrai html, compiler le site, puis remplacer le faux html par le vrai dans la structure du site. Mais, gitbook ajoute une couche de style supplémentaire sur les html, très pratique car c'est la structure du site : lien vers les autres pages, menu déroulant, etc.

Hier soir, j'ai réussi à faire un quelque chose "fait maison" en créant un html qui génère un page avec deux colonnes. La colonne de droite contient un html self-contained (ou pas) dans une balise iframe. La colonne de gauche, pour l'instant vide, devrait contenir une arborescence de fichiers. Ce n'est pas très joli d'un point de vue des styles, mais c'est exactement le rendu je voudrais pour le html issu de Rmd.

Résumé :
- **knitr** (html unique) : Rmd -> md -> html
- **gitbook** (site) : md -> html mais problème de style pour les md issus de knitr, et problème de java pour les md qui incluent les html issus de Rmd
- **bookdown** (site) : Rmd -> html mais les Rmd doivent avoir une structure particulière car leur YML est commun, et il faut un seul titre de niveau 1 (#) par Rmd
- **blogdown** (site) : Rmd -> html + couche hugo (https://gohugo.io/) pour le thème
- **pkgdown** (site) : md -> html
- html fait maison qui contient deux colonnes. Il faudrait générer un menu automatique qui liste l'intégralité des html d'un dossier, avec un lien vers eux, et colonne de droite qui inclut le html sur lequel on a cliqué dans le menu

Dernière option à tester avant d'améliorer la version "fait maison" :
- Organiser les md de knitr sous forme d'un package R, et utiliser pkgdown pour générer le site

Je teste cette dernière option cette semaine :)

Et voilà !


A ajouter :

- Quarto permet de faire un peu comme bookdown ([https://deepshamenghani.quarto.pub/portfolio-with-quarto-workshop/#/title-slide](https://deepshamenghani.quarto.pub/portfolio-with-quarto-workshop/#/title-slide))


