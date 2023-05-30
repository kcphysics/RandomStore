resource "aws_dynamodb_table" "devRandomStore" {
    name = "devRandomStore"
    billing_mode = "PROVISIONED"
    read_capacity = 1
    write_capacity = 1
    hash_key = "StoreID"

    attribute {
        name = "StoreID"
        type = "S"
    }

    ttl {
        attribute_name = "ExpiresAt"
        enabled = true
    }

    tags = {
        Project = "RandomStore"
        Environment = "Dev"
    }
}