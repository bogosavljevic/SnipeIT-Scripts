# SnipeIT-Scripts
Helpful scripts for daily activities in Snipe-IT through the API

1) company-id.ps1 - This script is useful if you’re utilizing the multi-company feature in Snipe-IT and need a workaround for the platform’s lack of automatic user-to-company assignment post-LDAP sync. It effectively pulls specific data (like department or company) synced from LDAP for users in Snipe-IT, and maps them to the correct company based on these values. For example, if a user’s attribute value is ‘UK’, the script will assign them to company with ID ‘5’, or ‘DE’ will assign them to company ID ‘1’. Additionally, the script handles paging for 500 queries due to Snipe-IT API limitations.
