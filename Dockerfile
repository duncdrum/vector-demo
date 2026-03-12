# Vector Search Demo — eXist-db app with .xar in autodeploy
FROM existdb/existdb:latest

COPY build/vector-demo-*.xar /exist/autodeploy/

EXPOSE 8080 8443
