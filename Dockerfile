ARG GO_VERSION=1.25
FROM --platform=$BUILDPLATFORM golang:${GO_VERSION}-alpine AS builder
WORKDIR /app

ARG GOPRIVATE
ENV GOPRIVATE=$GOPRIVATE

COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download -x

COPY . .

RUN test -d hello || (echo "missing 'hello/' in image (check build context)" && exit 1)

ARG TARGETOS TARGETARCH
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    go build -ldflags="-s -w" -o server ./.

FROM gcr.io/distroless/static-debian12:latest
WORKDIR /app
COPY --from=builder /app/server /app/server
EXPOSE 50051
USER 65532:65532
ENTRYPOINT ["/app/server"]