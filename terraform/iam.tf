# ==============================================================
# MAXWELL OBSERVATORY -- IAM ROLES AND ACCESS CONTROL
# Phase 3: Identity and access management
#
# Structure:
#   Policy -> attached to -> Group -> assigned to -> User
#
# Never attach policies directly to users -- always via groups.
# This mirrors how Epic security is structured in a hospital:
# roles assigned to groups, staff added to groups.
#
# Each persona maps directly to an Epic Radiant role.
# ==============================================================


# ==============================================================
# IAM POLICIES
# One custom policy per persona defining exactly what S3
# actions are permitted on which buckets.
# ==============================================================

# Policy 1: Telescope Operator
# Radiant parallel: Radiology Technologist
# Can write raw instrument data only.
# Cannot access processed results, reports, or compliance data.
resource "aws_iam_policy" "telescope_operator" {
  name        = "maxwell-telescope-operator-policy"
  description = "Radiant parallel: Radiology Technologist. Write access to raw instrument buckets only."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "WriteRawInstrumentData"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::maxwell-obs-raw-xray-prod",
          "arn:aws:s3:::maxwell-obs-raw-xray-prod/*",
          "arn:aws:s3:::maxwell-obs-raw-gamma-prod",
          "arn:aws:s3:::maxwell-obs-raw-gamma-prod/*",
          "arn:aws:s3:::maxwell-obs-raw-radio-prod",
          "arn:aws:s3:::maxwell-obs-raw-radio-prod/*",
          "arn:aws:s3:::maxwell-obs-raw-optical-prod",
          "arn:aws:s3:::maxwell-obs-raw-optical-prod/*",
          "arn:aws:s3:::maxwell-obs-raw-infrared-prod",
          "arn:aws:s3:::maxwell-obs-raw-infrared-prod/*",
          "arn:aws:s3:::maxwell-obs-raw-uv-prod",
          "arn:aws:s3:::maxwell-obs-raw-uv-prod/*",
          "arn:aws:s3:::maxwell-obs-raw-microwave-prod",
          "arn:aws:s3:::maxwell-obs-raw-microwave-prod/*"
        ]
      }
    ]
  })
}

# Policy 2: Astrophysicist
# Radiant parallel: Radiologist
# Read processed results, write finalized reports.
resource "aws_iam_policy" "astrophysicist" {
  name        = "maxwell-astrophysicist-policy"
  description = "Radiant parallel: Radiologist. Read processed results, write final reports."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadProcessedResults"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::maxwell-obs-processed-results-prod",
          "arn:aws:s3:::maxwell-obs-processed-results-prod/*"
        ]
      },
      {
        Sid    = "WriteFinalReports"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::maxwell-obs-final-reports-prod",
          "arn:aws:s3:::maxwell-obs-final-reports-prod/*"
        ]
      }
    ]
  })
}

# Policy 3: Signal Processing Engineer
# Radiant parallel: PACS Administrator
# Read raw data, manage processed results and signal logs.
resource "aws_iam_policy" "signal_engineer" {
  name        = "maxwell-signal-engineer-policy"
  description = "Radiant parallel: PACS Administrator. Read raw data, manage processed results and signal logs."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadRawData"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::maxwell-obs-raw-xray-prod",
          "arn:aws:s3:::maxwell-obs-raw-xray-prod/*",
          "arn:aws:s3:::maxwell-obs-raw-gamma-prod",
          "arn:aws:s3:::maxwell-obs-raw-gamma-prod/*",
          "arn:aws:s3:::maxwell-obs-raw-radio-prod",
          "arn:aws:s3:::maxwell-obs-raw-radio-prod/*",
          "arn:aws:s3:::maxwell-obs-raw-optical-prod",
          "arn:aws:s3:::maxwell-obs-raw-optical-prod/*",
          "arn:aws:s3:::maxwell-obs-raw-infrared-prod",
          "arn:aws:s3:::maxwell-obs-raw-infrared-prod/*",
          "arn:aws:s3:::maxwell-obs-raw-uv-prod",
          "arn:aws:s3:::maxwell-obs-raw-uv-prod/*",
          "arn:aws:s3:::maxwell-obs-raw-microwave-prod",
          "arn:aws:s3:::maxwell-obs-raw-microwave-prod/*"
        ]
      },
      {
        Sid    = "ManageProcessedResults"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::maxwell-obs-processed-results-prod",
          "arn:aws:s3:::maxwell-obs-processed-results-prod/*",
          "arn:aws:s3:::maxwell-obs-signal-logs-prod",
          "arn:aws:s3:::maxwell-obs-signal-logs-prod/*"
        ]
      }
    ]
  })
}

# Policy 4: Principal Investigator
# Radiant parallel: Referring Physician
# Read-only access to final reports only.
resource "aws_iam_policy" "principal_investigator" {
  name        = "maxwell-principal-investigator-policy"
  description = "Radiant parallel: Referring Physician. Read-only access to final reports only."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadFinalReportsOnly"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::maxwell-obs-final-reports-prod",
          "arn:aws:s3:::maxwell-obs-final-reports-prod/*"
        ]
      }
    ]
  })
}

# Policy 5: Radiation Safety Officer
# Radiant parallel: Radiation Dosimetrist
# Manage dosimetry logs, read critical alerts.
resource "aws_iam_policy" "radiation_safety_officer" {
  name        = "maxwell-radiation-safety-policy"
  description = "Radiant parallel: Radiation Dosimetrist. Manage dosimetry logs, read critical alerts."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ManageDosimetryLogs"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::maxwell-obs-dosimetry-logs-prod",
          "arn:aws:s3:::maxwell-obs-dosimetry-logs-prod/*"
        ]
      },
      {
        Sid    = "ReadCriticalAlerts"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::maxwell-obs-critical-alerts-prod",
          "arn:aws:s3:::maxwell-obs-critical-alerts-prod/*"
        ]
      }
    ]
  })
}

# Policy 6: Compliance Auditor
# Radiant parallel: HIPAA Compliance Officer
# Read-only access to audit and dosimetry logs.
resource "aws_iam_policy" "compliance_auditor" {
  name        = "maxwell-compliance-auditor-policy"
  description = "Radiant parallel: HIPAA Compliance Officer. Read-only access to audit and dosimetry logs."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadAuditAndDosimetryLogs"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::maxwell-obs-audit-logs-prod",
          "arn:aws:s3:::maxwell-obs-audit-logs-prod/*",
          "arn:aws:s3:::maxwell-obs-dosimetry-logs-prod",
          "arn:aws:s3:::maxwell-obs-dosimetry-logs-prod/*"
        ]
      }
    ]
  })
}

# Policy 7: Critical Alert Monitor
# Radiant parallel: STAT Alert Recipient
# Read-only access to critical alerts bucket only.
resource "aws_iam_policy" "alert_monitor" {
  name        = "maxwell-alert-monitor-policy"
  description = "Radiant parallel: STAT Alert Recipient. Read-only access to critical alerts bucket only."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadCriticalAlertsOnly"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::maxwell-obs-critical-alerts-prod",
          "arn:aws:s3:::maxwell-obs-critical-alerts-prod/*"
        ]
      }
    ]
  })
}

# Policy 8: Observatory Data Administrator
# Radiant parallel: RIS Administrator
# Full management access to all MAXWELL buckets.
resource "aws_iam_policy" "data_administrator" {
  name        = "maxwell-data-administrator-policy"
  description = "Radiant parallel: RIS Administrator. Full management access to all MAXWELL buckets."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "FullObservatoryAccess"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketPolicy",
          "s3:PutBucketPolicy",
          "s3:GetLifecycleConfiguration",
          "s3:PutLifecycleConfiguration"
        ]
        Resource = [
          "arn:aws:s3:::maxwell-obs-*",
          "arn:aws:s3:::maxwell-obs-*/*"
        ]
      }
    ]
  })
}


# ==============================================================
# IAM USER GROUPS
# One group per persona. Policies attached at group level.
# Users inherit permissions through group membership.
# ==============================================================

resource "aws_iam_group" "telescope_operators" {
  name = "maxwell-telescope-operators"
}

resource "aws_iam_group" "astrophysicists" {
  name = "maxwell-astrophysicists"
}

resource "aws_iam_group" "signal_engineers" {
  name = "maxwell-signal-engineers"
}

resource "aws_iam_group" "principal_investigators" {
  name = "maxwell-principal-investigators"
}

resource "aws_iam_group" "radiation_safety_officers" {
  name = "maxwell-radiation-safety-officers"
}

resource "aws_iam_group" "compliance_auditors" {
  name = "maxwell-compliance-auditors"
}

resource "aws_iam_group" "alert_monitors" {
  name = "maxwell-alert-monitors"
}

resource "aws_iam_group" "data_administrators" {
  name = "maxwell-data-administrators"
}


# ==============================================================
# GROUP POLICY ATTACHMENTS
# Attach each custom policy to its matching group.
# ==============================================================

resource "aws_iam_group_policy_attachment" "telescope_operators" {
  group      = aws_iam_group.telescope_operators.name
  policy_arn = aws_iam_policy.telescope_operator.arn
}

resource "aws_iam_group_policy_attachment" "astrophysicists" {
  group      = aws_iam_group.astrophysicists.name
  policy_arn = aws_iam_policy.astrophysicist.arn
}

resource "aws_iam_group_policy_attachment" "signal_engineers" {
  group      = aws_iam_group.signal_engineers.name
  policy_arn = aws_iam_policy.signal_engineer.arn
}

resource "aws_iam_group_policy_attachment" "principal_investigators" {
  group      = aws_iam_group.principal_investigators.name
  policy_arn = aws_iam_policy.principal_investigator.arn
}

resource "aws_iam_group_policy_attachment" "radiation_safety_officers" {
  group      = aws_iam_group.radiation_safety_officers.name
  policy_arn = aws_iam_policy.radiation_safety_officer.arn
}

resource "aws_iam_group_policy_attachment" "compliance_auditors" {
  group      = aws_iam_group.compliance_auditors.name
  policy_arn = aws_iam_policy.compliance_auditor.arn
}

resource "aws_iam_group_policy_attachment" "alert_monitors" {
  group      = aws_iam_group.alert_monitors.name
  policy_arn = aws_iam_policy.alert_monitor.arn
}

resource "aws_iam_group_policy_attachment" "data_administrators" {
  group      = aws_iam_group.data_administrators.name
  policy_arn = aws_iam_policy.data_administrator.arn
}


# ==============================================================
# IAM USERS
# One user per persona assigned to matching group.
# Console access disabled -- these are service personas.
# ==============================================================

resource "aws_iam_user" "telescope_operator" {
  name = "maxwell-telescope-operator-01"
  tags = merge(local.common_tags, { Role = "telescope-operator" })
}

resource "aws_iam_user" "astrophysicist" {
  name = "maxwell-astrophysicist-01"
  tags = merge(local.common_tags, { Role = "astrophysicist" })
}

resource "aws_iam_user" "signal_engineer" {
  name = "maxwell-signal-engineer-01"
  tags = merge(local.common_tags, { Role = "signal-engineer" })
}

resource "aws_iam_user" "principal_investigator" {
  name = "maxwell-principal-investigator-01"
  tags = merge(local.common_tags, { Role = "principal-investigator" })
}

resource "aws_iam_user" "radiation_safety_officer" {
  name = "maxwell-radiation-safety-officer-01"
  tags = merge(local.common_tags, { Role = "radiation-safety-officer" })
}

resource "aws_iam_user" "compliance_auditor" {
  name = "maxwell-compliance-auditor-01"
  tags = merge(local.common_tags, { Role = "compliance-auditor" })
}

resource "aws_iam_user" "alert_monitor" {
  name = "maxwell-alert-monitor-01"
  tags = merge(local.common_tags, { Role = "alert-monitor" })
}

resource "aws_iam_user" "data_administrator" {
  name = "maxwell-data-administrator-01"
  tags = merge(local.common_tags, { Role = "data-administrator" })
}


# ==============================================================
# USER GROUP MEMBERSHIPS
# Assign each user to their matching group.
# ==============================================================

resource "aws_iam_user_group_membership" "telescope_operator" {
  user   = aws_iam_user.telescope_operator.name
  groups = [aws_iam_group.telescope_operators.name]
}

resource "aws_iam_user_group_membership" "astrophysicist" {
  user   = aws_iam_user.astrophysicist.name
  groups = [aws_iam_group.astrophysicists.name]
}

resource "aws_iam_user_group_membership" "signal_engineer" {
  user   = aws_iam_user.signal_engineer.name
  groups = [aws_iam_group.signal_engineers.name]
}

resource "aws_iam_user_group_membership" "principal_investigator" {
  user   = aws_iam_user.principal_investigator.name
  groups = [aws_iam_group.principal_investigators.name]
}

resource "aws_iam_user_group_membership" "radiation_safety_officer" {
  user   = aws_iam_user.radiation_safety_officer.name
  groups = [aws_iam_group.radiation_safety_officers.name]
}

resource "aws_iam_user_group_membership" "compliance_auditor" {
  user   = aws_iam_user.compliance_auditor.name
  groups = [aws_iam_group.compliance_auditors.name]
}

resource "aws_iam_user_group_membership" "alert_monitor" {
  user   = aws_iam_user.alert_monitor.name
  groups = [aws_iam_group.alert_monitors.name]
}

resource "aws_iam_user_group_membership" "data_administrator" {
  user   = aws_iam_user.data_administrator.name
  groups = [aws_iam_group.data_administrators.name]
}
