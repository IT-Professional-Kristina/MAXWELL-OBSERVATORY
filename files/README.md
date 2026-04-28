# MAXWELL Observatory
## Electromagnetic Spectrum Data Infrastructure on AWS

> *"In 1865, James Clerk Maxwell wrote four equations that described electricity,
> magnetism, and light as a single unified force. Thirty years later, Wilhelm Rontgen
> aimed that force through a human hand and saw the bones inside. MAXWELL Observatory
> exists at that same intersection -- monitoring electromagnetic radiation from the
> birth of the universe to understand the physics that made medical imaging possible."*

---

## Project Overview

MAXWELL (Multi-spectrum Astronomical Wavelength Exploration Laboratory) is a
cloud infrastructure project built on AWS that simulates the data lifecycle
management system for a fictional space observatory monitoring electromagnetic
radiation across the full EM spectrum.

The project demonstrates core Cloud Administrator and IAM Engineer competencies --
storage architecture, lifecycle policy management, identity and access control,
monitoring, and infrastructure as code -- framed around a domain that connects
astrophysics directly to Epic Radiant radiology workflows.

Every AWS component in this project has a direct parallel in an Epic Radiant
deployment. The physics are not decorative -- they are the reason the parallel exists.

---

## The Science: Why Electromagnetism Connects Space to Radiology

### Maxwell's Equations -- The Foundation of Both

James Clerk Maxwell unified electricity and magnetism in 1865 into four equations that:
- Predicted electromagnetic waves travel at the speed of light
- Proved that light itself is an electromagnetic wave
- Form the theoretical foundation of every Radiant imaging modality
- Govern how radio signals from the Voyager spacecraft reach Earth today

Wilhelm Rontgen discovered X-rays in 1895 as a direct consequence of Maxwell's
framework. Without electromagnetism theory, there is no radiology.

### The Electromagnetic Spectrum -- One Physics, Many Instruments

| EM Band | MAXWELL Instrument | Radiant Modality | Clinical Use |
|---|---|---|---|
| Radio waves | Radio Array | MRI | Radio pulses interact with hydrogen protons |
| Microwave | CMB Detector | Microwave ablation | Heat-based tissue treatment |
| Infrared | Infrared Telescope | Thermal imaging | Inflammation and tumor detection |
| Visible light | Optical Telescope | Fluoroscopy | Real-time visual imaging |
| Ultraviolet | UV Monitor | Bone density imaging | Surface and shallow tissue |
| X-ray | X-Ray Satellite | X-Ray / CT | Bone and density contrast imaging |
| Gamma ray | Gamma Burst Detector | PET / Nuclear Medicine | Metabolic tracer imaging |

### The Big Bang as the First Imaging Study

The Cosmic Microwave Background (CMB) is electromagnetic radiation released
380,000 years after the Big Bang when the universe first became transparent to
light. Stephen Hawking spent much of his career studying its temperature
fluctuations as seeds of every galaxy, star, and planet that followed.
It is the universe's first imaging study.

---

## Architecture

```
COSMIC EM EVENT (Solar flare, gamma burst, CMB reading)
        |
TELESCOPE INSTRUMENT (radio/microwave/infrared/optical/uv/xray/gamma)
        |  [Telescope Operator writes]
RAW INSTRUMENT BUCKET (maxwell-obs-raw-[band]-prod)
        |  [Signal Processing Engineer]
SIGNAL PROCESSING LOGS (maxwell-obs-signal-logs-prod)
        |  [Astrophysicist reads, analyzes]
PROCESSED RESULTS (maxwell-obs-processed-results-prod)
        |
        |---> FINAL REPORTS (maxwell-obs-final-reports-prod)
        |
        '---> CRITICAL ALERTS (maxwell-obs-critical-alerts-prod)
              [CloudWatch -> SNS notification]
```

---

## S3 Bucket Inventory (13 Buckets)

### Raw Instrument Buckets

| Bucket | EM Band | Radiant Parallel |
|---|---|---|
| maxwell-obs-raw-xray-prod | X-ray | DICOM X-Ray / CT study |
| maxwell-obs-raw-gamma-prod | Gamma ray | DICOM PET / Nuclear Med |
| maxwell-obs-raw-radio-prod | Radio wave | DICOM MRI study |
| maxwell-obs-raw-optical-prod | Visible light | DICOM Fluoroscopy |
| maxwell-obs-raw-infrared-prod | Infrared | DICOM Thermal study |
| maxwell-obs-raw-uv-prod | Ultraviolet | DICOM Bone density |
| maxwell-obs-raw-microwave-prod | Microwave | CMB baseline calibration |

### Operational Pipeline Buckets

| Bucket | Radiant Parallel | Retention |
|---|---|---|
| maxwell-obs-signal-logs-prod | HL7 ORM/ORU message logs | 60d -> Archive |
| maxwell-obs-processed-results-prod | PACS processed imaging | 90d -> Glacier |
| maxwell-obs-final-reports-prod | Signed radiology report | Permanent Standard-IA |
| maxwell-obs-critical-alerts-prod | STAT critical value alert | Permanent Standard |
| maxwell-obs-dosimetry-logs-prod | Patient radiation dose record | 10-year retention |
| maxwell-obs-audit-logs-prod | HIPAA audit trail | 7-year retention |

---

## IAM Personas (8 Roles)

| MAXWELL Role | Radiant Parallel | Access Scope |
|---|---|---|
| maxwell-telescope-operator-01 | Radiology Technologist | Write raw instrument buckets only |
| maxwell-astrophysicist-01 | Radiologist | Read processed results, write final reports |
| maxwell-signal-engineer-01 | PACS Administrator | Read raw, manage processed and signal logs |
| maxwell-principal-investigator-01 | Referring Physician | Read final reports only |
| maxwell-radiation-safety-officer-01 | Radiation Dosimetrist | Manage dosimetry, read alerts |
| maxwell-compliance-auditor-01 | HIPAA Compliance Officer | Read audit and dosimetry logs |
| maxwell-alert-monitor-01 | STAT Alert Recipient | Read critical alerts only |
| maxwell-data-administrator-01 | RIS Administrator | Full environment management |

---

## Monitoring and Alerting (5 Alarms)

| Alarm | Radiant Parallel | Trigger |
|---|---|---|
| maxwell-lifecycle-config-change-alarm | Change control monitor | Lifecycle policy modification |
| maxwell-xray-storage-threshold-alarm | PACS storage alert | X-ray bucket exceeds 5GB |
| maxwell-gamma-burst-threshold-alarm | STAT critical finding | Gamma bucket object spike |
| maxwell-dosimetry-access-spike-alarm | Dose record access anomaly | Unexpected dosimetry access |
| maxwell-report-access-anomaly-alarm | HIPAA access anomaly | Final report access spike |

---

## Security Configuration

All 13 buckets configured with:
- Block all public access
- Versioning enabled
- Server-side encryption AES-256
- IAM-only access control

---

## Project Phases

| Phase | Description | Status |
|---|---|---|
| Phase 1 | S3 architecture, 13 buckets, tagging, security baseline | Complete |
| Phase 2 | S3 lifecycle policies -- automated tiering by data age | Complete |
| Phase 3 | IAM roles and access control -- 8 personas | Complete |
| Phase 4 | CloudWatch monitoring -- 5 alarms, CloudTrail audit | Complete |
| Phase 5 | Master provisioning script | Complete |
| Phase 6 | Final documentation | Complete |

---

## Deploy This Project

```bash
git clone https://github.com/IT-Professional-Kristina/MAXWELL-Observatory.git
cd MAXWELL-Observatory
chmod +x provision.sh
./provision.sh
```

---

## Repository Structure

```
MAXWELL-Observatory/
|-- README.md
|-- provision.sh
|-- .gitignore
|-- terraform/
|   |-- main.tf
|   |-- variables.tf
|   |-- lifecycle.tf
|   |-- iam.tf
|   '-- cloudwatch.tf
'-- docs/
    '-- radiant-parallel-mapping.md
```

---

## Technology Stack

- Cloud Platform: Amazon Web Services (AWS)
- Storage: Amazon S3
- Identity: AWS IAM
- Monitoring: Amazon CloudWatch and CloudTrail
- Alerting: Amazon SNS
- Infrastructure as Code: Terraform
- Scripting: Bash

---

## Healthcare IT Connection

A Cloud Administrator supporting a hospital radiology department manages
infrastructure that stores and tiers DICOM imaging files, maintains HL7
interface transaction logs, enforces RBAC for radiologists and technologists,
monitors storage thresholds and access anomalies, and maintains a tamper-proof
audit trail for HIPAA compliance. MAXWELL models every one of those functions
-- with the observable universe as the patient.

---

## References

- Maxwell, J.C. (1865). A Dynamical Theory of the Electromagnetic Field
- Rontgen, W.C. (1895). On a New Kind of Rays
- Hawking, S. (1974). Black hole explosions? Nature, 248, 30-31
- NASA WMAP Science Team. Cosmic Microwave Background
- Epic Systems. Radiant Radiology Information System
