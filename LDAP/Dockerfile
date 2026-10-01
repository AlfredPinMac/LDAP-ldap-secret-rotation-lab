FROM osixia/openldap:1.5.0

# Copy seed LDIF into OpenLDAP's custom bootstrap directory
COPY users.ldif /container/service/slapd/assets/config/bootstrap/ldif/custom/50-users.ldif

RUN chmod 644 /container/service/slapd/assets/config/bootstrap/ldif/custom/50-users.ldif
