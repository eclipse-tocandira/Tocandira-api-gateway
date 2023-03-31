FROM kong:2.7.1-alpine

USER root

ENV GROUP_ID=1000
ENV USER_ID=1000
ENV KONG_DATABASE="off"
ENV KONG_DECLARATIVE_CONFIG="/etc/kong/kong.yml"

COPY kong.conf /etc/kong/

RUN addgroup -g $GROUP_ID gateway
RUN adduser -D -u $USER_ID -G gateway gateway -s /bin/s

RUN chown -R gateway:gateway /etc/kong/
RUN chown -R gateway:gateway /usr/local/kong/
RUN chown -R gateway:gateway /home/kong/

USER gateway

CMD kong start -c /etc/kong/kong.conf
