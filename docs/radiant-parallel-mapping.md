# Radiant Parallel Mapping — MAXWELL Observatory

This document explains the direct relationship between each AWS component
in the MAXWELL project and its equivalent in an Epic Radiant deployment.

---

## Why This Mapping Exists

Epic Radiant is a Radiology Information System (RIS) built on the physics of
electromagnetic radiation. Every imaging modality it manages — X-ray, CT, MRI,
PET, fluoroscopy, nuclear medicine — operates on a different frequency band of
the same electromagnetic spectrum that astronomical observatories monitor from
space. The infrastructure required to manage that data follows identical patterns
regardless of whether the source is a patient or a galaxy.

---

## Component-Level Mapping

### Storage Layer

| MAXWELL Component | AWS Resource | Radiant Equivalent | Notes |
|---|---|---|---|
| Raw X-ray satellite data | S3 bucket | DICOM image store (X-Ray/CT) | Same physics — photons through matter |
| Raw gamma burst data | S3 bucket | DICOM PET/Nuclear Med store | Gamma photons from radioactive tracers |
| Raw radio array data | S3 bucket | DICOM MRI store | Radio waves interact with H protons |
| Raw optical data | S3 bucket | DICOM Fluoroscopy store | Real-time visual capture |
| Raw infrared data | S3 bucket | DICOM Thermal imaging store | Heat signature detection |
| Raw UV data | S3 bucket | DICOM Bone density store | High-energy surface imaging |
| Raw microwave data | S3 bucket | CMB baseline / calibration | Background radiation reference |
| Signal processing logs | S3 bucket | HL7 ORM/ORU message logs | Order routing transaction records |
| Processed results | S3 bucket | PACS image archive | Post-processing, QC-passed data |
| Final reports | S3 bucket | Signed radiology reports | Permanent, versioned, legal record |
| Critical alerts | S3 bucket | STAT critical value alerts | Immediate routing required |
| Dosimetry logs | S3 bucket | Patient radiation dose record | Cumulative exposure tracking |
| Audit logs | S3 bucket | HIPAA audit trail | Every access and modification logged |

### Access Control Layer

| MAXWELL IAM Role | Radiant Role | Access Scope |
|---|---|---|
| Astrophysicist | Radiologist | Read processed results, write final reports |
| Telescope Operator | Radiology Technologist | Write raw instrument buckets only |
| Signal Processing Engineer | PACS Administrator | Read/write processed results |
| Principal Investigator | Referring/Ordering Physician | Read final reports for their projects |
| Observatory Data Administrator | RIS Administrator | Full environment management |
| Radiation Safety Officer | Radiation Dosimetrist | Read/write dosimetry logs |
| Compliance Auditor | HIPAA Compliance Officer | Read audit logs only |
| Critical Alert Monitor | STAT Alert Recipient | Read critical alerts only |

### Workflow Layer

| MAXWELL Event | Radiant Workflow Step |
|---|---|
| Cosmic EM event detected | Imaging order placed by provider |
| Telescope instrument captures signal | Modality (CT/MRI/XR) performs exam |
| Raw data written to S3 | DICOM image sent to PACS |
| Signal processing log entry | HL7 ORM message transmitted to modality |
| Processed result written | Radiologist worklist populated |
| Threshold alert triggered | Critical value STAT notification fired |
| Astrophysicist writes final report | Radiologist signs and finalizes report |
| Principal Investigator reads report | Referring provider receives result in In Basket |
| CloudTrail logs all activity | Epic audit log records all access |

### Lifecycle Policy Layer

| Data Type | MAXWELL Retention Logic | Radiant / HIPAA Equivalent |
|---|---|---|
| Raw instrument data | Standard 30d → Standard-IA 90d → Glacier 1yr | DICOM image retention by modality age |
| Signal logs | Standard 60d → Glacier 180d | HL7 log retention for interface troubleshooting |
| Processed results | Standard 90d → Standard-IA 1yr → Glacier 2yr | PACS archive tiering |
| Final reports | Permanent Standard-IA | Signed reports — permanent medical record |
| Critical alerts | Permanent Standard | Legal record — never archived |
| Dosimetry logs | Standard 180d → Glacier 5yr → Deep Archive 10yr | NRC/HIPAA radiation exposure retention |
| Audit logs | Standard 90d → Glacier 1yr → Deep Archive 7yr | HIPAA audit log 6-year minimum retention |

---

## The HL7 Parallel in Detail

In Epic Radiant, two HL7 message types govern the imaging workflow:

- **ORM (Order Message)** — sent from Epic to the imaging modality when an order is placed.
  If this message fails, the exam never appears on the technologist's worklist.
- **ORU (Result Message)** — sent from the modality back to Epic when the exam is complete.
  If this message fails, the radiologist never receives the study to read.

When either fails, a Radiant analyst traces the HL7 transaction log to find where the
message broke — wrong patient ID, missing order number, interface timeout.

In MAXWELL, the `maxwell-obs-signal-logs-prod` bucket captures every transaction between
telescope instruments and the processing pipeline. When data stops arriving from the
gamma burst detector, the signal log is the first place to look — exactly as a Radiant
analyst checks HL7 logs when a radiology order goes missing.

---

## The PACS Parallel in Detail

PACS (Picture Archiving and Communication System) is the image archive that sits between
the imaging modality and the radiologist's workstation in a Radiant environment. Raw DICOM
data from the scanner is not what the radiologist reads — it passes through PACS for
reconstruction, compression, and quality control before being presented on the reading
workstation.

In MAXWELL, raw telescope signal data is noisy, uncalibrated, and full of atmospheric
interference. It passes through a signal processing layer — removing noise, calibrating
against known reference stars — before landing in `maxwell-obs-processed-results-prod`
as clean, analysis-ready data. The astrophysicist reads from this bucket exactly as a
radiologist reads from PACS.
