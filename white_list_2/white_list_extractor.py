# /opt/white_list/white_list_extractor.py
from bs4 import BeautifulSoup
from urllib.parse import urlparse
from typing import List

def extract_whitelist_domains(bookmarks_file: str) -> List[str]:
    """
    Extract unique hostnames from a Netscape-format bookmarks HTML file.
    Returns e.g. ["example.com", "sub.example.com"] without scheme.
    """
    with open(bookmarks_file, "r", encoding="utf-8") as f:
        soup = BeautifulSoup(f, "html.parser")

    urls = [a["href"] for a in soup.find_all("a", href=True)]

    hosts = []
    for url in urls:
        try:
            host = urlparse(url).hostname
            if host:
                hosts.append(host.lower().strip("."))
        except Exception:
            pass
    print(sorted(set(hosts)))
    return sorted(set(hosts))

if __name__ == "__main__":
    for d in extract_whitelist_domains("bookmarks.html"):
        print(d)
