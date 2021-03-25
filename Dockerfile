FROM alpine:3.13

RUN apk update && apk add --no-cache bash

ADD entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
