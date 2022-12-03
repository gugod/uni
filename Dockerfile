FROM docker.io/perl:5.36
WORKDIR /app

ADD cpanfile /app/
RUN cpanm --notest --quiet App::cpm && \
    cpm install -g && \
    rm -rf /root/.cpanm /root/.perl-cpm

ADD . /app

EXPOSE 8000
CMD plackup --listen localhost:8000 --env production app.psgi
