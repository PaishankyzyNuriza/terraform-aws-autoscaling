// Launch template 
resource "aws_launch_template" "template" {
  name = "nuriza-template"
  image_id           = "ami-068e3d6bc44010346"
  instance_type = "t2.micro"
  user_data =base64encode(file("user_data.sh"))

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.my_webserver.id]
  }
   tags = {
    Name = "template"
   }
}

resource "aws_security_group" "my_webserver" {
  
  name        = "WebServer Security Group"
  description = "My First SecurityGroup"
  vpc_id      = var.vpc_id
   dynamic "ingress" {
    for_each = [ "80", "22"]
    content {
      from_port = ingress.value
      to_port = ingress.value
        protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
    }
   }
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 }

 



//AUTO_SCALING
resource "aws_autoscaling_group" "auto_scaling" {
  min_size             = 1
  max_size             = 3
  desired_capacity     = var.desired
  launch_template {
    id      = aws_launch_template.template.id
  }

  target_group_arns = [aws_lb_target_group.target.arn]
  vpc_zone_identifier  =var.subnet_ids
 
}
//TARGET
resource "aws_lb_target_group" "target" {
  name     = "target"
  port     = 80
  protocol = "HTTP"
  vpc_id     = var.vpc_id
}


//LISTENER
resource "aws_lb_listener" "lb-listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target.arn
  }
}
//LB
resource "aws_lb" "lb" {
  name               = "lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_webserver.id]
  subnets = var.subnet_ids
  enable_http2       = false
}
