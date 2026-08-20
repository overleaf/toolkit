FROM sharelatex/sharelatex:6.2.2

RUN tlmgr update --self && \
    tlmgr install scheme-full && \
    tlmgr path add
