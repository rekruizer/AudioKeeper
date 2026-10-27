"""Check release scripts in disposable fixtures; never build, sign or publish the real app."""
import os
from pathlib import Path
import plistlib
import shutil
import subprocess
import tempfile

REPO = Path(__file__).resolve().parents[1]


def check_dmg(version="1.2.3", app_version="1.2.3", dmg_version="v1.2.3", fail=False):
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        (root / "Scripts").mkdir()
        shutil.copy(REPO / "Scripts/create_dmg.sh", root / "Scripts/create_dmg.sh")
        app = root / "AudioKeeper.app/Contents"
        app.mkdir(parents=True)
        (app / "Info.plist").write_bytes(plistlib.dumps({"CFBundleShortVersionString": version}))
        tools = root / "bin"
        tools.mkdir()
        hdiutil = tools / "hdiutil"
        hdiutil.write_text('#!/bin/bash\necho called >> invoked\n'
                           + ('exit 17\n' if fail else 'printf fixture > "${@: -1}"\n'))
        hdiutil.chmod(0o755)
        env = dict(os.environ, PATH=f"{tools}:{os.environ['PATH']}", APP_VERSION=app_version,
                   DMG_VERSION=dmg_version, APPLE_CERTIFICATE="", APPLE_CERTIFICATE_PASSWORD="")
        result = subprocess.run(["bash", "Scripts/create_dmg.sh"], cwd=root, env=env,
                                text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        matches = version == app_version and dmg_version == f"v{version}" and version == "1.2.3"
        assert (result.returncode == 0) == (matches and not fail), result.stdout
        assert (root / "invoked").exists() == matches, result.stdout
        if matches and not fail:
            assert (root / "AudioKeeper-v1.2.3.dmg").read_text() == "fixture"
        else:
            assert "✅ DMG created" not in result.stdout


def check_build(app_version="1.2.3", fail=False):
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        (root / "Scripts").mkdir()
        shutil.copy(REPO / "Scripts/build_release.sh", root / "Scripts/build_release.sh")
        shutil.copy(REPO / "AudioKeeper.entitlements", root / "AudioKeeper.entitlements")
        (root / "AudioKeeper.xcodeproj").mkdir()
        plist = plistlib.dumps({"CFBundleShortVersionString": "1.2.3"})
        (root / "Info.plist").write_bytes(plist)
        tools = root / "bin"
        tools.mkdir()
        xcode = tools / "xcodebuild"
        xcode.write_text('#!/bin/bash\n' + ('exit 19\n' if fail else
                         'mkdir -p build/Build/Products/Release/AudioKeeper.app/Contents\n'
                         'cp Info.plist build/Build/Products/Release/AudioKeeper.app/Contents/Info.plist\n'))
        sign = tools / "codesign"
        sign.write_text('#!/bin/bash\nprintf "%s " "$@" >> signing.log\necho >> signing.log\n')
        xcode.chmod(0o755)
        sign.chmod(0o755)
        env = dict(os.environ, PATH=f"{tools}:{os.environ['PATH']}", APP_VERSION=app_version,
                   APPLE_CERTIFICATE="", APPLE_CERTIFICATE_PASSWORD="")
        result = subprocess.run(["bash", "Scripts/build_release.sh"], cwd=root, env=env,
                                text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        assert (result.returncode == 0) == (app_version == "1.2.3" and not fail), result.stdout
        if not fail:
            assert "--entitlements AudioKeeper.entitlements" in (root / "signing.log").read_text()
        else:
            assert not (root / "signing.log").exists()


check_dmg()
check_dmg(app_version="1.2.4")
check_dmg(dmg_version="v1.2.4")
check_dmg(version="../invalid", app_version="../invalid", dmg_version="v../invalid")
check_dmg(fail=True)
check_build()
check_build(app_version="1.2.4")
check_build(fail=True)
print("PASS: packaging names, version mismatches, signing entitlements and build/DMG failure propagation (stubbed tools)")
