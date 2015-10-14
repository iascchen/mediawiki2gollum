# Mediawiki2Gollum

It is a internal test version.

Revised from [https://gist.github.com/henare/863476](https://gist.github.com/henare/863476)

I change it for change some link to Chinese pinyin, and handle some picture issues.

## Dockerfile

This docker file revised form [https://hub.docker.com/r/suttang/gollum/](https://hub.docker.com/r/suttang/gollum/)

I add some need gem pacakge for chinese.

	> docker build -t iasc_gollum .
	
	> sudo docker run -d -P -v /data/website/wikidata:/root/wikidata -v /root/source:/root/source -p 8081:4567 --name gollum iasc_gollum
	> docker exec -it  -w /root/wikidata gollum bash

## Run

This tool write in ruby. **it is not fullly tested.** 

## Download the files

	git clone https://github.com/iascchen/mediawiki2gollum.git

## Run it

	ruby mw-to-gollum.rb --file current.xml --directory wiki
	
## Copy to gollum folder

	cp -rf wiki/* /data/website/wikidata/	
	
# Other 

Here is another tool in Python. I don't test it. 
	https://github.com/brandonheller/mediawiki_to_gollum