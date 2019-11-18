# Build Stage
FROM golang:1.13-alpine AS build-stage

LABEL app="build-oidc-ingress"
LABEL REPO="https://github.com/pwillie/oidc-ingress"

ENV GOROOT=/usr/local/go \
    GOPATH=/gopath \
    GOBIN=/gopath/bin \
    PROJPATH=/gopath/src/github.com/pwillie/oidc-ingress

RUN apk add -U -q --no-progress build-base git
RUN wget -q https://github.com/golang/dep/releases/download/v0.3.2/dep-linux-amd64 -O /usr/local/bin/dep \
 && chmod +x /usr/local/bin/dep

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

WORKDIR /gopath/src/github.com/pwillie/oidc-ingress
ADD . /gopath/src/github.com/pwillie/oidc-ingress

RUN make get-deps && make build-alpine

# Final Stage (pwillie/oidc-ingress)
FROM alpine:3.8

ARG GIT_COMMIT
ARG VERSION
LABEL REPO="https://github.com/pwillie/oidc-ingress"
LABEL GIT_COMMIT=$GIT_COMMIT
LABEL VERSION=$VERSION

RUN apk add -U -q --no-progress ca-certificates

COPY --from=build-stage /gopath/src/github.com/pwillie/oidc-ingress/bin/oidc-ingress /usr/bin/
RUN chmod +x /usr/bin/oidc-ingress

ENTRYPOINT [ "/usr/bin/oidc-ingress" ] 
