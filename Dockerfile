# ===============================
# Overleaf Custom - UFPEL Edition
# Autor: Pablo De Chiaro Rosa
# Base: sharelatex/sharelatex:5.5.4
# Objetivo: Ambiente LaTeX completo com suporte ao português, pacotes acadêmicos e PDF moderno
# ===============================

FROM sharelatex/sharelatex:5.5.4

# ---------------------------
# Atualiza o TeX Live e instala pacotes essenciais
# ---------------------------
RUN tlmgr update --self && \
    tlmgr install \
        babel-portuges \
        lastpage \
        chngcntr \
        titlesec \
        setspace \
        changepage \
        caption \
        listings \
        pdfpages \
        minted \
        upquote \
        lineno \
        pdflscape \
        pdfmanagement-testphase \
        tagpdf \
        l3experimental \
        collection-fontsrecommended && \
    mktexlsr && \
    fmtutil-sys --byfmt pdflatex && \
    fmtutil-sys --all

# ---------------------------
# Dependência do pacote minted (requer Pygments)
# ---------------------------
RUN apt-get update && \
    apt-get install -y python3-pygments && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ---------------------------
# Reconstrução de formatos e cache de fontes
# ---------------------------
RUN mktexlsr && \
    fmtutil-sys --all