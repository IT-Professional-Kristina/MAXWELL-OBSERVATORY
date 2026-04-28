# ==============================================================
# MAXWELL OBSERVATORY -- CLOUDWATCH MONITORING AND ALERTING
# Phase 4: Infrastructure monitoring and compliance logging
#
# Five alarms monitor the MAXWELL environment, each mapping
# directly to a monitoring requirement in Epic Radiant:
#
# 1. Lifecycle config change    -> Unauthorized config change
# 2. Storage capacity spike     -> PACS storage threshold
# 3. Gamma burst threshold      -> STAT critical finding
# 4. Dosimetry access spike     -> Patient dose record access
# 5. Unauthorized report access -> HIPAA access anomaly
#
# CloudTrail provides the HIPAA-equivalent audit trail,
# writing all API activity to the audit logs bucket.
# ==============================================================


# ==============================================================
# SNS TOPIC -- ALERT NOTIFICATION ROUTING
# Radiant parallel: In Basket critical value routing
# All alarms route notifications through this topic.
# Add email subscriptions to receive alert notifications.
# ==============================================================

resource "aws_sns_topic" "maxwell_alerts" {
  name = "maxwell-observatory-alerts"

  tags = merge(local.common_tags, {
    Purpose = "alert-routing"
  })
}


# ==============================================================
# ALARM 1 -- LIFECYCLE CONFIGURATION CHANGE
# Radiant parallel: Unauthorized system configuration change
# Fires when any S3 lifecycle policy is modified.
# Unexpected configuration changes require investigation --
# mirrors Epic change control monitoring requirements.
# ==============================================================

resource "aws_cloudwatch_metric_alarm" "lifecycle_config_change" {
  alarm_name          = "maxwell-lifecycle-config-change-alarm"
  alarm_description   = "Radiant parallel: Unauthorized configuration change monitor. Fires when an S3 lifecycle policy is modified on any MAXWELL bucket. Mirrors Epic Radiant change control monitoring."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "PutBucketLifecycle"
  namespace           = "AWS/S3"
  period              = 86400
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "missing"

  alarm_actions = [aws_sns_topic.maxwell_alerts.arn]
  ok_actions    = [aws_sns_topic.maxwell_alerts.arn]

  tags = merge(local.common_tags, {
    AlarmType       = "configuration-change"
    RadiantParallel = "change-control-monitor"
  })
}


# ==============================================================
# ALARM 2 -- STORAGE CAPACITY SPIKE (RAW X-RAY BUCKET)
# Radiant parallel: PACS storage threshold alert
# Fires when raw X-ray satellite data exceeds 5GB.
# In a real environment raw DICOM data from a busy
# radiology department fills terabytes rapidly.
# NOTE: BucketSizeBytes metric requires data in bucket
# and 24hr collection period to become active.
# ==============================================================

resource "aws_cloudwatch_metric_alarm" "storage_capacity_xray" {
  alarm_name          = "maxwell-xray-storage-threshold-alarm"
  alarm_description   = "Radiant parallel: PACS storage threshold. Raw X-ray satellite data exceeding 5GB threshold. Mirrors how PACS administrators monitor storage capacity in a hospital radiology department."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "BucketSizeBytes"
  namespace           = "AWS/S3"
  period              = 86400
  statistic           = "Average"
  threshold           = 5368709120
  treat_missing_data  = "missing"

  dimensions = {
    BucketName  = "maxwell-obs-raw-xray-prod"
    StorageType = "StandardStorage"
  }

  alarm_actions = [aws_sns_topic.maxwell_alerts.arn]

  tags = merge(local.common_tags, {
    AlarmType       = "storage-threshold"
    RadiantParallel = "pacs-storage-alert"
  })
}


# ==============================================================
# ALARM 3 -- GAMMA BURST THRESHOLD
# Radiant parallel: STAT critical imaging finding
# Fires when gamma burst bucket receives unexpected writes.
# A gamma burst event exceeding threshold intensity requires
# immediate routing to the Radiation Safety Officer --
# exactly as a critical radiology finding routes STAT
# to the ordering provider via Radiant In Basket.
# ==============================================================

resource "aws_cloudwatch_metric_alarm" "gamma_burst_threshold" {
  alarm_name          = "maxwell-gamma-burst-threshold-alarm"
  alarm_description   = "Radiant parallel: STAT critical imaging finding. Gamma burst detector data spike indicating high-intensity event. Mirrors how Radiant routes critical findings immediately to ordering providers."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "NumberOfObjects"
  namespace           = "AWS/S3"
  period              = 3600
  statistic           = "Average"
  threshold           = 10
  treat_missing_data  = "missing"

  dimensions = {
    BucketName  = "maxwell-obs-raw-gamma-prod"
    StorageType = "AllStorageTypes"
  }

  alarm_actions = [aws_sns_topic.maxwell_alerts.arn]

  tags = merge(local.common_tags, {
    AlarmType       = "critical-threshold"
    RadiantParallel = "stat-critical-finding"
  })
}


# ==============================================================
# ALARM 4 -- DOSIMETRY ACCESS SPIKE
# Radiant parallel: Patient radiation dose record access
# Fires when dosimetry logs bucket receives unexpected access.
# Dosimetry records are restricted data -- any access spike
# outside normal patterns requires audit investigation.
# Mirrors NRC and HIPAA requirements for radiation
# exposure record access monitoring.
# ==============================================================

resource "aws_cloudwatch_metric_alarm" "dosimetry_access_spike" {
  alarm_name          = "maxwell-dosimetry-access-spike-alarm"
  alarm_description   = "Radiant parallel: Patient radiation dose record access anomaly. Unexpected access to dosimetry logs requires immediate audit investigation. Mirrors NRC and HIPAA radiation exposure record monitoring."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "NumberOfObjects"
  namespace           = "AWS/S3"
  period              = 3600
  statistic           = "Average"
  threshold           = 1
  treat_missing_data  = "missing"

  dimensions = {
    BucketName  = "maxwell-obs-dosimetry-logs-prod"
    StorageType = "AllStorageTypes"
  }

  alarm_actions = [aws_sns_topic.maxwell_alerts.arn]

  tags = merge(local.common_tags, {
    AlarmType       = "access-anomaly"
    RadiantParallel = "dose-record-access-monitor"
  })
}


# ==============================================================
# ALARM 5 -- UNAUTHORIZED REPORT ACCESS
# Radiant parallel: HIPAA access anomaly
# Fires when final reports bucket shows unexpected activity.
# Only Astrophysicists and Principal Investigators should
# access this bucket. Any other access pattern is anomalous.
# Mirrors how Epic audit logs flag unauthorized access
# to signed radiology reports.
# ==============================================================

resource "aws_cloudwatch_metric_alarm" "unauthorized_report_access" {
  alarm_name          = "maxwell-report-access-anomaly-alarm"
  alarm_description   = "Radiant parallel: HIPAA unauthorized access anomaly. Unexpected access to final observation reports outside authorized personas. Mirrors Epic audit monitoring for unauthorized radiology report access."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "NumberOfObjects"
  namespace           = "AWS/S3"
  period              = 86400
  statistic           = "Average"
  threshold           = 100
  treat_missing_data  = "missing"

  dimensions = {
    BucketName  = "maxwell-obs-final-reports-prod"
    StorageType = "AllStorageTypes"
  }

  alarm_actions = [aws_sns_topic.maxwell_alerts.arn]

  tags = merge(local.common_tags, {
    AlarmType       = "access-anomaly"
    RadiantParallel = "hipaa-access-monitor"
  })
}


# ==============================================================
# CLOUDTRAIL -- HIPAA AUDIT TRAIL
# Radiant parallel: Epic audit log
# Records every API call made in the MAXWELL environment.
# Writes to the dedicated audit logs bucket.
# No human has write access to this bucket --
# only CloudTrail writes here, mirroring how Epic
# audit logs are tamper-proof system records.
# ==============================================================

resource "aws_cloudtrail" "maxwell_audit" {
  name                          = "maxwell-observatory-audit-trail"
  s3_bucket_name                = aws_s3_bucket.audit_logs.id
  include_global_service_events = true
  is_multi_region_trail         = false
  enable_logging                = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type = "AWS::S3::Object"
      values = [
        "${aws_s3_bucket.raw_xray.arn}/",
        "${aws_s3_bucket.raw_gamma.arn}/",
        "${aws_s3_bucket.raw_radio.arn}/",
        "${aws_s3_bucket.raw_optical.arn}/",
        "${aws_s3_bucket.raw_infrared.arn}/",
        "${aws_s3_bucket.raw_uv.arn}/",
        "${aws_s3_bucket.raw_microwave.arn}/",
        "${aws_s3_bucket.signal_logs.arn}/",
        "${aws_s3_bucket.processed_results.arn}/",
        "${aws_s3_bucket.final_reports.arn}/",
        "${aws_s3_bucket.critical_alerts.arn}/",
        "${aws_s3_bucket.dosimetry_logs.arn}/"
      ]
    }
  }

  tags = merge(local.common_tags, {
    Purpose         = "hipaa-audit-trail"
    RadiantParallel = "epic-audit-log"
  })
}


# ==============================================================
# CLOUDWATCH DASHBOARD
# Radiant parallel: Radiology operations dashboard
# Single pane view of MAXWELL observatory health --
# storage levels, alarm states, and activity by bucket.
# ==============================================================

resource "aws_cloudwatch_dashboard" "maxwell_operations" {
  dashboard_name = "MAXWELL-Observatory-Operations"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "alarm"
        properties = {
          title  = "MAXWELL Observatory Alarms"
          alarms = [
            "arn:aws:cloudwatch:us-east-2:${data.aws_caller_identity.current.account_id}:alarm:maxwell-lifecycle-config-change-alarm",
            "arn:aws:cloudwatch:us-east-2:${data.aws_caller_identity.current.account_id}:alarm:maxwell-xray-storage-threshold-alarm",
            "arn:aws:cloudwatch:us-east-2:${data.aws_caller_identity.current.account_id}:alarm:maxwell-gamma-burst-threshold-alarm",
            "arn:aws:cloudwatch:us-east-2:${data.aws_caller_identity.current.account_id}:alarm:maxwell-dosimetry-access-spike-alarm",
            "arn:aws:cloudwatch:us-east-2:${data.aws_caller_identity.current.account_id}:alarm:maxwell-report-access-anomaly-alarm"
          ]
        }
      }
    ]
  })
}

data "aws_caller_identity" "current" {}
