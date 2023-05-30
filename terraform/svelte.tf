resource "aws_s3_bucket" "devRandomStoreBucket" {
    bucket = "dev.randomstore.scselvy.com"
    tags = {
        Project = "RandomStore"
        Environment = "Dev"
    }
}

resource "aws_s3_bucket_public_access_block" "devRandomStoreS3Access" {
    bucket = aws_s3_bucket.devRandomStoreBucket.id
    block_public_acls = false
    block_public_policy = false
}

resource "aws_s3_object" "JSFile" {
    for_each = fileset("/RandomStore/RandomStore/dist/", "**/*.js")
    bucket = aws_s3_bucket.devRandomStoreBucket.id
    key = each.value
    source = "/RandomStore/RandomStore/dist/${each.value}"
    etag = filemd5("/RandomStore/RandomStore/dist/${each.value}")
    content_type = "text/javascript"
}

resource "aws_s3_object" "CSSFile" {
    for_each = fileset("/RandomStore/RandomStore/dist/", "**/*.css")
    bucket = aws_s3_bucket.devRandomStoreBucket.id
    key = each.value
    source = "/RandomStore/RandomStore/dist/${each.value}"
    etag = filemd5("/RandomStore/RandomStore/dist/${each.value}")
    content_type = "text/css"
}

resource "aws_s3_object" "HTMLFiles" {
    for_each = fileset("/RandomStore/RandomStore/dist/", "**/*.html")
    bucket = aws_s3_bucket.devRandomStoreBucket.id
    key = each.value
    source = "/RandomStore/RandomStore/dist/${each.value}"
    etag = filemd5("/RandomStore/RandomStore/dist/${each.value}")
    content_type = "text/html"
}

resource "aws_s3_object" "PNGFiles" {
    for_each = fileset("/RandomStore/RandomStore/dist/", "**/*.png")
    bucket = aws_s3_bucket.devRandomStoreBucket.id
    key = each.value
    source = "/RandomStore/RandomStore/dist/${each.value}"
    etag = filemd5("/RandomStore/RandomStore/dist/${each.value}")
    content_type = "image/png"
}

data "aws_iam_policy_document" "devRandomStoreS3PolicyDoc" {
    statement {
        principals {
            type = "*"
            identifiers = ["*"]
        }
        actions = [
            "s3:GetObject"
        ]
        resources = [
            "${aws_s3_bucket.devRandomStoreBucket.arn}/*"
        ]
    }
}

resource "aws_s3_bucket_website_configuration" "devRandomStoreS3Website" {
    bucket = aws_s3_bucket.devRandomStoreBucket.id
    index_document {
      suffix = "index.html"
    }
    error_document {
      key = "index.html"
    }
}

resource "aws_s3_bucket_policy" "devRandomStoreS3Policy" {
    bucket = aws_s3_bucket.devRandomStoreBucket.id
    policy = data.aws_iam_policy_document.devRandomStoreS3PolicyDoc.json
}

resource "aws_cloudfront_distribution" "devRandomStoreCFDist" {
    origin {
        domain_name = aws_s3_bucket.devRandomStoreBucket.bucket_regional_domain_name
        origin_id =  aws_s3_bucket.devRandomStoreBucket.bucket_regional_domain_name
    }
    enabled = true
    is_ipv6_enabled = true
    default_root_object = "index.html"
    aliases = [
        "dev.randomstore.scselvy.com"
    ]
    default_cache_behavior {
        allowed_methods = ["GET", "HEAD", "OPTIONS"]
        cached_methods = ["GET", "HEAD", "OPTIONS"]
        target_origin_id = aws_s3_bucket.devRandomStoreBucket.bucket_regional_domain_name
        viewer_protocol_policy = "redirect-to-https"
        forwarded_values {
            query_string = true
            cookies {
                forward = "none"
            }
        }
    }

    restrictions {
      geo_restriction {
        locations = []
        restriction_type = "none"
      }
    }

    viewer_certificate {
        acm_certificate_arn = local.dev_certificate_arn
        ssl_support_method = "sni-only"
        minimum_protocol_version = "TLSv1.2_2021"
    }

    tags = {
        Project = "RandomStore"
        Environment = "Dev"
    }
}

resource "aws_route53_record" "devRandomStoreCFDNS" {
    name = "dev.randomstore.scselvy.com"
    type = "A"
    zone_id = "Z07600102Y2PN0W4J333F"

    alias {
        evaluate_target_health = true
        name = aws_cloudfront_distribution.devRandomStoreCFDist.domain_name
        zone_id = aws_cloudfront_distribution.devRandomStoreCFDist.hosted_zone_id
    }
}