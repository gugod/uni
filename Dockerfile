FROM docker.io/perl:5.38
WORKDIR /app

ADD cpanfile /app/
RUN cpanm --notest --quiet App::cpm && \
    cpm install -g && \
    rm -rf /root/.cpanm /root/.perl-cpm

ADD . /app

EXPOSE 8000
CMD plackup --port 8000 -e 'enable "AccessLog"' --env deployment app.psgi
