# MAXWELL Observatory — Electromagnetic Spectrum Data Infrastructure on AWS

> *"In 1865, James Clerk Maxwell wrote four equations that described electricity, magnetism,
> and light as a single unified force. Thirty years later, Wilhelm Röntgen aimed that force
> through a human hand and saw the bones inside. MAXWELL Observatory exists at that same
> intersection — monitoring electromagnetic radiation from the birth of the universe to
> understand the physics that made medical imaging possible."*

---

## Project Overview

MAXWELL (Multi-spectrum Astronomical Wavelength Exploration Laboratory) is a cloud
infrastructure project built on AWS S3 that simulates the data lifecycle management
system for a fictional space observatory monitoring electromagnetic radiation across
the full EM spectrum.

The project demonstrates core **Cloud Administrator** competencies — storage architecture,
lifecycle policy management, identity and access control, monitoring, and infrastructure
as code — framed around a domain that connects astrophysics directly to **Epic Radiant**
radiology workflows.

**Every AWS component in this project has a direct parallel in an Epic Radiant
deployment.** The physics are not decorative — they are the reason the parallel exists.

---

## The Science: Why Electromagnetism Connects Space to Radiology

### Maxwell's Equations — The Foundation of Both

James Clerk Maxwell unified electricity and magnetism in 1865 into four equations that:
- Predicted electromagnetic waves travel at the speed of light
- Proved that light itself is an electromagnetic wave
- Form the theoretical foundation of every Radiant imaging modality
- Are the same equations governing how radio signals from the Voyager spacecraft reach Earth

Wilhelm Röntgen discovered X-rays in 1895 as a direct consequence of Maxwell's framework.
Without electromagnetism theory, there is no radiology.

### The Electromagnetic Spectrum — One Physics, Many Instruments

Every imaging modality in Epic Radiant operates on a different frequency band of the
same electromagnetic spectrum that MAXWELL Observatory monitors from space:

| EM Band | MAXWELL Instrument | Radiant Modality | Clinical Use |
|---|---|---|---|
| Radio waves | Radio Array | MRI | Radio pulses interact with hydrogen protons in tissue |
| Microwave | CMB Detector | Microwave ablation | Heat-based tissue treatment |
| Infrared | Infrared Telescope | Thermal imaging | Inflammation, circulation, tumor detection |
| Visible light | Optical Telescope | Fluoroscopy | Real-time visual imaging |
| Ultraviolet | UV Monitor | Bone density imaging | Surface and shallow tissue |
| X-ray | X-Ray Satellite | X-Ray / CT | Bone, density contrast imaging |
| Gamma ray | Gamma Burst Detector | PET / Nuclear Medicine | Metabolic tracer imaging |

### The Big Bang as the First Imaging Study

The **Cosmic Microwave Background (CMB)** — captured by the microwave detector in this
project — is electromagnetic radiation released 380,000 years after the Big Bang when the
universe first became transparent to light. It is the oldest light in existence, and
Stephen Hawking spent much of his career studying its tiny temperature fluctuations as
seeds of every galaxy, star, and planet that followed.

It is, in the most literal sense, the universe's first imaging study.

---

## Architecture

```
COSMIC EM EVENT (Solar flare, gamma burst, CMB reading)
        ↓
TELESCOPE INSTRUMENT (radio / microwave / infrared / optical / uv / xray / gamma)
        ↓ [Telescope Operator writes]
RAW INSTRUMENT BUCKET (maxwell-obs-raw-[band]-prod)   ←── Dosimetry logs
        ↓ [Signal Processing Engineer]
SIGNAL PROCESSING LOGS (maxwell-obs-signal-logs-prod)  ←── Audit trail (CloudTrail)
        ↓ [Astrophysicist reads, analyzes]
PROCESSED RESULTS (maxwell-obs-processed-results-prod)
        ↓
        ├──→ FINAL REPORTS (maxwell-obs-final-reports-prod)
        │    [Astrophysicist writes → Principal Investigator reads]
        │
        └──→ CRITICAL ALERTS (maxwell-obs-critical-alerts-prod)
             [CloudWatch threshold breach → Alert Monitor notified]
```

---

## S3 Bucket Inventory

### Raw Instrument Buckets

| Bucket | EM Band | Radiant Parallel | Storage Class |
|---|---|---|---|
| maxwell-obs-raw-xray-prod | X-ray | DICOM X-Ray / CT study | Standard → Standard-IA → Glacier |
| maxwell-obs-raw-gamma-prod | Gamma ray | DICOM PET / Nuclear Med | Standard → Standard-IA → Glacier |
| maxwell-obs-raw-radio-prod | Radio wave | DICOM MRI study | Standard → Standard-IA → Glacier |
| maxwell-obs-raw-optical-prod | Visible light | DICOM Fluoroscopy | Standard → Standard-IA → Glacier |
| maxwell-obs-raw-infrared-prod | Infrared | DICOM Thermal study | Standard → Standard-IA → Glacier |
| maxwell-obs-raw-uv-prod | Ultraviolet | DICOM Bone density | Standard → Standard-IA → Glacier |
| maxwell-obs-raw-microwave-prod | Microwave | CMB baseline calibration | Standard → Standard-IA → Glacier |

### Operational Pipeline Buckets

| Bucket | Radiant Parallel | Retention |
|---|---|---|
| maxwell-obs-signal-logs-prod | HL7 ORM/ORU message logs | 60 days Standard → Archive |
| maxwell-obs-processed-results-prod | PACS processed imaging | 90 days Standard → Glacier |
| maxwell-obs-final-reports-prod | Signed radiology report | Permanent Standard-IA |
| maxwell-obs-critical-alerts-prod | STAT critical value alert | Permanent — legal record |
| maxwell-obs-dosimetry-logs-prod | Patient radiation dose record | 10-year retention |
| maxwell-obs-audit-logs-prod | HIPAA audit trail | 7-year retention |

---

## Security Configuration

All 13 buckets are configured with:

- **Block all public access** — no bucket in this project is publicly accessible
- **Versioning enabled** — every object version is preserved; mirrors Radiant's requirement
  that signed reports cannot be deleted, only addended
- **Server-side encryption (SSE-S3)** — all objects encrypted at rest with AES-256;
  mirrors HIPAA encryption requirements for PHI at rest
- **IAM-only access control** — ACLs disabled; all access governed by IAM policies

---

## Project Phases

| Phase | Description | Status |
|---|---|---|
| Phase 1 | S3 architecture, bucket creation, tagging, security baseline | ✅ Complete |
| Phase 2 | S3 lifecycle policies — automated tiering by data age | 🔄 In progress |
| Phase 3 | IAM roles and access control — 8 personas with scoped permissions | ⏳ |
| Phase 4 | CloudWatch monitoring and alerting — 5 alert types and dashboard | ⏳ |
| Phase 5 | Terraform automation — full environment provisioning as code | ⏳ |
| Phase 6 | Final documentation, architecture diagram, README polish | ⏳ |

---

## Infrastructure as Code

This project is managed with Terraform. To deploy the MAXWELL environment:

```bash
# Clone the repository
git clone https://github.com/[your-username]/MAXWELL-Observatory.git
cd MAXWELL-Observatory/terraform

# Initialize Terraform
terraform init

# Preview the deployment plan
terraform plan

# Deploy all resources
terraform apply
```

> **Note:** Requires AWS CLI configured with appropriate credentials and permissions
> to create S3 buckets, IAM roles, and CloudWatch resources.

---

## Radiant Clinical Connection

This project was designed to demonstrate how cloud infrastructure skills directly
support Epic Radiant deployments in healthcare environments. A Cloud Administrator
supporting a hospital radiology department would manage infrastructure that:

- Stores and tiers DICOM imaging files by modality and study age
- Maintains HL7 interface transaction logs for troubleshooting order routing failures
- Enforces RBAC so radiologists, technologists, and referring providers access only
  what their role permits
- Monitors storage thresholds, interface failures, and access anomalies
- Maintains a tamper-proof audit trail for HIPAA compliance

MAXWELL models every one of those functions — with the observable universe as the patient.

---

## Technology Stack

- **Cloud Platform:** Amazon Web Services (AWS)
- **Storage:** Amazon S3
- **Identity:** AWS IAM
- **Monitoring:** Amazon CloudWatch + CloudTrail
- **Infrastructure as Code:** Terraform (HashiCorp HCL)
- **Automation:** Python + boto3

---

## References

- Maxwell, J.C. (1865). *A Dynamical Theory of the Electromagnetic Field*
- Röntgen, W.C. (1895). *On a New Kind of Rays*
- Hawking, S. (1974). *Black hole explosions?* Nature, 248, 30–31
- NASA. *Cosmic Microwave Background* — WMAP Science Team
- Epic Systems. *Radiant Radiology Information System* — Epic UserWeb
