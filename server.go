package main

import (
	"context"
	"go-grpc-server/hello"
	"log"
	"net"

	"google.golang.org/grpc"
)

type server struct {
	hello.UnimplementedHelloServiceServer
}

func (s *server) SayHello(_ context.Context, req *hello.HelloRequest) (*hello.HelloResponse, error) {
	log.Printf("Received request for: %s", req.Name)
	return &hello.HelloResponse{Message: "Hello, " + req.Name + "!"}, nil
}

func main() {
	lis, err := net.Listen("tcp", ":50051")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
	grpcServer := grpc.NewServer()
	hello.RegisterHelloServiceServer(grpcServer, &server{})
	log.Println("gRPC server listening on :50051")
	if err := grpcServer.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
