#define _GNU_SOURCE
#include <nss.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <regex.h>
#include <stdio.h>
#include <string.h>

enum nss_status
_nss_regex_gethostbyname2_r(const char *name, int af,
                            struct hostent *result, char *buffer,
                            size_t buflen, int *errnop, int *h_errnop) {
    FILE *fp = fopen("/etc/regexhosts", "r");
    if (!fp) return NSS_STATUS_NOTFOUND;

    char pattern[256];
    regex_t preg;
    int matched = 0;

    while (fscanf(fp, "%255s", pattern) == 1) {
        if (regcomp(&preg, pattern, REG_EXTENDED|REG_NOSUB) == 0) {
            if (regexec(&preg, name, 0, NULL, 0) == 0) {
                matched = 1;
                regfree(&preg);
                break;
            }
            regfree(&preg);
        }
    }
    fclose(fp);

    if (matched) {
        // Match -> NotFound -> VPN(DNS)
        return NSS_STATUS_NOTFOUND;
    } else {
        // Loop back block
        static char loopback[] = "127.0.0.1";
        static struct in_addr addr;
        inet_pton(AF_INET, loopback, &addr);

        char **addr_list = (char **) buffer;
        buffer += sizeof(char *) * 2;

        char *addr_buf = buffer;
        memcpy(addr_buf, &addr, sizeof(addr));

        addr_list[0] = addr_buf;
        addr_list[1] = NULL;

        result->h_addrtype = AF_INET;
        result->h_length = sizeof(addr);
        result->h_addr_list = addr_list;
        result->h_name = (char *) name;

        return NSS_STATUS_SUCCESS;
    }
}