#!/usr/bin/env python3
"""
JuwishPro Automated cPanel SFTP Deployment Script
Uploads production codebase directly to cPanel server over SFTP using Paramiko.
"""

import os
import sys
import argparse
import paramiko
from stat import S_ISDIR

EXCLUDE_DIRS = {
    '.git',
    'node_modules',
    '.next',
    'juwish_pro_flutter',
    '.cache',
    'coverage',
    'temp',
}

EXCLUDE_FILES = {
    '.DS_Store',
    'Thumbs.db',
    'npm-debug.log',
    'yarn-debug.log',
    'sftp_deploy.py',
}

def sftp_mkdir_p(sftp, remote_directory):
    """Recursively creates remote directories on SFTP if they don't exist."""
    dirs_to_create = []
    dir_path = remote_directory
    while len(dir_path) > 1:
        try:
            sftp.stat(dir_path)
            break
        except IOError:
            dirs_to_create.append(dir_path)
            dir_path = os.path.dirname(dir_path)

    while dirs_to_create:
        dir_to_create = dirs_to_create.pop()
        try:
            sftp.mkdir(dir_to_create)
            print(f"📁 Created remote directory: {dir_to_create}")
        except IOError:
            pass

def upload_directory(sftp, local_path, remote_path):
    """Recursively uploads local directory to remote SFTP directory."""
    sftp_mkdir_p(sftp, remote_path)

    total_files = 0
    uploaded_files = 0

    # Count total files
    for root, dirs, files in os.walk(local_path):
        dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]
        files = [f for f in files if f not in EXCLUDE_FILES]
        total_files += len(files)

    print(f"🚀 Starting upload of {total_files} files to {remote_path}...")

    for root, dirs, files in os.walk(local_path):
        dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]

        relative_path = os.path.relpath(root, local_path)
        current_remote_dir = (
            remote_path
            if relative_path == '.'
            else os.path.join(remote_path, relative_path).replace('\\', '/')
        )

        sftp_mkdir_p(sftp, current_remote_dir)

        for filename in files:
            if filename in EXCLUDE_FILES or filename.endswith('.log'):
                continue

            local_file = os.path.join(root, filename)
            remote_file = os.path.join(current_remote_dir, filename).replace('\\', '/')

            try:
                sftp.put(local_file, remote_file)
                uploaded_files += 1
                percent = (uploaded_files / total_files) * 100 if total_files > 0 else 100
                print(f"[{uploaded_files}/{total_files} ({percent:.1f}%)] ⬆️ Uploaded: {remote_file}")
            except Exception as e:
                print(f"❌ Failed to upload {local_file} -> {remote_file}: {e}")

    print(f"\n✅ Upload completed successfully! Total {uploaded_files} files deployed.")

def main():
    parser = argparse.ArgumentParser(description="JuwishPro cPanel SFTP Automated Deployer")
    parser.add_argument("--host", default=os.getenv("SFTP_HOST", "2026.dmillers.org"), help="SFTP Host / IP")
    parser.add_argument("--port", type=int, default=int(os.getenv("SFTP_PORT", 22)), help="SFTP Port (default: 22)")
    parser.add_argument("--user", default=os.getenv("SFTP_USER"), required=not os.getenv("SFTP_USER"), help="cPanel Username")
    parser.add_argument("--password", default=os.getenv("SFTP_PASSWORD"), required=not os.getenv("SFTP_PASSWORD"), help="cPanel Password")
    parser.add_argument("--remote-path", default=os.getenv("SFTP_REMOTE_PATH", "/home/username/public_html/2026"), help="Remote target directory path in cPanel")
    parser.add_argument("--local-path", default=os.getcwd(), help="Local project directory (default: current directory)")

    args = parser.parse_args()

    print("==================================================")
    print("📡 Connecting to cPanel SFTP Server...")
    print(f"   Host: {args.host}")
    print(f"   Port: {args.port}")
    print(f"   User: {args.user}")
    print(f"   Target: {args.remote_path}")
    print("==================================================")

    transport = paramiko.Transport((args.host, args.port))
    try:
        transport.connect(username=args.user, password=args.password)
        sftp = paramiko.SFTPClient.from_transport(transport)
        print("🔓 SFTP Connection established successfully!\n")

        upload_directory(sftp, args.local_path, args.remote_path)

        sftp.close()
        transport.close()
        print("\n🎉 Deployment to 2026.dmillers.org completed!")
    except Exception as e:
        print(f"❌ SFTP Connection Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()

