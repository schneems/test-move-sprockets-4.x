# Sprockets 3.2 caching

Newer versions of sprockets cache assets based on an asset's
fullpath. In an environment like Heroku, this means that _no caching_
occurs between deploys, because the build directory is prefixed by a
random hash on each subsequent deploy.

This repository is meant to provide a simple and minimal example of
the problem. 500 random JavaScript files of varying length are being
included for demonstration purposes.

## Reproducing

```sh
~/test-3.2 $ time RAILS_ENV=production bin/rake assets:precompile
# Observe long compile time

~/test-3.2 $ time RAILS_ENV=production bin/rake assets:precompile
# Observe short compile time due to cache present in tmp/cache

~/test-3.2 $ cd .. && mv test-3.2 no-cache && cd no-cache

~/no-cache $ time RAILS_ENV=production bin/rake assets:precompile
# Observe long compile time, even though tmp/cache is in place
# and no assets have changed
```
