ps:
	ps aux | grep -v grep | grep chainspace | awk '{print $2 " " $11 " " $12 " " $13}'

list-nodes:
	screen -list

build-jar:
	cd chainspacecore && mvn -Dversion=1.0-SNAPSHOT package assembly:single

start-nodes:
	./contrib/core-tools/easystart.mac.sh

tail-node:
	tail -f chainspacecore-0-0/screenlog.0

start-client:
	cd chainspacecore && ./runclientservice.sh

kill-all:
	ps aux | grep -v grep | grep chainspace | awk '{print $2}' | xargs kill




