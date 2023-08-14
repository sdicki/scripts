
create_alert.pl: used to create terraform files in cloud-infra/terraform/grafana/alerts from a template.
> cd cloud-infra/terraform/grafana/environments/prod/alerts/site_metrics
> create_alert.pl

sctl_2_1pass.pl: used to more easily get scuttle credentials.
> cd ~/Development/git/vapor-io/edge-ops/sites/sea/ke2-sea
> sctl_2_1pass.pl
Password:
Processing the following secrets ...
0] ALERTMANAGER_CONFIG
1] BLACKBOX_POSTGRES_PASSWORD
2] DOCKER_CONFIG_JSON
3] EFR1_OPENCONFIG_PASSWORD
4] EFR1_OPENCONFIG_PASSWORD_REAL
5] EFR2_OPENCONFIG_PASSWORD
6] EFR2_OPENCONFIG_PASSWORD_REAL
7] GCP_EXTERNAL_DNS_CREDENTIAL
8] IPIO8_PASSWORD
9] OPENCONFIG_TLS_CERT
10] OPENCONFIG_TLS_KEY
11] SNMP_UPS_AUTH_PASSPHRASE
12] SNMP_UPS_CUSTOMER_AUTH_PASSPHRASE
13] SNMP_UPS_CUSTOMER_PRIVACY_PASSPHRASE
14] SNMP_UPS_PRIVACY_PASSPHRASE
15] ZEFR1_OPENCONFIG_PASSWORD
16] ZEFR2_OPENCONFIG_PASSWORD
TOTAL ITEM COUNT: 17

#######################################################################
0 - ALERTMANAGER_CONFIG
#######################################################################
<REDACTED>

#######################################################################
1 - BLACKBOX_POSTGRES_PASSWORD
#######################################################################
<REDACTED>
...

sctl_verify.pl: used to compare what was in scuttle vs. what has now been migrated to 1pass.
> cd ~
> sctl_verify.pl

sctl_2_envrc.pl: used to create repo dir .envrc files which should match what is contained in the .scuttle file.
> cd ~
> sctl_2_envrc.pl
