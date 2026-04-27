terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ─────────────────────────────────────────────────────────────────
# LOCAL VALUES
# Shared tag base applied to every resource in this project.
# ─────────────────────────────────────────────────────────────────
locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    CostCenter  = var.cost_center
    Owner       = var.owner
  }
}

# ─────────────────────────────────────────────────────────────────
# RAW INSTRUMENT BUCKETS (×7)
# Each bucket maps to one band of the electromagnetic spectrum
# and its corresponding Radiant imaging modality.
# ─────────────────────────────────────────────────────────────────

# X-Ray Satellite Feed → Radiant Parallel: X-Ray / CT studies
resource "aws_s3_bucket" "raw_xray" {
  bucket = "maxwell-obs-raw-xray-prod"
  tags = merge(local.common_tags, {
    InstrumentType  = "xray"
    DataClassification = "raw"
    RadiantParallel = "dicom-study"
  })
}

# Gamma Ray Burst Detector → Radiant Parallel: PET / Nuclear Medicine
resource "aws_s3_bucket" "raw_gamma" {
  bucket = "maxwell-obs-raw-gamma-prod"
  tags = merge(local.common_tags, {
    InstrumentType  = "gamma"
    DataClassification = "raw"
    RadiantParallel = "dicom-study"
  })
}

# Radio Array → Radiant Parallel: MRI (radio waves interact with hydrogen protons)
resource "aws_s3_bucket" "raw_radio" {
  bucket = "maxwell-obs-raw-radio-prod"
  tags = merge(local.common_tags, {
    InstrumentType  = "radio"
    DataClassification = "raw"
    RadiantParallel = "dicom-study"
  })
}

# Optical Telescope → Radiant Parallel: Fluoroscopy (real-time visual imaging)
resource "aws_s3_bucket" "raw_optical" {
  bucket = "maxwell-obs-raw-optical-prod"
  tags = merge(local.common_tags, {
    InstrumentType  = "optical"
    DataClassification = "raw"
    RadiantParallel = "dicom-study"
  })
}

# Infrared Telescope → Radiant Parallel: Thermal imaging
resource "aws_s3_bucket" "raw_infrared" {
  bucket = "maxwell-obs-raw-infrared-prod"
  tags = merge(local.common_tags, {
    InstrumentType  = "infrared"
    DataClassification = "raw"
    RadiantParallel = "dicom-study"
  })
}

# Ultraviolet Monitor → Radiant Parallel: Bone density / surface imaging
resource "aws_s3_bucket" "raw_uv" {
  bucket = "maxwell-obs-raw-uv-prod"
  tags = merge(local.common_tags, {
    InstrumentType  = "uv"
    DataClassification = "raw"
    RadiantParallel = "dicom-study"
  })
}

# Microwave CMB Detector → Radiant Parallel: Baseline calibration / microwave ablation
resource "aws_s3_bucket" "raw_microwave" {
  bucket = "maxwell-obs-raw-microwave-prod"
  tags = merge(local.common_tags, {
    InstrumentType  = "microwave"
    DataClassification = "raw"
    RadiantParallel = "dicom-study"
  })
}

# ─────────────────────────────────────────────────────────────────
# OPERATIONAL PIPELINE BUCKETS
# ─────────────────────────────────────────────────────────────────

# Signal Processing Logs → Radiant Parallel: HL7 ORM/ORU message logs
resource "aws_s3_bucket" "signal_logs" {
  bucket = "maxwell-obs-signal-logs-prod"
  tags = merge(local.common_tags, {
    InstrumentType     = "all"
    DataClassification = "operational"
    RadiantParallel    = "hl7-log"
  })
}

# Processed Results → Radiant Parallel: PACS processed imaging results
resource "aws_s3_bucket" "processed_results" {
  bucket = "maxwell-obs-processed-results-prod"
  tags = merge(local.common_tags, {
    InstrumentType     = "all"
    DataClassification = "processed"
    RadiantParallel    = "pacs-results"
  })
}

# Final Observation Reports → Radiant Parallel: Signed radiology reports
resource "aws_s3_bucket" "final_reports" {
  bucket = "maxwell-obs-final-reports-prod"
  tags = merge(local.common_tags, {
    InstrumentType     = "all"
    DataClassification = "published"
    RadiantParallel    = "radiology-report"
  })
}

# Critical Event Alerts → Radiant Parallel: STAT critical value alerts
resource "aws_s3_bucket" "critical_alerts" {
  bucket = "maxwell-obs-critical-alerts-prod"
  tags = merge(local.common_tags, {
    InstrumentType     = "all"
    DataClassification = "operational"
    RadiantParallel    = "critical-value-alert"
  })
}

# Dosimetry Exposure Logs → Radiant Parallel: Patient radiation dose record
resource "aws_s3_bucket" "dosimetry_logs" {
  bucket = "maxwell-obs-dosimetry-logs-prod"
  tags = merge(local.common_tags, {
    InstrumentType     = "all"
    DataClassification = "restricted"
    RadiantParallel    = "dose-record"
  })
}

# Compliance Audit Logs → Radiant Parallel: HIPAA audit trail
resource "aws_s3_bucket" "audit_logs" {
  bucket = "maxwell-obs-audit-logs-prod"
  tags = merge(local.common_tags, {
    InstrumentType     = "all"
    DataClassification = "audit"
    RadiantParallel    = "hipaa-audit-trail"
  })
}

# ─────────────────────────────────────────────────────────────────
# VERSIONING
# Enabled on all buckets. In a Radiant environment, overwriting a
# finalized report or imaging file is a compliance violation.
# Versioning preserves every object state for audit purposes.
# ─────────────────────────────────────────────────────────────────

locals {
  all_buckets = [
    aws_s3_bucket.raw_xray.id,
    aws_s3_bucket.raw_gamma.id,
    aws_s3_bucket.raw_radio.id,
    aws_s3_bucket.raw_optical.id,
    aws_s3_bucket.raw_infrared.id,
    aws_s3_bucket.raw_uv.id,
    aws_s3_bucket.raw_microwave.id,
    aws_s3_bucket.signal_logs.id,
    aws_s3_bucket.processed_results.id,
    aws_s3_bucket.final_reports.id,
    aws_s3_bucket.critical_alerts.id,
    aws_s3_bucket.dosimetry_logs.id,
    aws_s3_bucket.audit_logs.id,
  ]
}

resource "aws_s3_bucket_versioning" "all" {
  for_each = toset(local.all_buckets)
  bucket   = each.value
  versioning_configuration {
    status = "Enabled"
  }
}

# ─────────────────────────────────────────────────────────────────
# BLOCK PUBLIC ACCESS
# All buckets are private. This mirrors HIPAA requirements where
# patient data and system logs must never be publicly accessible.
# ─────────────────────────────────────────────────────────────────

resource "aws_s3_bucket_public_access_block" "all" {
  for_each                = toset(local.all_buckets)
  bucket                  = each.value
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ─────────────────────────────────────────────────────────────────
# SERVER-SIDE ENCRYPTION
# SSE-S3 encrypts all objects at rest automatically.
# Mirrors HIPAA encryption requirements for PHI at rest.
# ─────────────────────────────────────────────────────────────────

resource "aws_s3_bucket_server_side_encryption_configuration" "all" {
  for_each = toset(local.all_buckets)
  bucket   = each.value
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
