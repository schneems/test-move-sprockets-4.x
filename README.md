# Sprockets test-move-4.x caching

> Warning: I can't get sprockets 4.x to work

```
$ ls public/assets
ls: public/assets: No such file or directory
$ RAILS_ENV=production bin/rake assets:precompile
$ ls -f public/assets
.               .sprockets-manifest-086efa7aa260714a7d0c3db1ac42e84a.json
# No actual assets generated
```

Why? No clue, someone with more sprockets 4 experience want to take a stab?

## Issue I want to test for

Newer versions of sprockets cache assets based on an asset's
fullpath. In an environment like Heroku, this means that _no caching_
occurs between deploys, because the build directory is prefixed by a
random hash on each subsequent deploy.

This repository is meant to provide a simple and minimal example of
the problem. 500 random JavaScript files of varying length are being
included for demonstration purposes.

## Reproducing

```sh
~/test-move-4.x $ time RAILS_ENV=production bin/rake assets:precompile
# Observe long compile time

~/test-move-4.x $ time RAILS_ENV=production bin/rake assets:precompile
# Observe short compile time due to cache present in tmp/cache

~/test-move-4.x $ cd .. && mv test-move-4.x no-cache && cd no-cache

~/no-cache $ time RAILS_ENV=production bin/rake assets:precompile
# Observe long compile time, even though tmp/cache is in place
# and no assets have changed
```

## Profiling

The `assets:precompile:profile` rake task can be used to see where time is being spent:

```sh
~/test-3.2 $ RAILS_ENV=production bin/rake assets:precompile:profile
I, [2015-07-31T15:23:39.074165 #39415]  INFO -- : Writing /Users/david/Development/slow-deploys/test-3.2/public/assets/application-47e3846a90680e1d494256b1e67f4c6c7d988a75c1bc9b56aa4942c148d25d23.js
I, [2015-07-31T15:23:39.196086 #39415]  INFO -- : Writing /Users/david/Development/slow-deploys/test-3.2/public/assets/application-e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855.css
==================================
  Mode: wall(1000)
  Samples: 5514 (93.27% miss rate)
  GC: 660 (11.97%)
==================================
     TOTAL    (pct)     SAMPLES    (pct)     FRAME
      2242  (40.7%)        1177  (21.3%)     Sprockets::PathUtils#atomic_write
       810  (14.7%)         685  (12.4%)     block in FileUtils#mv
      2882  (52.3%)         469   (8.5%)     Sprockets::Cache::FileStore#set
       382   (6.9%)         382   (6.9%)     block in Digest::Instance#file
       280   (5.1%)         266   (4.8%)     Sprockets::Mime#read_file
       259   (4.7%)         232   (4.2%)     Sprockets::DigestUtils#digest
       138   (2.5%)         138   (2.5%)     block (4 levels) in Sprockets::Mime#compute_extname_map
       105   (1.9%)         105   (1.9%)     URI::RFC3986_Parser#split
        97   (1.8%)          97   (1.8%)     block in Sprockets::Cache::FileStore#set
        78   (1.4%)          66   (1.2%)     FileUtils::Entry_#lstat
        69   (1.3%)          65   (1.2%)     FileUtils#fu_mkdir
        62   (1.1%)          62   (1.1%)     URI::RFC2396_Parser#escape
        73   (1.3%)          60   (1.1%)     FileUtils#fu_check_options
       912  (16.5%)          54   (1.0%)     FileUtils#fu_each_src_dest0
        70   (1.3%)          48   (0.9%)     Sprockets::Cache::FileStore#safe_open
        48   (0.9%)          48   (0.9%)     FileUtils#fu_same?
        40   (0.7%)          40   (0.7%)     rescue in block in FileUtils#mkdir_p
        38   (0.7%)          38   (0.7%)     URI::RFC2396_Parser#unescape
        36   (0.7%)          36   (0.7%)     Sprockets::PathUtils#path_extnames
        30   (0.5%)          30   (0.5%)     Set#include?
        29   (0.5%)          29   (0.5%)     rescue in FileUtils::Entry_#exist?
        29   (0.5%)          29   (0.5%)     block (2 levels) in <class:Numeric>
        28   (0.5%)          28   (0.5%)     Sprockets::PathUtils#stat
        53   (1.0%)          25   (0.5%)     Sprockets::CachedEnvironment#stat
       156   (2.8%)          25   (0.5%)     Sprockets::URIUtils#split_file_uri
       405   (7.3%)          23   (0.4%)     Digest::Instance#file
        21   (0.4%)          21   (0.4%)     block in FileUtils#fu_list
        54   (1.0%)          19   (0.3%)     block in Sprockets::URIUtils#encode_uri_query_params
        19   (0.3%)          19   (0.3%)     Sprockets::PathUtils#split_subpath
        18   (0.3%)          18   (0.3%)     FileUtils::Entry_#initialize
```
