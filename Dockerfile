################################################################################
# builder
################################################################################
FROM python:3.12-slim as builder

RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    tzdata

COPY ./requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

################################################################################
# development
################################################################################
FROM python:3.12-slim as dev

COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/lib /usr/local/lib

RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    git

COPY ./requirements.dev.txt /tmp/requirements.dev.txt
RUN pip install --no-cache-dir -r /tmp/requirements.dev.txt

RUN git config --global --add safe.directory /workspace

################################################################################
# testing
################################################################################
FROM python:3.12-slim as test

ENV TZ Asia/Tokyo

COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/lib /usr/local/lib
RUN pip install --no-cache-dir pytest

COPY ./app/src /app/src
COPY ./app/assets /app/assets
COPY ./app/test /app/test
CMD ["pytest"]

################################################################################
# production
################################################################################
FROM python:3.12-slim as prod

ENV TZ Asia/Tokyo

COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/lib /usr/local/lib

COPY ./app/src /app/src
COPY ./app/assets /app/assets
CMD ["echo", "app is running correctly."]
