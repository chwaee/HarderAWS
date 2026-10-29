provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "harderaws"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

provider "aws" {
  alias  = "additional"
  region = var.additional_regions[0]

  default_tags {
    tags = {
      Project     = "harderaws"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
