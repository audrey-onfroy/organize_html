---
title: "Add one level to all titles in Rmd file"
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

In `bookdown` package, Rmarkdown files must contains only one `#` for chapter titles, then, only subtitles (`##`, `###`). It could be useful to increment all titles in Rmd files.



The full command to replace all `#` by `##`, only in section names, is :


```bash
ls *.Rmd |
while read f; do
  { cat -n $f | awk '1;/```{/{exit}' ; \
  cat -n $f | awk '/```$/{flag=1;next}/```{/{flag=0}flag' ; } | \
  grep -P '[0-9]\s#' | \
  grep -oP '.*?(?=#)' | \
  sed 's/ //g' | \
  while read x ; do
    sed -ie "${x} s/^/#&/" $f
  done
done
```

# Create working files

We create a directory, with a pseudo-random name, to make sure the directory doesn't already exist. We generate a pseudo-random string :


```bash
rnd_str=$(openssl rand -hex 5)
echo $rnd_str > .rvars
echo $rnd_str
```

```
052554cba4
```
We can reuse this variable :


```bash
rnd_str=$(cat .rvars)
echo $rnd_str

```

```
052554cba4
```

We create a directory :


```bash
rnd_str=$(cat .rvars)
mkdir -p dir$rnd_str
ls -d dir*
```

```
dir052554cba4
```

We add two Rmarkdown files in this directory, by duplicating this one.


```bash
rnd_str=$(cat .rvars)
cp add_hash_title.Rmd dir$rnd_str/toto.Rmd
cp add_hash_title.Rmd dir$rnd_str/tata.Rmd
ls dir$rnd_str/
```

```
tata.Rmd
toto.Rmd
```

# Increment all hashes

The first line will list all Rmarkdwon file in the directory of interest :


```bash
rnd_str=$(cat .rvars)

ls dir$rnd_str/*.Rmd
```

```
dir052554cba4/tata.Rmd
dir052554cba4/toto.Rmd
```
To get file names as variable using pipe, we use the `read` function :


```bash
rnd_str=$(cat .rvars)

ls dir$rnd_str/*.Rmd |
while read f; do
 ls -lh $f
done
```

```
-rw-rw-r-- 1 aurelien aurelien 8,0K déc.  14 20:30 dir052554cba4/tata.Rmd
-rw-rw-r-- 1 aurelien aurelien 8,0K déc.  14 20:30 dir052554cba4/toto.Rmd
```

## Get matching line numbers

We can then apply a function to each file. For instance, let's work on `toto.Rmd`. We add line number. To see what we are doing, we print last 25 lines of the file.


```bash
rnd_str=$(cat .rvars)

f=dir$rnd_str/toto.Rmd

cat -n $f | tail -n 25
```

```
   275	# Exercise
   276	
   277	## Lorem ipsum A
   278	
   279	Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum vel commodo dui. Suspendisse potenti. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. In hendrerit tristique sem non interdum. Etiam eget risus quis dui pharetra condimentum id ut odio. Proin quis enim libero. Suspendisse sed purus elementum, congue ipsum eget, volutpat lorem. Duis a elit condimentum, efficitur tellus et, viverra enim. Suspendisse tincidunt odio tortor, sit amet lacinia mauris suscipit at. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Integer consectetur lacus at vulputate bibendum. Nunc ornare vel erat vitae facilisis. Praesent maximus elementum tellus vel pharetra.
   280	
   281	```{r eval = FALSE}
   282	# lorem ipsum dolor sit amet
   283	print("toto") # proin quis enim libero
   284	```
   285	
   286	
   287	## Lorem ipsum B
   288	
   289	### Lorem ipsum B1
   290	
   291	Ut luctus urna eu nisl consectetur interdum. Sed elementum, risus ut maximus ultrices, lorem nisi condimentum odio, vitae molestie urna dui ut purus. Suspendisse semper ligula ut nibh tempor tincidunt. Etiam quis nunc in neque aliquam viverra in quis libero. Maecenas ut neque a lorem lacinia tempus. Nulla sagittis turpis sed leo congue dignissim. Aenean vestibulum consectetur elit in mollis. Suspendisse vitae quam mi. Integer urna enim, convallis quis efficitur quis, facilisis ac libero. Vivamus laoreet in ligula non pretium. Donec mattis at massa a mattis. Etiam consectetur porttitor arcu in porta. Nunc nec fringilla nisl. Proin faucibus nisl eget velit iaculis elementum. Cras eu venenatis ipsum. 
   292	```{r eval = FALSE}
   293	# lorem ipsum dolor sit amet
   294	print("toto") # proin quis enim libero
   295	```
   296	
   297	### Lorem ipsum B2
   298	
   299	Ut eu tellus ornare, interdum ex ac, cursus quam. In tristique risus eu lacus aliquet iaculis in et velit. Sed felis purus, molestie eu urna eget, viverra porttitor felis. Suspendisse sed facilisis erat, non ultrices lacus. Quisque ac eros a velit maximus fringilla. Etiam malesuada in leo viverra rutrum. Nunc tempor erat id mollis pellentesque. Duis hendrerit tincidunt lacus eu ultricies.
```


To extract only text lines, ie lines not corresponding to chunk, we select all lines after the end of a chunk and before the beginning of a new one :

* end of chunk is marked by three back quotes and nothing after (`$` to mark the end)
* beginning of chunk is marked by three back quotes and a curly bracket (`{`)

The command below will extract all the text between chunks, including what is after the last chunks :


```bash
rnd_str=$(cat .rvars)

f=dir$rnd_str/toto.Rmd

cat -n $f | \
awk '/```$/{flag=1;next}/```{/{flag=0}flag' | \
tail -n 20
```

```
   267	And that's all ! We clean the directory :
   268	
   274	
   275	# Exercise
   276	
   277	## Lorem ipsum A
   278	
   279	Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum vel commodo dui. Suspendisse potenti. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. In hendrerit tristique sem non interdum. Etiam eget risus quis dui pharetra condimentum id ut odio. Proin quis enim libero. Suspendisse sed purus elementum, congue ipsum eget, volutpat lorem. Duis a elit condimentum, efficitur tellus et, viverra enim. Suspendisse tincidunt odio tortor, sit amet lacinia mauris suscipit at. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Integer consectetur lacus at vulputate bibendum. Nunc ornare vel erat vitae facilisis. Praesent maximus elementum tellus vel pharetra.
   280	
   285	
   286	
   287	## Lorem ipsum B
   288	
   289	### Lorem ipsum B1
   290	
   291	Ut luctus urna eu nisl consectetur interdum. Sed elementum, risus ut maximus ultrices, lorem nisi condimentum odio, vitae molestie urna dui ut purus. Suspendisse semper ligula ut nibh tempor tincidunt. Etiam quis nunc in neque aliquam viverra in quis libero. Maecenas ut neque a lorem lacinia tempus. Nulla sagittis turpis sed leo congue dignissim. Aenean vestibulum consectetur elit in mollis. Suspendisse vitae quam mi. Integer urna enim, convallis quis efficitur quis, facilisis ac libero. Vivamus laoreet in ligula non pretium. Donec mattis at massa a mattis. Etiam consectetur porttitor arcu in porta. Nunc nec fringilla nisl. Proin faucibus nisl eget velit iaculis elementum. Cras eu venenatis ipsum. 
   296	
   297	### Lorem ipsum B2
   298	
   299	Ut eu tellus ornare, interdum ex ac, cursus quam. In tristique risus eu lacus aliquet iaculis in et velit. Sed felis purus, molestie eu urna eget, viverra porttitor felis. Suspendisse sed facilisis erat, non ultrices lacus. Quisque ac eros a velit maximus fringilla. Etiam malesuada in leo viverra rutrum. Nunc tempor erat id mollis pellentesque. Duis hendrerit tincidunt lacus eu ultricies.
```

But, it won't include the text appearing before the first chunk :


```bash
rnd_str=$(cat .rvars)

f=dir$rnd_str/toto.Rmd

cat -n $f | \
awk '/```$/{flag=1;next}/```{/{flag=0}flag' | \
head -n 15
```

```
    25	
    26	The full command to replace all `#` by `##`, only in section names, is :
    27	
    41	
    42	# Create working files
    43	
    44	We create a directory, with a pseudo-random name, to make sure the directory doesn't already exist. We generate a pseudo-random string :
    45	
    51	We can reuse this variable :
    52	
    58	
    59	We create a directory :
    60	
    66	
    67	We add two Rmarkdown files in this directory, by duplicating this one.
```

We extract all text written before the first chunk :


```bash
rnd_str=$(cat .rvars)

f=dir$rnd_str/toto.Rmd

cat -n $f | \
awk '1;/```{/{exit}'
```

```
     1	---
     2	title: "Add one level to all titles in Rmd file"
     3	author: "Audrey"
     4	date: "`r format(Sys.time(), '%Y-%m-%d')`"
     5	output:
     6	  html_document:
     7	    self_contained: false
     8	    lib_dir: libs
     9	    keep_md: true
    10	    code_folding: show
    11	    code_download: true
    12	    toc: true
    13	    toc_float: true
    14	    number_sections: true
    15	---
    16	
    17	# Context
    18	
    19	In `bookdown` package, Rmarkdown files must contains only one `#` for chapter titles, then, only subtitles (`##`, `###`). It could be useful to increment all titles in Rmd files.
    20	
    21	```{r setup, include = FALSE}
```

We merge both commands, to get all text written before the first chunk, and after it. *Is there a more elegant command ?*


```bash
rnd_str=$(cat .rvars)

f=dir$rnd_str/toto.Rmd

{ cat -n $f | awk '1;/```{/{exit}' ; \
cat -n $f | awk '/```$/{flag=1;next}/```{/{flag=0}flag' ; } | \
head -n 25
```

```
     1	---
     2	title: "Add one level to all titles in Rmd file"
     3	author: "Audrey"
     4	date: "`r format(Sys.time(), '%Y-%m-%d')`"
     5	output:
     6	  html_document:
     7	    self_contained: false
     8	    lib_dir: libs
     9	    keep_md: true
    10	    code_folding: show
    11	    code_download: true
    12	    toc: true
    13	    toc_float: true
    14	    number_sections: true
    15	---
    16	
    17	# Context
    18	
    19	In `bookdown` package, Rmarkdown files must contains only one `#` for chapter titles, then, only subtitles (`##`, `###`). It could be useful to increment all titles in Rmd files.
    20	
    21	```{r setup, include = FALSE}
    25	
    26	The full command to replace all `#` by `##`, only in section names, is :
    27	
    41	
```


From the text, we extract only lines containing a hash (`#`). In Rmarkdown syntax, they are necessarily at the beginning of a line, so no need to add the `^` before `#`. But, we can add hash between back quotes, as in this file... To keep only hash corresponding to section names, we grep lines matching only numbers and space, then hash, because we numbered lines.


```bash
rnd_str=$(cat .rvars)

f=dir$rnd_str/toto.Rmd

{ cat -n $f | awk '1;/```{/{exit}' ; \
cat -n $f | awk '/```$/{flag=1;next}/```{/{flag=0}flag' ; } | \
grep -P '[0-9]\s#' 
```

```
    17	# Context
    42	# Create working files
    76	# Increment all hashes
    96	## Get matching line numbers
   201	## Correction
   246	## Generalization
   275	# Exercise
   277	## Lorem ipsum A
   287	## Lorem ipsum B
   289	### Lorem ipsum B1
   297	### Lorem ipsum B2
```

To get line numbers, we extract what occurs before the `#`. We could (but how ?) include this in the `grep` line, but for readability, we add a new command line :


```bash
rnd_str=$(cat .rvars)

f=dir$rnd_str/toto.Rmd

{ cat -n $f | awk '1;/```{/{exit}' ; \
cat -n $f | awk '/```$/{flag=1;next}/```{/{flag=0}flag' ; } | \
grep -P '[0-9]\s#' | \
grep -oP '.*?(?=#)'
```

```
    17	
    42	
    76	
    96	
   201	
   246	
   275	
   277	
   287	
   289	
   297	
```

We remove spaces around line numbers :


```bash
rnd_str=$(cat .rvars)

f=dir$rnd_str/toto.Rmd

{ cat -n $f | awk '1;/```{/{exit}' ; \
cat -n $f | awk '/```$/{flag=1;next}/```{/{flag=0}flag' ; } | \
grep -P '[0-9]\s#' | \
grep -oP '.*?(?=#)' | \
sed 's/ //g'
```

```
17	
42	
76	
96	
201	
246	
275	
277	
287	
289	
297	
```

## Correction

For each line in the file, we add a `#`. We use `while` and `read` to loop over all the line number. In `sed` command, option `-i` modifies the input file.


```bash
rnd_str=$(cat .rvars)

f=dir$rnd_str/toto.Rmd
fcorr=dir$rnd_str/toto_cor.Rmd
cp $f $fcorr

{ cat -n $fcorr | awk '1;/```{/{exit}' ; \
cat -n $fcorr | awk '/```$/{flag=1;next}/```{/{flag=0}flag' ; } | \
grep -P '[0-9]\s#' | \
grep -oP '.*?(?=#)' | \
sed 's/ //g' | \
while read x ; do
  sed -ie "${x} s/^/#&/" $fcorr
done
```

We can check all lines containing `#` in the corrected file :


```bash
rnd_str=$(cat .rvars)

fcorr=dir$rnd_str/toto_cor.Rmd

cat -n $fcorr | \
grep '#' 
```

```
    17	## Context
    19	In `bookdown` package, Rmarkdown files must contains only one `#` for chapter titles, then, only subtitles (`##`, `###`). It could be useful to increment all titles in Rmd files.
    26	The full command to replace all `#` by `##`, only in section names, is :
    33	  grep -P '[0-9]\s#' | \
    34	  grep -oP '.*?(?=#)' | \
    37	    sed -ie "${x} s/^/#&/" $f
    42	## Create working files
    76	## Increment all hashes
    96	### Get matching line numbers
   162	From the text, we extract only lines containing a hash (`#`). In Rmarkdown syntax, they are necessarily at the beginning of a line, so no need to add the `^` before `#`. But, we can add hash between back quotes, as in this file... To keep only hash corresponding to section names, we grep lines matching only numbers and space, then hash, because we numbered lines.
   171	grep -P '[0-9]\s#' 
   174	To get line numbers, we extract what occurs before the `#`. We could (but how ?) include this in the `grep` line, but for readability, we add a new command line :
   183	grep -P '[0-9]\s#' | \
   184	grep -oP '.*?(?=#)'
   196	grep -P '[0-9]\s#' | \
   197	grep -oP '.*?(?=#)' | \
   201	### Correction
   203	For each line in the file, we add a `#`. We use `while` and `read` to loop over all the line number. In `sed` command, option `-i` modifies the input file.
   214	grep -P '[0-9]\s#' | \
   215	grep -oP '.*?(?=#)' | \
   218	  sed -ie "${x} s/^/#&/" $fcorr
   222	We can check all lines containing `#` in the corrected file :
   230	grep '#' 
   246	### Generalization
   257	  grep -P '[0-9]\s#' | \
   258	  grep -oP '.*?(?=#)' | \
   261	    sed -ie "${x} s/^/#&/" $f
   275	## Exercise
   277	### Lorem ipsum A
   282	# lorem ipsum dolor sit amet
   283	print("toto") # proin quis enim libero
   287	### Lorem ipsum B
   289	#### Lorem ipsum B1
   293	# lorem ipsum dolor sit amet
   294	print("toto") # proin quis enim libero
   297	#### Lorem ipsum B2
```


All section names have been corrected. Hashes in code, code comments and inline code didn't changed.

We delete this corrected file :


```bash
rnd_str=$(cat .rvars)

fcorr=dir$rnd_str/toto_cor.Rmd
rm $fcorr
```


## Generalization

Now, we can apply the correction to all Rmarkdown files in the directory :


```bash
rnd_str=$(cat .rvars)

ls dir$rnd_str/*.Rmd |
while read f; do
  { cat -n $f | awk '1;/```{/{exit}' ; \
  cat -n $f | awk '/```$/{flag=1;next}/```{/{flag=0}flag' ; } | \
  grep -P '[0-9]\s#' | \
  grep -oP '.*?(?=#)' | \
  sed 's/ //g' | \
  while read x ; do
    sed -ie "${x} s/^/#&/" $f
  done
done
```


And that's all ! We clean the directory :


```bash
rnd_str=$(cat .rvars)
rm -r dir$rnd_str
rm .rvars
```

# Exercise

## Lorem ipsum A

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum vel commodo dui. Suspendisse potenti. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. In hendrerit tristique sem non interdum. Etiam eget risus quis dui pharetra condimentum id ut odio. Proin quis enim libero. Suspendisse sed purus elementum, congue ipsum eget, volutpat lorem. Duis a elit condimentum, efficitur tellus et, viverra enim. Suspendisse tincidunt odio tortor, sit amet lacinia mauris suscipit at. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Integer consectetur lacus at vulputate bibendum. Nunc ornare vel erat vitae facilisis. Praesent maximus elementum tellus vel pharetra.


```r
# lorem ipsum dolor sit amet
print("toto") # proin quis enim libero
```


## Lorem ipsum B

### Lorem ipsum B1

Ut luctus urna eu nisl consectetur interdum. Sed elementum, risus ut maximus ultrices, lorem nisi condimentum odio, vitae molestie urna dui ut purus. Suspendisse semper ligula ut nibh tempor tincidunt. Etiam quis nunc in neque aliquam viverra in quis libero. Maecenas ut neque a lorem lacinia tempus. Nulla sagittis turpis sed leo congue dignissim. Aenean vestibulum consectetur elit in mollis. Suspendisse vitae quam mi. Integer urna enim, convallis quis efficitur quis, facilisis ac libero. Vivamus laoreet in ligula non pretium. Donec mattis at massa a mattis. Etiam consectetur porttitor arcu in porta. Nunc nec fringilla nisl. Proin faucibus nisl eget velit iaculis elementum. Cras eu venenatis ipsum. 

```r
# lorem ipsum dolor sit amet
print("toto") # proin quis enim libero
```

### Lorem ipsum B2

Ut eu tellus ornare, interdum ex ac, cursus quam. In tristique risus eu lacus aliquet iaculis in et velit. Sed felis purus, molestie eu urna eget, viverra porttitor felis. Suspendisse sed facilisis erat, non ultrices lacus. Quisque ac eros a velit maximus fringilla. Etiam malesuada in leo viverra rutrum. Nunc tempor erat id mollis pellentesque. Duis hendrerit tincidunt lacus eu ultricies.
