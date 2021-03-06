FROM alpine

ENV IP_URLS \
    https://ifconfig.me/ip \
    http://ip1.dynupdate.no-ip.com:8245 \
    http://ip1.dynupdate.no-ip.com \
    https://api.ipify.org \
    https://diagnostic.opendns.com/myip \
    https://domains.google.com/checkip \
    https://ifconfig.io/ip \
    https://ipinfo.io/ip

ENV SOCKS_USER sockd
ENV SOCKS_PASS GENERATE_RANDOM
ENV UPSTREAM_HOST 0.0.0.0
ENV UPSTREAM_PORT 1080
# Automatically kill after 1 hour, set to 0 to disable.
# Supports s(econds), m(inutes), h(ours) and d(ays)
ENV TIMEOUT 1h
ENV PATH="/scripts:${PATH}"

EXPOSE 1080

RUN apk add curl zsh tini pwgen gettext

# Duplicated openvpn and privoxy to only install updates
RUN apk --update --no-cache add dante-server && \
    rm -rf /var/cache/apk/*

RUN mkdir /scripts
COPY /scripts/* /scripts/
RUN chmod +x /scripts/*
WORKDIR /scripts

COPY sockd.conf /etc/sockd.conf.template
COPY sockd_no_auth.conf /etc/sockd_no_auth.conf.template

ENTRYPOINT ["/sbin/tini", "--", "/scripts/main"]
HEALTHCHECK --timeout=5s --interval=30s --start-period=30s --retries=3 CMD /sbin/tini -- /scripts/health
