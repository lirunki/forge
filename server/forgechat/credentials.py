"""Generate ForgeChat secrets and support owner-password recovery."""

from __future__ import annotations

import argparse
import getpass
import os
from pathlib import Path

from .access import AccessStore
from .auth import hash_password, random_session_secret


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=("hash-password", "session-secret", "set-owner-password"))
    parser.add_argument("--username", default=os.environ.get("FORGECHAT_USERNAME", "owner"))
    app_dir = Path(os.environ.get("FORGECHAT_APP_DIR", "/var/lib/forgechat/apps")).expanduser()
    access_db = Path(os.environ.get("FORGECHAT_ACCESS_DB", str(app_dir / ".access.sqlite3")).strip()).expanduser()
    parser.add_argument("--access-db", type=Path, default=access_db)
    args = parser.parse_args()
    if args.action in {"hash-password", "set-owner-password"}:
        password = getpass.getpass("ForgeChat password (9+ characters): ")
        confirm = getpass.getpass("Confirm password: ")
        if password != confirm:
            parser.error("Passwords do not match.")
        try:
            encoded = hash_password(password)
        except ValueError as exc:
            parser.error(str(exc))
        if args.action == "set-owner-password":
            accounts = AccessStore(args.access_db)
            account = accounts.get_user(args.username)
            if account is None or account["role"] != "owner":
                parser.error("Configured owner account was not found in the access database.")
            accounts.set_password(account["username"], encoded)
            print("Owner password updated; active sessions have been invalidated.")
        else:
            print(encoded)
    else:
        print(random_session_secret())


if __name__ == "__main__":
    main()
