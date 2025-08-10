from bs4 import BeautifulSoup
from urllib.parse import urlparse
from typing import List

def extract_whitelist_domains(bookmarks_file: str) -> List[str]:
    """
    Extract unique top-level domains from a Netscape-format bookmarks HTML file.

    Args:
        bookmarks_file (str): Path to the bookmarks HTML file.

    Returns:
        List[str]: Sorted list of unique domains in 'https://example.com' format.
    """
    with open(bookmarks_file, "r", encoding="utf-8") as f:
        soup = BeautifulSoup(f, "html.parser")

    # Extract all URLs
    urls = [a["href"] for a in soup.find_all("a", href=True)]

    # Convert to scheme + domain
    def get_top_domain(url):
        parsed = urlparse(url)
        return f"{parsed.scheme}://{parsed.netloc}"

    # Remove duplicates and sort
    return sorted(set(get_top_domain(url) for url in urls))

# Example usage (if running directly)
if __name__ == "__main__":
    domains = extract_whitelist_domains("bookmarks.html")
    for domain in domains:
        print(domain)
