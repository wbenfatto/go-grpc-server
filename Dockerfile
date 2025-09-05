ARG TARGETARCH
ARG TARGETOS

FROM --platform=$TARGETOS/$TARGETARCH golang:1.25-alpine AS builder

WORKDIR /app

RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=bind,source=go.mod,target=go.mod \
    --mount=type=bind,source=go.sum,target=go.sum \
    go mod download -x

COPY . .

RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -ldflags="-s -w" -o server

FROM --platform=$TARGETOS/$TARGETARCH gcr.io/distroless/static-debian12:latest

WORKDIR /app

COPY --from=builder /app/server .

EXPOSE 50051

CMD ["/app/server"]