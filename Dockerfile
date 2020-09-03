# Mount the local socket and kolla directory
# E.g: docker build -t kolla . && docker run  -v `pwd`:/usr/local/share/kolla -v /var/run/docker.sock:/var/run/docker.sock -v <kolla-config-dir>:/etc/kolla -ti kolla
FROM python:2 as wheels

ADD . /kolla
RUN pip wheel -w /wheels /kolla

FROM python:2-slim
LABEL source_repository="https://github.com/sapcc/kolla"

COPY --from=wheels /wheels /wheels
ENV PYTHONDONTWRITEBYTECODE=1
RUN apt-get update && apt-get install -y git && apt-get clean && rm -fr /var/lib/apt/lists/* && pip install --no-cache-dir --no-compile --no-index /wheels/* && rm -fr /wheels && ( [ ! -d /usr/local/share/kolla/docker ] || rm -fr /usr/local/share/kolla/docker )
CMD kolla-build
