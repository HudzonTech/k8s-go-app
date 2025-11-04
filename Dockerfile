# Build stage
FROM golang:1.25.3-alpine AS builder
WORKDIR /app
COPY app/src/go.mod app/src/go.sum ./
RUN go mod tidy && go mod download
COPY app/src/ ./
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# Final stage
FROM alpine:3.22.2
RUN apk --no-cache add ca-certificates tzdata curl
WORKDIR /app
COPY --from=builder /app/main .
COPY app/src/version.txt ./version.txt
RUN adduser -D -u 65532 appuser && chown -R appuser:appuser /app
USER 65532:65532
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -fsS http://localhost:8080/health >/dev/null || exit 1
CMD ["./main"]
