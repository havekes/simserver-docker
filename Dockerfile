FROM debian:latest AS build

ARG REVISION=10420

WORKDIR /simutrans

RUN apt-get update && apt-get -y install build-essential subversion zlib1g-dev libbz2-dev libpng-dev curl unzip
RUN svn co --username anon -r $REVISION svn://servers.simutrans.org/simutrans/trunk

WORKDIR /simutrans/trunk

COPY config.default .

RUN make -j$(nproc)
RUN strip build/default/sim
RUN ./get_lang_files.sh

FROM debian:latest

ENV PORT=13353
ENV LANG=en
ENV DEBUG=0
ENV PAK=pak128

WORKDIR /simutrans

COPY --from=build /simutrans/trunk/simutrans .
COPY --from=build /simutrans/trunk/build/default/sim .

ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
CMD ["/simutrans/sim", "-server", "$PORT", "-nosound", "-nomidi", "-noaddons", "-lang", "$LANG", "-objects", "$PAK", "-debug", "$DEBUG"]
