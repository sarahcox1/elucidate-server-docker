# elucidate-server-docker

Docker configuration for running Elucidate.

## Installation

```
git clone https://github.com/dlcs/elucidate-database-docker
cd elucidate-database-docker
git submodule init
sudo docker build -t elucidate-database .
sudo docker run -d \
	--name elucidate-database \
	--env POSTGRES_PASSWORD=<YOUR DB PASSWORD> \
	--user postgres \
	elucidate-database

cd ..
git clone https://github.com/dlcs/elucidate-server-docker
cd elucidate-server-docker
git submodule init
sudo docker build -t elucidate .
sudo docker run -d \
        --name elucidate-server \
        --env S3_SETTINGS='s3://<YOUR SETTINGS BUCKET AND KEY HERE>' \
        --env S3_LOG_SETTINGS='s3://<YOUR LOG4J SETTINGS BUCKET AND KEY HERE>' \
        --link elucidate-database:elucidate-database \
        -p=8080:8080 \
        elucidate \
        /opt/elucidate/run_elucidate.sh
```

## Testing

```
curl -X POST -H 'Accept: application/ld+json; profile="http://www.w3.org/ns/anno.jsonld"' -H 'Content-Type: application/ld+json; profile="http://www.w3.org/ns/anno.jsonld"' --data '{"@context": "http://www.w3.org/ns/anno.jsonld", "type": "AnnotationCollection", "label": "Steampunk Annotations", "creator": "http://example.com/publisher"}' http://localhost:8080/annotation/w3c/
```

Should return:
```
{
  "@context" : "http://www.w3.org/ns/anno.jsonld",
  "id" : "http://localhost:8080/annotation/w3c/<ANNOTATION LIST GUID>/",
  "type" : "AnnotationCollection",
  "creator" : "http://example.com/publisher",
  "label" : "Steampunk Annotations",
  "first" : {
    "type" : "AnnotationPage",
    "as:items" : {
      "@list" : [ ]
    },
    "partOf" : "http://localhost:8080/annotation/w3c/<ANNOTATION LIST GUID>/",
    "startIndex" : 0
  },
  "last" : "http://localhost:8080/annotation/w3c/<ANNOTATION LIST GUID>/?page=0&desc=1",
  "total" : 0
}
```

```
curl -X POST -H 'Accept: application/ld+json; profile="http://www.w3.org/ns/anno.jsonld"' -H 'Content-Type: application/ld+json; profile="http://www.w3.org/ns/anno.jsonld"' --data '{"context": "http://www.w3.org/ns/anno.jsonld", "id": "http://example.org/anno1", "type": "Annotation", "body": "http://example.org/post1", "target": "http://example.com/page1"}' http://localhost:8080/annotation/w3c/<ANNOTATION LIST GUID>/
```

Should return:
```
{
 "@context" : "http://www.w3.org/ns/anno.jsonld",
 "id" : "http://localhost:8080/annotation/w3c/<ANNOTATION LIST GUID>/<ANNOTATION GUID>",
 "type" : "Annotation",
 "body" : "http://example.org/post1",
 "target" : "http://example.com/page1",
 "via" : "http://example.org/anno1"
}
```
