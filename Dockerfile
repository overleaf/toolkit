FROM sharelatex/sharelatex:6.2.2

# Upgrade and install full TeXLive scheme
RUN tlmgr update --self && \
    tlmgr install scheme-full && \
    tlmgr path add
    