variable "vpc_id" {
    type =string
}
variable "subnet_ids" {
   type = list(string)
   default = []
}
variable "desired" {
    type = number
}