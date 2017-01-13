FROM python:3

ADD . /kolla
RUN pip install --no-cache-dir -e /kolla
CMD /kolla/tools/build.py
