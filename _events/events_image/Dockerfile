FROM alpine:latest
RUN apk --no-cache add curl jq
COPY run.sh /run.sh
RUN chmod +x /run.sh
CMD ["/run.sh"]
