---
title: "Singularity container containing R packages"
author: "Audrey"
date: "2022-12-14"
output:
  html_document:
    self_contained: false
    lib_dir: libs
    keep_md: true
    code_folding: show
    code_download: true
    toc: true
    toc_float: true
    number_sections: true
---

# Context

You developed your own R package.s or you work with a defined set of R packages, and you want to build a container containing all your packages of interest. In this file, we explain how we create a Singularity container containing all R packages used for the ongoing manuscript.




# List your packages of interest

Set a vector containing the names of your packages of interest, including `base` (**important**), including your own package. For instance, it could be :


```r
package_names = c("base", "aquarius",
                  "Seurat", "ggplot2", "patchwork",
                  "dplyr", "slingshot", "TInGa", "ComplexHeatmap",
                  "nichenetr", "org.Mm.eg.db", "infercnv", "rtracklayer",
                  "stringr", "RColorBrewer", "viridis", "circlize",
                  "ggvenn", "gridExtra", "gtable", "grid", "harmony",
                  "dynplot", "dynmethods", "AnnotationDbi", "msigdbr",
                  "clusterProfiler", "EnhancedVolcano", "AUCell", "Matrix",
                  "knitr", "kableExtra", "corrplot", "dynutils", "ggtext")
```

# Find dependency tree

We want to make a Singularity container containing all your packages of interest, following as much as possible the installed version. If we install one package, but all its dependencies are not yet installed, it will install your packages with the asked version, but all the latest versions for the dependencies. Then, if you want to install a second package with common dependencies, but the package can not use the latest versions, there will be an error.

The goal is to build a dependency tree linking all the wanted package, and all their dependencies, and their own dependencies, up to the `base` package. We build two functions. The first function builds the dependency three containing all your packages of interest, up to `base`. This function is based on a loop. This is the first function :


```bash
cat /home/aurelien/Documents/Audrey/git_aquarius/R/repro_dependency_tree.R
```

```
#' @title Get exhaustive list of packages with there dependencies
#' @description This function build a dependency tree for a provided list of packages. If some packages are required by the provided list but are not in the list, they are added.
#' @param wanted_packages CHARACTER : a list of installed packages (default to all packages installed)
#' @param verbose LOGICAL : whether to print a progress bar or not (default to TRUE)
#' @return This function returns a dataframe with two columns. The column "package" contains the name of the package. All wanted packages are there. The column "dependence" contains the dependency of the package.
#' @examples
#' \dontrun{
#' wanted_packages = c("base", "Matrix", "ggplot")
#' relations = repro_dependency_tree(wanted_packages = wanted_packages_matrix)
#' g = igraph::graph_from_data_frame(relations)
#'
#' custom = "Matrix"
#' custom_related = tools::package_dependencies(packages = custom,
#'                                              db = wanted_packages,
#'                                              recursive = TRUE,
#'                                              reverse = FALSE)
#' custom_related = c(as.character(unlist(custom_related)), custom)
#'
#' sub = igraph::induced_subgraph(g, vids = custom_related, impl = "auto")
#' plot(sub)
#' }
#' @importFrom dplyr distinct
#' @importFrom httr set_config config
#' @importFrom utils installed.packages txtProgressBar setTxtProgressBar
#' @export
repro_dependency_tree = function(wanted_packages = utils::installed.packages()[, "Package"],
                                 verbose = TRUE){
  # Input
  wanted_packages = unique(c("base", wanted_packages))
  installed_packages_db = utils::installed.packages()
  all_packages = rownames(installed_packages_db)

  # Check if packages are installed
  not_installed = wanted_packages[!(wanted_packages %in% rownames(installed_packages_db))]
  if (length(not_installed) > 0) {
    stop("Some packages are not installed : ", not_installed)
  }

  # Progress bar
  if (verbose) {
    max_it = length(all_packages)
    pb = utils::txtProgressBar(min = 1, max = max_it, initial = 1, style = 3)
  }

  # Initialization : a package without any dependence
  relations = data.frame(package = "base",
                         dependence = "0")
  relations[] = lapply(relations, as.character)
  all_packages = all_packages[-(which(all_packages == "base"))]

  # Loop to get dependency tree
  while (length(all_packages) != 0) {
    done_in_this_round = c()

    for (package in all_packages) {
      done = FALSE

      # Get package's dependencies
      its_dependencies = tools::package_dependencies(packages = package,
                                                     db = installed_packages_db,
                                                     recursive = FALSE,
                                                     reverse = FALSE,
                                                     which = c("Depends", "Imports", "LinkingTo"))
      its_dependencies = unlist(its_dependencies)
      its_dependencies = as.character(its_dependencies)

      # If : 1) no dependencies or
      #      2) dependencies have already been taken into account
      # Then : contribute to relations

      ## IF
      if (length(its_dependencies) == 0) {
        relations_package = data.frame(package = package,
                                       dependence = "0")
        done = TRUE
      } else if (sum(its_dependencies %in% relations$package) == length(its_dependencies)) {
        # Relation of these package and its dependencies
        relations_package = data.frame(package = package,
                                       dependence = its_dependencies)
        done = TRUE
      }

      ## THEN
      if (done) {
        relations_package[] = lapply(relations_package, as.character)

        # Concatenate to relations
        relations = rbind(relations, relations_package)
        relations[] = lapply(relations, as.character)

        # Add this package to the ones added to relations during the FOR loop
        done_in_this_round = c(done_in_this_round, package)
      }
    } # Then, let's go to next package

    # Remove all done packages during the FOR, to loop again in WHILE
    all_packages = all_packages[!(all_packages %in% done_in_this_round)]

    # Progress bar
    if (verbose) {
      utils::setTxtProgressBar(pb, max_it - length(all_packages))
    }

  } # We browse all the list and remove some package, so re browse the list without these packages

  ## Remove duplicated rows
  relations = dplyr::distinct(relations)

  ## Progress bar
  if (verbose) {
    close(pb)
  }

  ## Keep only wanted packages (this is not time-consuming)
  # "relations" can be sawn as a directed graph from one package to one dependencies.
  # The packages of interest are not necessarily bound by dependendies link,
  # but, they belong to the full graph.
  # We would like a subgraph :
  # - containing all wanted packages
  # - containing all their dependencies, in a recursive manner
  # i.e., from each package, it is possible to reach the "0" dependencies, by following
  # the egde direction

  # 1- Initialization : keep only wanted packages
  sub_relations = relations %>%
    dplyr::filter(package %in% wanted_packages)

  ndims = 0 # init

  # While the nrow of sub_relations is different from the one in the previous round, ...
  while (nrow(sub_relations) != ndims) {
    ndims = nrow(sub_relations)

    # Get all the dependencies for which we
    # have not yet their own dependencies
    all_dependencies = unique(sub_relations$dependence)
    all_dependencies = setdiff(all_dependencies, sub_relations$package)

    # Add the dependencies
    sub_relations = rbind(sub_relations,
                          relations %>%
                            dplyr::filter(package %in% all_dependencies))
  }

  # Put in the good order (installation order !)
  sub_relations = dplyr::inner_join(relations, sub_relations,
                                    by = c("package", "dependence"))

  ## Output
  return(sub_relations)
}
```

# Find download link for each package

The second function will find a download link to install the package. In this function, we specific that there are no download link for our own package, because we will use the `.tar.gz` file to install it in the container. This is the second function, which will call the first one :


```bash
cat /home/aurelien/Documents/Audrey/git_aquarius/R/repro_installation_order.R
```

```
#' @title Get installation order to install packages such as no dependencies need to be installed
#' @description This function uses the function repro_dependency_tree to build the dependency tree between packages. Then, it retrieves the link to install the specific version of packages. The function returns a dataframe where packages are in the order to install. This dataframe contains link to download package version.
#' build a dependency tree for a provided list of packages. If some packages are required by the provided list but are not in the list, they are added.
#' @param wanted_packages CHARACTER : a list of wanted and already installed packages (default to all packages installed)
#' @param verbose LOGICAL : whether to print a progress bar or not (default to TRUE)
#' @return The function returns a dataframe where packages are in the order to install. This dataframe contains link to download package in the same version as installed.
#' @details TO DO :
#' - make the function working for uninstalled package : one must also add the wanted version
#' - add a new parameter to set the list of exception. It must be named vector containing the url to download package. Packages are the names of this vector.
#' @importFrom httr set_config config http_error
#' @importFrom utils installed.packages txtProgressBar setTxtProgressBar
#' @export
repro_installation_order = function(wanted_packages = utils::installed.packages()[, "Package"],
                                    verbose = TRUE){
  ## Order to install packages
  # The order to install packages is the order of appearance of packages in get.dependency.tree()
  # because each time we added a package in relations, this was because all its
  # dependencies were already added in relations
  message("Get dependency order")
  package_order = repro_dependency_tree(wanted_packages, verbose = verbose)
  package_order = unique(package_order$package)

  ## Get package version
  # Note : utils::packageVersion gives version with dot : 0.8.18 for example
  #        utils::installed.packages gives the "true" version : 0.8-18 for amap package for example
  all_installed_packages = utils::installed.packages()
  info_to_install = as.data.frame(all_installed_packages)[package_order, c("Package", "Version")]
  colnames(info_to_install) = c("package_name", "version")

  info_to_install$order = c(1:nrow(info_to_install))
  info_to_install = info_to_install[, c("order", "package_name", "version")]

  ## Clean
  rm(list = c("package_order", "all_installed_packages"))

  # head(info_to_install)
  #   order    package_name version
  # 1     1            base   3.6.3
  # 2     2         acepack   1.4.1
  # 3     3 additivityTests   1.1-4
  # 4     4       ADGofTest     0.3
  # 5     5       AlgDesign   1.2.0
  # 6     6            amap  0.8-18

  ## Internal functions
  CRAN_archive = function(package, version) {
    url = paste("http://cran.r-project.org/src/contrib/Archive/",
                package, "/", package, "_", version, ".tar.gz", sep = "")
    return(url)
  }

  CRAN_last = function(package, version) {
    url = paste("https://cran.r-project.org/src/contrib/",
                package, "_", version, ".tar.gz", sep = "")
    return(url)
  }

  BioC_archive = function(package, version, bio = "3.10") {
    url = paste("https://bioconductor.org/packages/", bio, "/bioc/src/contrib/Archive/",
                package, "/", package, "_", version, ".tar.gz", sep = "")
    return(url)
  }

  BioC_last = function(package, version, bio = "3.10") {
    url = paste("https://bioconductor.org/packages/", bio, "/bioc/src/contrib/",
                package, "_", version, ".tar.gz", sep = "")
    return(url)
  }

  BioC_riken = function(package, version, bio = "3.10") {
    url = paste("https://bioconductor.riken.jp/packages/", bio, "/data/annotation/src/contrib/",
                package, "_", version, ".tar.gz", sep = "")
    return(url)
  }

  RAN_archive = function(package, version) {
    url = paste("http://ran.synapse.org/src/contrib/",
                package, "_", version, ".tar.gz", sep = "")
    return(url)
  }

  url_exists = function(url) {
    return(!httr::http_error(url))
  }

  # Remove a error :
  # Error in curl::curl_fetch_memory(url, handle = handle) :
  #   SSL certificate problem: unable to get local issuer certificate
  httr::set_config(httr::config(ssl_verifypeer = FALSE))

  ## Initialization of url and type of url
  info_to_install$url = NA
  info_to_install$type = NA

  message("Get download url for each package")

  if (verbose) {
    pb = utils::txtProgressBar(min = 1, max = nrow(info_to_install), initial = 1, style = 3)
  }

  for (i in c(1:nrow(info_to_install))) {
    package = info_to_install[i, "package_name"]
    version = info_to_install[i, "version"]
    package = as.character(package)
    version = as.character(version)

    # Progress bar
    if (verbose) {
      utils::setTxtProgressBar(pb, i)
    }

    # ============================================================================ Base package
    if (package %in% c("stats", "graphics", "grDevices",
                       "utils", "datasets", "methods", "base",
                       "compiler", "grid", "tools",
                       "tcltk", "parallel", "splines", "stats4")) {
      info_to_install[i, "url"] = "this_is_base"
    } else {
      # ========================================================================== Not base
      # Compute each possible link
      url_CRAN_archive = CRAN_archive(package, version)
      url_CRAN_last = CRAN_last(package, version)
      url_BioC_archive = BioC_archive(package, version)
      url_BioC_last = BioC_last(package, version)

      # ========================================================================== CRAN or BioC 3.10
      # Test each one
      if (url_exists(url_CRAN_archive)) {
        info_to_install[i, "url"] = url_CRAN_archive
        info_to_install[i, "type"] = "CRAN_archive"
      } else if (url_exists(url_CRAN_last)) {
        info_to_install[i, "url"] = url_CRAN_last
        info_to_install[i, "type"] = "CRAN_last"
      } else if (url_exists(url_BioC_archive)) {
        info_to_install[i, "url"] = url_BioC_archive
        info_to_install[i, "type"] = "BioC_archive"
      } else if (url_exists(url_BioC_last)) {
        info_to_install[i, "url"] = url_BioC_last
        info_to_install[i, "type"] = "BioC_last"
      } else if (package %in% c("TInGa")) {
        # ======================================================================== Github subdir
        info_to_install[i, "url"] = 'devtools::install_github("Helena-todd/TInGa/package")'
        info_to_install[i, "type"] = 'special_install'
      } else {
        # ======================================================================== Github specific

        url_custom = NULL
        if (package == "leidenbase" & version == "0.1.0") {
          url_custom = "https://github.com/cole-trapnell-lab/leidenbase/archive/refs/tags/0.1.0.tar.gz"
        } else if (package == "monocle3" & version == "0.2.1") {
          url_custom = "https://github.com/cole-trapnell-lab/monocle3/archive/refs/tags/0.2.1.tar.gz"
        } else if (package == "liger" & version == "0.5.0") {
          url_custom = "https://github.com/welch-lab/liger/archive/refs/tags/v0.5.0.tar.gz"
        } else if (package == "dynplot" & version == "1.0.2.9000") {
          url_custom = "https://cran.r-project.org/src/contrib/Archive/dynplot/dynplot_1.1.0.tar.gz"
        } else if (package == "clustifyrdata" & version == "0.2.0") {
          url_custom = "https://api.github.com/repos/rnabioco/clustifyrdata/tarball/"
        } else if (package == "loomR" & version == "0.2.1.9000") {
          url_custom = "https://api.github.com/repos/mojaveazure/loomR/tarball/"
        } else if (package == "CCInx" & version == "0.5.1") {
          url_custom = "https://api.github.com/repos/BaderLab/CCInx/tarball/"
        } else if (package == "SeuratWrappers" & version == "0.2.0") {
          url_custom = "https://api.github.com/repos/satijalab/seurat-wrappers/tarball/"
        } else if (package == "nichenetr" & version == "0.1.0") {
          url_custom = "https://api.github.com/repos/saeyslab/nichenetr/tarball/"
        } else if (package == "dyneval" & version == "0.9.9") {
          url_custom = "https://api.github.com/repos/dynverse/dyneval/tarball/"
        } else if (package == "reticulate" & version == "1.24-9000") {
          url_custom = "https://cran.r-project.org/src/contrib/reticulate_1.24.tar.gz"
        } else if (package == "ggpattern" & version == "0.3.1") {
          url_custom = "https://github.com/coolbutuseless/ggpattern/archive/refs/tags/v0.3.1.tar.gz"
        } else if (package == "gng" & version == "0.1.0") {
          url_custom = "https://api.github.com/repos/rcannood/gng/tarball/"
        } else if (package == "dynmethods" & version == "1.0.5") {
          url_custom = "https://api.github.com/repos/dynverse/dynmethods/tarball/"
        } else if (package == "dynguidelines" & version == "1.0.1") {
          url_custom = "https://api.github.com/repos/dynverse/dynguidelines/tarball/"
        } else if (package == "dyno" & version == "0.1.2") {
          url_custom = "https://api.github.com/repos/dynverse/dyno/tarball/"
        } else if (package == "circlize" & version == "0.4.16") { # VERSION IS NOT MATCHING
          url_custom = "https://cran.r-project.org/src/contrib/circlize_0.4.15.tar.gz"
        } else if (package == "DO.db") {
          url_custom = "https://bioconductor.org/packages/3.15/data/annotation/src/contrib/DO.db_2.9.tar.gz"
        } else if (package == "GO.db") {
          url_custom = "https://bioconductor.org/packages/3.10/data/annotation/src/contrib/GO.db_3.10.0.tar.gz"
        } else if (package == "org.Mm.eg.db") {
          url_custom = "https://bioconductor.org/packages/3.10/data/annotation/src/contrib/org.Mm.eg.db_3.10.0.tar.gz"
        } else if (package == "GenomeInfoDbData") {
          url_custom = "https://bioconductor.org/packages/3.10/data/annotation/src/contrib/GenomeInfoDbData_1.2.2.tar.gz"
        } else if (package == "ComplexHeatmap") { # VERSION IS NOT MATCHING
          url_custom = "https://www.bioconductor.org/packages/release/bioc/src/contrib/ComplexHeatmap_2.14.0.tar.gz"
        }

        if (!is.null(url_custom)) {
          if (url_exists(url_custom)) {
            info_to_install[i, "url"] = url_custom
            info_to_install[i, "type"] = "url_custom"
          } else {
            stop(package)
          }
        } else {
          # ======================================================================== Ultra specific

          # 1) Specific repository : RAN
          # Case for : PythonEmbedInR, synapser and synapserutils
          url_RAN_archive = RAN_archive(package, version)

          # 2) Package version is stored on CRAN without the last number
          # Case for : furrr, dynutils, patchwork and dynfeature
          # Example : 1.0.1.9000 -> 1 0 1 9000 -> 1.0.1
          version_short = strsplit(version, split = "\\.")[[1]]
          version_short = paste(version_short[c(1:(length(version_short) - 1))], collapse = ".")

          url_CRAN_archive_short_version = CRAN_archive(package, version_short)
          url_CRAN_last_short_version = CRAN_last(package, version_short)

          # 3) Another bioconductor
          # Case for : GOSemSim, clustifyr, AND GenomeInfoDbData
          url_BioC_3.11_archive = BioC_archive(package, version, bio = "3.11")
          url_BioC_3.11_last = BioC_last(package, version, bio = "3.11")
          url_BioC_riken = BioC_riken(package, version)

          if (package == "clustifyr") {
            url_BioC_3.11_archive = BioC_archive(package, "0.99.8", bio = "3.11")
          }

          # Test each one
          if (url_exists(url_RAN_archive)) {
            info_to_install[i, "url"] = url_RAN_archive
            info_to_install[i, "type"] = "RAN_archive"
          } else if (url_exists(url_CRAN_archive_short_version)) {
            info_to_install[i, "url"] = url_CRAN_archive_short_version
            info_to_install[i, "type"] = "CRAN_archive_short_version"
          } else if (url_exists(url_CRAN_last_short_version)) {
            info_to_install[i, "url"] = url_CRAN_last_short_version
            info_to_install[i, "type"] = "CRAN_last_short_version"
          } else if (url_exists(url_BioC_3.11_archive)) {
            info_to_install[i, "url"] = url_BioC_3.11_archive
            info_to_install[i, "type"] = "BioC_3.11_archive"
          } else if (url_exists(url_BioC_3.11_last)) {
            info_to_install[i, "url"] = url_BioC_3.11_last
            info_to_install[i, "type"] = "BioC_3.11_last"
          } # else if (url_exists(url_BioC_riken)) {
          #info_to_install[i, "url"] = url_BioC_riken
          # info_to_install[i, "type"] = "BioC_riken"
          #}
          else {
            info_to_install[i, "url"] = "another_exception"
            info_to_install[i, "type"] = "another_exception"
          }
        }
      }
    }
  }

  ## Progress bar
  if (verbose) {
    close(pb)
  }

  ## Message when url not found
  message("url not found for the following packages :")
  url_not_found = info_to_install[info_to_install$url == "another_exception", c("package_name", "version")]
  for (i in 1:nrow(url_not_found)) {
    message(url_not_found$package_name[i], " : ", url_not_found$version[i])
  }
  rm(url_not_found)

  ## Output
  return(info_to_install)
}
```

# Make `info_to_install` dataframe

## Principle

The function outputs a dataframe `info_to_install` looking like this :


```bash
tail -n 15 /home/aurelien/Documents/Audrey/git_scripts/singularity/rpackages/info_to_install_13_12_2022.txt
```

```
442	destiny	3.0.1	https://bioconductor.org/packages/3.10/bioc/src/contrib/destiny_3.0.1.tar.gz	BioC_last
443	DOSE	3.12.0	https://bioconductor.org/packages/3.10/bioc/src/contrib/DOSE_3.12.0.tar.gz	BioC_last
444	dynparam	1.0.0	http://cran.r-project.org/src/contrib/Archive/dynparam/dynparam_1.0.0.tar.gz	CRAN_archive
445	dynwrap	1.2.1	http://cran.r-project.org/src/contrib/Archive/dynwrap/dynwrap_1.2.1.tar.gz	CRAN_archive
446	enrichplot	1.6.1	https://bioconductor.org/packages/3.10/bioc/src/contrib/enrichplot_1.6.1.tar.gz	BioC_last
447	gng	0.1.0	https://api.github.com/repos/rcannood/gng/tarball/	url_custom
448	nichenetr	0.1.0	https://api.github.com/repos/saeyslab/nichenetr/tarball/	url_custom
449	scBFA	1.0.0	https://bioconductor.org/packages/3.10/bioc/src/contrib/scBFA_1.0.0.tar.gz	BioC_last
450	scDblFinder	1.1.8	https://bioconductor.org/packages/3.10/bioc/src/contrib/scDblFinder_1.1.8.tar.gz	BioC_last
451	clusterProfiler	3.14.3	https://bioconductor.org/packages/3.10/bioc/src/contrib/clusterProfiler_3.14.3.tar.gz	BioC_last
452	dynfeature	1.0.0.9000	https://cran.r-project.org/src/contrib/dynfeature_1.0.0.tar.gz	CRAN_last_short_version
453	dynmethods	1.0.5	https://api.github.com/repos/dynverse/dynmethods/tarball/	url_custom
454	dynplot	1.0.2.9000	https://cran.r-project.org/src/contrib/Archive/dynplot/dynplot_1.1.0.tar.gz	url_custom
455	dyneval	0.9.9	https://api.github.com/repos/dynverse/dyneval/tarball/	url_custom
456	TInGa	0.0.0.9000	devtools::install_github("Helena-todd/TInGa/package")	special_install
```
There are several columns :

- **order** : installation order
- **package_name** : package name
- **version** : package version you already installed
- **url** : link to download the package in the good version. For some packages, it was not possible to find a link matching the good version, so the function uses a list of exceptions to find another link.
- **type** : the type of link, for information only


## No version on Github

Some packages, such as `TInGa`, can only be installed from GitHub, and there are no version available. We can download from a particular commit or from the alst one. We chose this last option. Those packages have the **type** `special_install`, and will be download by evaluating what is written in the **url** column, for instance :


```bash
tail -n 1 /home/aurelien/Documents/Audrey/git_scripts/singularity/rpackages/info_to_install_13_12_2022.txt
```

```
456	TInGa	0.0.0.9000	devtools::install_github("Helena-todd/TInGa/package")	special_install
```

## No download link

For some packages, no link can be found, even for other versions than the one installed. Their "type" is `another_exception`. You can access to those packages like this :


```r
info_to_install %>% dplyr::filter(url == "another_exception")
```

Please, make sure you have the `.tar.gz` file corresponding to those packages, and remove lines in the dataframe :


```r
info_to_install = info_to_install %>% dplyr::filter(url != "another_exception")
```


## clustifyrdata issue

For package `clustifyrdata`, the dependency `tibble` is not set. We move `clustifyrdata` just before `clustifyr` because `clustifyr` is a dependency only for `clustifyrdata`, and it depends on `tibble` which is not defined in `clustifyrdata` dependencies :


```r
which_clustifyrdata = which(info_to_install$package_name == "clustifyrdata")
which_clustifyr = which(info_to_install$package_name == "clustifyr")

info_to_install = rbind(info_to_install[c(1:(which_clustifyrdata - 1)),],
                        info_to_install[c((which_clustifyrdata + 1):(which_clustifyr - 1)),],
                        info_to_install[which_clustifyrdata,],
                        info_to_install[c(which_clustifyr:nrow(info_to_install)),])
```


## Save the file

Now, save the file :


```r
save_name = "./info_to_install.txt"
utils::write.table(x = info_to_install,
                   file = save_name,
                   quote = FALSE, sep = "\t", row.names = FALSE, col.names = TRUE)
```

## Check url validity

Later, you can check if the download link are still valid using the following code :


```r
info_to_install = read.table(save_name, header = TRUE)

url_exists = function(url) {
  return(!httr::http_error(url))
}

httr::set_config(httr::config(ssl_verifypeer = FALSE))

for (url in info_to_install$url) {
  if (url != "this_is_base") {
    if (!url_exists(url)) {
      message(url)
    }
  }
}
```


# Loop to install packages from links

You have :

* **info_to_install.txt** : file containing the link to download and install each package, in the good installation order.
* **.tar.gz** : archive for package for which no download link is available, for instance, your own package

We wrote a R script to install all packages using the **info_to_install.txt** file. This script will loop in the dataframe. It will not install anything for base package (type `this_is_base`), download the package at their url for the other, and evaluate the code for some (type `special_install`).


```bash
cat /home/aurelien/Documents/Audrey/git_scripts/singularity/rpackages/singularity_from_tree.R
```

```
#!/usr/bin/env Rscript

file_path = commandArgs(trailingOnly = TRUE)
info_to_install = utils::read.table(file_path, header = TRUE,
                                    colClasses = c("integer", "character", "character", "character", "character"))

for (i in c(1:nrow(info_to_install))) {
  package = info_to_install[i, "package_name"]
  dl_url = info_to_install[i, "url"]
  type = info_to_install[i, "type"]
  
  if (dl_url !=  "this_is_base") {
    # From url or from a R command
    if (type == "special_install") {
      eval(parse(text = dl_url))
    } else {
      install.packages(dl_url, repos = NULL, method = "wget",
                       clean = TRUE, dependencies = c("Depends", "Imports", "LinkingTo"),
                       extra = "--no-check-certificate")
    }

    #library(package, character.only = TRUE)
    
    # If package not problematic and if we already download 1000 packages, load them
    # if (!(package %in% c("conflicted", "semTools", "spacetime", "gstat"))) {
    #   if (i > 1000) {
    #     library(package, character.only = TRUE)
    #   }
    # }
  }
}
```


# Write the definition file

You have :

* **info_to_install.txt** : file containing the link to download and install each package, in the good installation order.
* **.tar.gz** : archive for package for which no download link is available, for instance, your own package
* **singularity_from_tree.R** : R script to install all packages

Now, write a definition file for Singularity :


```bash
cat /home/aurelien/Documents/Audrey/git_scripts/singularity/rpackages/singularity_from_tree.def
```

```
BootStrap: library
From: ubuntu:20.04

%environment
    export PATH=/opt/tools/bin:$PATH
    export RETICULATE_MINICONDA_ENABLED=FALSE
    export LANG=en_US.UTF-8
    export LANGUAGE=en_US
    export LC_ALL=en_US.UTF-8
    export LC_CTYPE=C
    export LC_TIME=en_US.UTF-8
    export LC_MONETARY=en_US.UTF-8
    export LC_PAPER=en_US.UTF-8
    export LC_MEASUREMENT=en_US.UTF-8

%files
    # R script to download packages from url, in loop
    /home/aurelien/Documents/Audrey/git_scripts/singularity/rpackages/singularity_from_tree.R /install_R_packages.R
    # A table with package, version and url to download them
    /home/aurelien/Documents/Audrey/git_scripts/singularity/rpackages/info_to_install_14_12_2022.txt /package_version_url.R
    # Archive for aquarius package (our own package)
    /home/aurelien/Documents/Audrey/git_scripts/singularity/rpackages/aquarius-0.1.3.tar.gz /aquarius.tar.gz
    # Copy the definition in the container, for reproducibility
    /home/aurelien/Documents/Audrey/git_scripts/singularity/rpackages/singularity_from_tree.def /singularity_recipe.def

%post
    ## ------------------------------------------------------------------ ##
    ## ------------------------ Install librairies ---------------------- ##
    ## ------------------------------------------------------------------ ##
    apt-get -y update && apt-get -y upgrade
    apt-get install -y libxml2-dev
    apt-get install -y dirmngr gnupg apt-transport-https ca-certificates software-properties-common

    # install these lib after previous (else : error)
    apt-get -y update && apt-get -y upgrade
    apt-get install -y libcurl4-openssl-dev libssl-dev
    add-apt-repository -y ppa:cran/libgit2

    apt-get install -y wget

    ## ------------------------------------------------------------------ ##
    ## ------------- Pre requisites to install R language --------------- ##
    ## ------------------------------------------------------------------ ##
    apt-get -y update && apt-get -y upgrade
    apt-get install -y g++ gcc gfortran zlib1g-dev zlib1g libbz2-dev libreadline-dev
    
    #apt-get install -y  xorg-dev # xserver-xorg-dev # libglx-dev libgl-dev mesa-common-dev
    apt-get install -y libbz2-dev liblzma-dev libpango1.0-dev build-essential
    apt-get install -y libcurl4-gnutls-dev libssl-dev

    ## Java dependencies for some packages
    apt-get -y update && apt-get -y upgrade
    apt-get install -y default-jre default-jdk default-jdk-headless #openjdk-8-jdk openjdk-8-jre
    export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64/jre"
    export PATH=$PATH:$JAVA_HOME/bin

    ## Package specific installation
    apt-get -y update && apt-get -y upgrade

    # Package : aplpack
    DEBIAN_FRONTEND=noninteractive apt-get -y install tcl8.6 tk8.6 tcl8.6-dev tk8.6-dev tcl8.6-doc tk8.6-doc

    # Package : gsl
    add-apt-repository main
    add-apt-repository universe
    add-apt-repository restricted
    add-apt-repository multiverse  
    apt-get -y update && apt-get -y upgrade
    apt-get install -y libgsl23 libgsl-dev

    # Package : jpeg
    apt-get -y update && apt-get -y upgrade
    apt-get install -y libjpeg-dev libjpeg-turbo8-dev

    # Package : ncdf4
    apt-get install -y libnetcdf-dev

    # Package : udunits2
    apt-get -y update && apt-get install -y libudunits2-dev libgdal-dev libgeos-dev libproj-dev

    # Package : rjags
    apt-get -y install pkg-config jags

    # Package : rmarkdown
    wget -O pandoc.deb https://github.com/jgm/pandoc/releases/download/2.19.2/pandoc-2.19.2-1-amd64.deb
    dpkg -i pandoc.deb
    rm /pandoc.deb

    ## ------------------------------------------------------------------ ##
    ## ----------------------- Install R language ----------------------- ##
    ## ------------------------------------------------------------------ ##
    ## As described in https://cran.r-project.org/bin/linux/ubuntu/
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9

    export R_VERSION=3.6.3
    cd /usr/local/src
    wget -O R-${R_VERSION}.tar.gz https://cran.r-project.org/src/base/R-3/R-${R_VERSION}.tar.gz
    tar xzvf R-${R_VERSION}.tar.gz
    cd R-${R_VERSION}
    ./configure \
        --prefix=/usr/local \
        --x-includes=/usr/include/X11 \
        --x-libraries=/usr/lib/X11 \
        --enable-R-shlib \
        --enable-prebuilt-html
    make && make install

    rm /usr/local/src/R-${R_VERSION}.tar.gz
    
    ## ------------------------------------------------------------------ ##
    ## --------------------- Install all R packages --------------------- ##
    ## ------------------------------------------------------------------ ##
    apt-get -y update && apt-get -y upgrade
    Rscript /install_R_packages.R /package_version_url.R

    ## ------------------------------------------------------------------ ##
    ## ------------------------ Install aquarius ------------------------ ##
    ## ------------------------------------------------------------------ ##
    R CMD INSTALL /aquarius.tar.gz
    R -e 'library(aquarius)'

    ## ------------------------------------------------------------------ ##
    ## ---------------------------- Clean ------------------------------- ##
    ## ------------------------------------------------------------------ ##
    rm /install_R_packages.R
    rm /package_version_url.R
    rm /aquarius.tar.gz


%labels
    Author Audrey ONFROY

%help
    Time to build : 2h15
```

This file will :

* install all R language dependencies
* install specific libraries for some R packages. We found those lines by trail and error
* install R in version 3.6.3
* install all the R packages using the R script
* install our custom package from the `.tar.gz` archive

# Build the image

Use the following command to build the image :


```bash
sudo time singularity build my_image.simg singularity_from_tree.def
```

And the image is done !

