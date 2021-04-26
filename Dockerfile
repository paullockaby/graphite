FROM python:3.9.4-alpine@sha256:2a9b93b032246dabbec008c1527bd0ef31947e7fd351a200aec5a46eea68d776 AS base

# github metadata
LABEL org.opencontainers.image.source https://github.com/paullockaby/graphite

FROM base AS builder

# packages needed for building this thing
RUN apk add --no-cache curl postgresql-dev cairo-dev gcc musl-dev

# install python dependencies
COPY requirements.txt /
RUN python3 -m venv --system-site-packages /opt/graphite && \
    source /opt/graphite/bin/activate && \
    pip3 install --no-cache-dir -r /requirements.txt

# install current version of graphite
ENV VERSION=1.1.8
RUN mkdir -p /usr/local/src && cd /usr/local/src && \
  curl -OJL https://github.com/graphite-project/whisper/archive/${VERSION}.tar.gz && \
  curl -OJL https://github.com/graphite-project/graphite-web/archive/${VERSION}.tar.gz && \
  tar zxf whisper-${VERSION}.tar.gz && \
  tar zxf graphite-web-${VERSION}.tar.gz && \
  source /opt/graphite/bin/activate && \
  cd /usr/local/src/whisper-$VERSION && python3 ./setup.py install && \
  cd /usr/local/src/graphite-web-$VERSION && python3 ./setup.py install --install-lib /opt/graphite/webapp && \
  true

FROM base AS final

# packages needed to run this thing
RUN apk add --no-cache tini expect libpq cairo

# copy the virtual environment that we just built
COPY --from=builder /opt /opt

## set up custom scripts for setting up django
RUN cd /opt/graphite/webapp/graphite && ln -s /opt/graphite/conf/local_settings.py
COPY customauth.py /opt/graphite/webapp/graphite/customauth.py

# this creates a new blank user
COPY django_admin_init.exp /opt/graphite/bin
RUN chmod +x /opt/graphite/bin/django_admin_init.exp

# install the entrypoint last to help with caching
COPY entrypoint /
RUN chmod +x /entrypoint

VOLUME ["/opt/graphite/conf", "/opt/graphite/storage"]
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint"]
