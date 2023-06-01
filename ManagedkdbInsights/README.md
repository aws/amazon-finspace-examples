# Projects
- [basic_tick](basic_tick)
- [boto](boto)

# Important notes

The parent directory contains common python scripts and symlinks to aws environment files (config and credentials). 

# Appendix

## requirements.txt
```
pip freeze > ~/ManagedKdbInsights/requirements.txt
```

## tarball creation
```
cd ~/
pip freeze > ~/ManagedKdbInsights/requirements.txt
tar --exclude="*.ipynb_checkpoints*" --exclude="*__pycache__*" -czvf ~/ManagedKdbInsights.tar.gz ManagedKdbInsights 
```

## zip creations
REMEMBER, the zip knows the paths, the filename does not determine the directories!  

```
zip -r -X code.zip code -x '*.ipynb_checkpoints*'
```
