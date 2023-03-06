# Define the provider
provider "aws" {
  region = "us-east-1"
}

# Create a new EC2 instance
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.xlarge"
  key_name      = "my-key-pair"
  security_groups = ["default"]

  tags = {
    Name = "MyEC2Instance"
  }
}
