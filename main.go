package main

import (
	"context"
	"log"
	"net"

	pb "github.com/wbenfatto/go-grpc-server/hello"

	"google.golang.org/grpc"
)

type server struct {
	pb.UnimplementedHelloServiceServer
}

func (s *server) SayHello(_ context.Context, req *pb.HelloRequest) (*pb.HelloResponse, error) {
	log.Printf("Received request for: %s", req.Name)
	return &pb.HelloResponse{Message: "Hello, " + req.Name + "!"}, nil
}

func main() {
	lis, err := net.Listen("tcp", ":50051")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
	grpcServer := grpc.NewServer()
	pb.RegisterHelloServiceServer(grpcServer, &server{})
	log.Println("gRPC server listening on :50051")
	if err := grpcServer.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
