#!/usr/bin/env python3

import subprocess
import sys
import shutil
import re
from pathlib import Path
from datetime import datetime

def get_latest_commit_hash(repo_url: str) -> str:
    """Fetch the latest commit hash using git ls-remote"""
    try:
        result = subprocess.run(
            ['git', 'ls-remote', repo_url, 'HEAD'],
            capture_output=True,
            text=True,
            check=True
        )
        # Extract commit hash (first part before tab)
        commit_hash = result.stdout.split('\t')[0].strip()
        return commit_hash
    except subprocess.CalledProcessError as e:
        print(f"❌ Failed to fetch latest commit: {e}")
        sys.exit(1)

def get_current_ref_from_pubspec(pubspec_path: Path) -> str:
    """Extract the current ref from pubspec.yaml"""
    try:
        if not pubspec_path.exists():
            print(f"❌ pubspec.yaml not found at: {pubspec_path.absolute()}")
            sys.exit(1)
        
        content = pubspec_path.read_text()
        
        # Look for ref: pattern in the file
        ref_pattern = r'ref:\s*([a-f0-9]{40})'
        matches = re.findall(ref_pattern, content)
        
        if not matches:
            print("❌ No git ref found in pubspec.yaml")
            sys.exit(1)
        
        # Return the first ref found (assuming all refs are the same)
        current_ref = matches[0]
        print(f"📋 Found current ref in pubspec.yaml: {current_ref}")
        return current_ref
        
    except Exception as e:
        print(f"❌ Failed to read current ref from pubspec.yaml: {e}")
        sys.exit(1)

def update_pubspec_refs(pubspec_path: Path, old_ref: str, new_ref: str) -> int:
    """Update all refs in pubspec.yaml and return number of replacements"""
    try:
        # Check if pubspec.yaml exists
        if not pubspec_path.exists():
            print(f"❌ pubspec.yaml not found at: {pubspec_path.absolute()}")
            print(f"💡 Current working directory: {Path.cwd()}")
            sys.exit(1)
        
        # Create backup folder and backup file
        project_root = pubspec_path.parent
        backup_dir = project_root / "pubspec_backups"
        backup_dir.mkdir(exist_ok=True)
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_filename = f"pubspec.yaml.backup.{timestamp}"
        backup_path = backup_dir / backup_filename
        
        shutil.copy2(pubspec_path, backup_path)
        print(f"💾 Backup created: {backup_path.relative_to(project_root)}")
        
        # Read and update content
        content = pubspec_path.read_text()
        updated_content = content.replace(old_ref, new_ref)
        
        # Count replacements
        replacements = content.count(old_ref)
        
        if replacements == 0:
            print("✅ Already up to date!")
            return 0
        
        # Write updated content
        pubspec_path.write_text(updated_content)
        print(f"✅ Updated pubspec.yaml with new ref: {new_ref}")
        print(f"📊 Updated {replacements} module references")
        
        return replacements
    except Exception as e:
        print(f"❌ Failed to update pubspec.yaml: {e}")
        sys.exit(1)

def run_flutter_pub_get(project_root: Path):
    """Run flutter pub get"""
    try:
        print("🔄 Running flutter pub get...")
        subprocess.run(['flutter', 'pub', 'get'], cwd=project_root, check=True)
        print("✅ Flutter pub get completed successfully!")
    except subprocess.CalledProcessError:
        print("❌ Flutter pub get failed, but refs were updated")
        print("💡 You may need to run 'flutter clean' and try again")

def main():
    repo_url: str = "https://github.com/Pet-Pals/whiskr_mobile_modules.git"
    
    # Get the script's directory and find the project root
    script_dir: Path = Path(__file__).parent
    project_root: Path = script_dir.parent  # Go up one level from scripts/ to project root
    pubspec_path: Path = project_root / "pubspec.yaml"
    
    print(f"📁 Project root: {project_root.absolute()}")
    print(f"📄 Looking for pubspec.yaml at: {pubspec_path.absolute()}")
    
    # Get current ref from pubspec.yaml
    current_ref: str = get_current_ref_from_pubspec(pubspec_path)
    
    print("🔍 Fetching latest commit from whiskr_mobile_modules...")
    latest_commit: str = get_latest_commit_hash(repo_url)
    
    print(f"📋 Current ref: {current_ref}")
    print(f"🆕 Latest commit: {latest_commit}")
    
    if current_ref == latest_commit:
        print("✅ Already up to date!")
        return
    
    print("🔄 Updating pubspec.yaml...")
    replacements: int = update_pubspec_refs(pubspec_path, current_ref, latest_commit)
    
    if replacements > 0:
        run_flutter_pub_get(project_root)
        print("🎉 Successfully updated all module references!")

if __name__ == "__main__":
    main()


    # This script is designed to update module references in a Flutter project's pubspec.yaml file.
    # It performs the following main functions:
    # 1. Gets the current git reference from pubspec.yaml
    # 2. Fetches the latest commit hash from the whiskr_mobile_modules repository
    # 3. Updates all module references in pubspec.yaml if a newer commit is available
    # 4. Runs flutter pub get to update dependencies
    #
    # The script includes error handling and provides clear console output
    # about the update process and any potential issues.