
https://vijayredkar.medium.com/banknext-casestudy-genai-multi-vectordb-switch-automation-34d41b7127f1

---- clean up commands

docker ps 
docker stop 536373
docker kill 736363
docker rm 466343

docker network ls
NETWORK ID     NAME         DRIVER    SCOPE
72aec4bc8069   bridge       bridge    local
965c289546d4   host         host      local
70c45221dd1f   my_network   bridge    local
60ab42406d58   none         null      local

docker network rm  70c45221dd1f


-only if reqd
docker stop $(docker ps -q)      [Stop all running containers]
docker rm $(docker ps -a -q)	 [Remove all containers]



---- launch commands

-network create:
docker network create my_network


-DB launch:
docker run -d --name chromadb  -p 8000:8000 chromadb/chroma				[standalone DB-> cannot connect to vector DB or file system]
docker run -d --name chromadb --network my_network -p 8000:8000 chromadb/chroma		[DB + network -> can connect to vector DB but not filesystem]	
[DB + network -> can connect to vector DB + filesystem]
docker run -d --name chromadb --network my_network -v C:\Vijay\Java\projects\openapi-ai-trials\LLM-gen-ai\langchain4j\gen-ai-local-vectordb-automation-dockerized\training-docs:/docs-repo -p 8000:8000 chromadb/chroma

-DB launch all:
docker run -d --name chromadb --network my_network -v C:\Vijay\Java\projects\openapi-ai-trials\LLM-gen-ai\langchain4j\gen-ai-local-vectordb-automation-dockerized\training-docs:/docs-repo -p 8000:8000 chromadb/chroma
docker run -d --name redis --network my_network -v C:\Vijay\Java\projects\openapi-ai-trials\LLM-gen-ai\langchain4j\gen-ai-local-vectordb-automation-dockerized\training-docs:/docs-repo -p 6379:6379  redis/redis-stack-server:latest
docker run -d --name weaviate --network my_network -v C:\Vijay\Java\projects\openapi-ai-trials\LLM-gen-ai\langchain4j\gen-ai-local-vectordb-automation-dockerized\training-docs:/docs-repo -p 50051:50051 cr.weaviate.io/semitechnologies/weaviate:1.27.6
docker run -d --name qdrant --network my_network -v C:\Vijay\Java\projects\openapi-ai-trials\LLM-gen-ai\langchain4j\gen-ai-local-vectordb-automation-dockerized\training-docs:/docs-repo -p 6334:6334 -v /c/qdrant/data:z qdrant/qdrant
docker run -d --name elasticsearch --network my_network -v C:\Vijay\Java\projects\openapi-ai-trials\LLM-gen-ai\langchain4j\gen-ai-local-vectordb-automation-dockerized\training-docs:/docs-repo -p 9200:9200 -p 9300:9300 -e discovery.type=single-node -e xpack.security.enabled=false docker.elastic.co/elasticsearch/elasticsearch:8.9.0


-app launch:
cd C:\Vijay\Java\projects\openapi-ai-trials\LLM-gen-ai\langchain4j\gen-ai-local-vectordb-automation-dockerized
mvn clean install
docker build -t gen-ai-local-vectordb-automation .
docker run -d --name springboot-app -p 8888:8888 gen-ai-local-vectordb-automation						   [standalone app -> cannot connect to vector DB or file system]
docker run -d --name springboot-app --network my_network -p 8888:8888 gen-ai-local-vectordb-automation				   [app + network -> can connect to vector DB but not filesystem]	
#docker run -d --name springboot-app --network my_network -v shared_volume:/docs-repo -p 8888:8888 gen-ai-local-vectordb-automation [app + network -> can connect to vector DB + filesystem]
[app + network -> can connect to vector DB + filesystem]
docker run -d --name springboot-app --network my_network -v C:\Vijay\Java\projects\openapi-ai-trials\LLM-gen-ai\langchain4j\gen-ai-local-vectordb-automation-dockerized\training-docs:/docs-repo -p 8888:8888 gen-ai-local-vectordb-automation


-test files:
copy test pdf/txt/csv test docs in to 
C:\Vijay\Java\projects\openapi-ai-trials\LLM-gen-ai\langchain4j\gen-ai-local-vectordb-automation-dockerized\training-docs   [mapped to the name /docs-repo inside docker console]
All docker containers launched with the mount volume will have access to this Windows dir.


-docker console:
docker exec -it springboot-app /bin/sh            [access app through the docker console]
touch /docs-repo/test-1.txt			  [manually create an empty file, if needed]
cd docs-repo
echo Hello World >> test-1.txt			  [add content to the file, if needed]    vi nano does not work

sh-4.4# ls -lrt docs-repo/			  [maps to C:\Vijay\Java\projects\openapi-ai-trials\LLM-gen-ai\langchain4j\gen-ai-local-vectordb-automation-dockerized\training-docs]
total 212
-rwxrwxrwx 1 root root   3265 Dec 20 10:21 PCI-DSS-4.txt
-rwxrwxrwx 1 root root   3265 Dec 20 10:22 PCI-DSS-4.csv
-rwxrwxrwx 1 root root 206962 Dec 20 15:37 PCI-DSS-4.pdf
drwxrwxrwx 1 root root   4096 Jan 14 15:38 format-csv
drwxrwxrwx 1 root root   4096 Jan 14 15:38 format-pdf
drwxrwxrwx 1 root root   4096 Jan 14 15:38 format-txt
sh-4.4#


-codebase adjustments for docker env:
ContextLoadService - change DB base URLs from localhost to :
http://chromadb:8000
http://redis:6379
http://elasticsearch:9200

Utils.java  - use mounted shared filesystem
/docs-repo/available-vectordbs.txt

-app logs:
docker logs 589e56cc6e92 -f --tail 100

-run Swagger test:
http://localhost:8888/swagger-ui/index.html

POST /gen-ai/v1/llm/document-extracts
fileNameWithFullPath = docs-repo/PCI-DSS-4.pdf
title = PCI-A

GET  /gen-ai/v1/llm/extracts
vectorDbMetadataPath = /docs-repo/PCI-A

response o/p
generic-11273956 generic-1647728261 generic-1335479731 generic-205794901



-Port the docker image 						[to transfer to some other machine]
docker save -o gen-ai-local-vectordb-automation.tar gen-ai-local-vectordb-automation 	[create the portable .tar file]
docker load -i gen-ai-local-vectordb-automation.tar      			[copy the .tar to the other machine]
docker run gen-ai-local-vectordb-automation				[launch the dockerized app]
