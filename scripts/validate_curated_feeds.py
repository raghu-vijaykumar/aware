import json
import sys
import time
import io
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")

FEEDS_PATH = Path(__file__).resolve().parent.parent / "client" / "assets" / "curated_feeds.json"
REQUEST_TIMEOUT = 15
MAX_WORKERS = 20


def feed_is_alive(url: str) -> tuple[str, bool, str]:
    try:
        req = Request(url, headers={"User-Agent": "AwareFeedValidator/1.0"})
        with urlopen(req, timeout=REQUEST_TIMEOUT) as resp:
            body = resp.read(8192)
        status = resp.getcode()
        if status != 200:
            return url, False, f"HTTP {status}"
        snippet = body.decode("utf-8", errors="replace").strip()
        if snippet.startswith("<?xml") or snippet.startswith("<rss") or snippet.startswith("<feed"):
            return url, True, "ok"
        return url, False, "response is not RSS/XML"
    except HTTPError as e:
        return url, False, f"HTTP {e.code}"
    except URLError as e:
        return url, False, f"network error: {e.reason}"
    except Exception as e:
        return url, False, str(e)


def main() -> int:
    feeds_raw = json.loads(FEEDS_PATH.read_text(encoding="utf-8-sig"))
    feeds = feeds_raw["feeds"]
    total = len(feeds)

    print(f"Validating {total} curated feeds ...\n")

    dead: list[dict] = []
    alive: list[dict] = []
    start = time.time()

    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as pool:
        fut_map = {pool.submit(feed_is_alive, f["url"]): f for f in feeds}
        for fut in as_completed(fut_map):
            feed = fut_map[fut]
            url, ok, reason = fut.result()
            status = "OK" if ok else "FAIL"
            title = feed.get("title", url) or url
            print(f"  [{status}] {title}")
            if not ok:
                print(f"          {url} -> {reason}")
                dead.append(feed)
            else:
                alive.append(feed)

    elapsed = time.time() - start
    print(f"\nResults: {len(alive)} alive, {len(dead)} dead in {elapsed:.1f}s")

    if not dead:
        return 0

    feeds_raw["feeds"] = alive
    content = json.dumps(feeds_raw, indent=2, ensure_ascii=False) + "\n"
    FEEDS_PATH.write_bytes(content.encode("utf-8-sig"))
    print(f"\nRemoved {len(dead)} dead feed(s). Updated curated_feeds.json")
    for f in dead:
        print(f"  - {f.get('title', f['url'])}")
    return 1


if __name__ == "__main__":
    sys.exit(main())
