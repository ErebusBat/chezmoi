# Workstation Configuration

This context defines the language for deploying OMP personal-profile settings across machines while preserving an explicit host-presentation choice.

## Language

**OMP profile**:
An isolated OMP identity whose credentials, providers, and settings belong together; it does not classify the host.
_Avoid_: Machine class, host profile

**Personal configuration variant**:
A complete deployable `personal`-profile settings document whose only intentional difference from another variant is the declared host-presentation policy.
_Avoid_: Overlay, profile link

**Canonical personal configuration**:
Normalized shared `personal`-profile settings from which variants derive.
_Avoid_: Master file, default variant
