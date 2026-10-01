# LDAP Service

This service provides centralized identity and directory services using OpenLDAP (`osixia/openldap:1.5.0`) and phpLDAPadmin.

## Directory Structure
- **Base DN**: `dc=example,dc=com`
- **Admin DN**: `cn=admin,dc=example,dc=com`
- **Organizational Units**: `ou=users`, `ou=groups`

## Seeded Accounts
| Username | Password | Email | Full Name | Group |
|---|---|---|---|---|
| `alice` | `alice123` | `alice@example.com` | Alice Smith | developers |
| `bob` | `bob123` | `bob@example.com` | Bob Johnson | developers |
| `admin` | *(Rotated dynamically)* | `admin@example.com` | Administrator | Administrators |

## Secret Management & Rotation
- The LDAP administrator password (`LDAP_ADMIN_PASSWORD`) is tracked in `/secrets/ldap_secret.env`.
- It participates in the 3-service secret rotation workflow using `ldappasswd`.
