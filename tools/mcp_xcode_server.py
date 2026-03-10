#!/usr/bin/env python3
import os
import shlex
import subprocess
from typing import List, Optional

from mcp.server.fastmcp import FastMCP

mcp = FastMCP("xcode-tools")


def _run(cmd: List[str], cwd: Optional[str] = None, timeout: int = 60 * 30) -> str:
    proc = subprocess.run(
        cmd,
        cwd=cwd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        timeout=timeout,
        check=False,
    )
    return proc.stdout


def _xcodebuild_base(
    scheme: str,
    project: Optional[str],
    workspace: Optional[str],
    configuration: Optional[str],
    destination: Optional[str],
    derived_data: Optional[str],
    extra_args: Optional[List[str]],
) -> List[str]:
    cmd = ["xcodebuild"]
    if workspace:
        cmd += ["-workspace", workspace]
    if project:
        cmd += ["-project", project]
    cmd += ["-scheme", scheme]
    if configuration:
        cmd += ["-configuration", configuration]
    if destination:
        cmd += ["-destination", destination]
    if derived_data:
        cmd += ["-derivedDataPath", derived_data]
    if extra_args:
        cmd += extra_args
    return cmd


@mcp.tool()
def xcodebuild_build(
    scheme: str,
    project: Optional[str] = None,
    workspace: Optional[str] = None,
    configuration: str = "Debug",
    destination: Optional[str] = None,
    derived_data: Optional[str] = None,
    extra_args: Optional[List[str]] = None,
    cwd: Optional[str] = None,
) -> str:
    """Build an Xcode scheme. Provide either project or workspace."""
    cmd = _xcodebuild_base(
        scheme=scheme,
        project=project,
        workspace=workspace,
        configuration=configuration,
        destination=destination,
        derived_data=derived_data,
        extra_args=extra_args,
    ) + ["build"]
    return _run(cmd, cwd=cwd)


@mcp.tool()
def xcodebuild_test(
    scheme: str,
    project: Optional[str] = None,
    workspace: Optional[str] = None,
    configuration: str = "Debug",
    destination: Optional[str] = None,
    derived_data: Optional[str] = None,
    extra_args: Optional[List[str]] = None,
    cwd: Optional[str] = None,
) -> str:
    """Run tests for an Xcode scheme. Provide either project or workspace."""
    cmd = _xcodebuild_base(
        scheme=scheme,
        project=project,
        workspace=workspace,
        configuration=configuration,
        destination=destination,
        derived_data=derived_data,
        extra_args=extra_args,
    ) + ["test"]
    return _run(cmd, cwd=cwd)


@mcp.tool()
def ios_deploy_install(
    app_path: str,
    device_id: Optional[str] = None,
    just_launch: bool = True,
    extra_args: Optional[List[str]] = None,
    cwd: Optional[str] = None,
) -> str:
    """Install (and optionally launch) an .app bundle on a connected iPhone using ios-deploy."""
    cmd = ["ios-deploy", "--bundle", app_path]
    if just_launch:
        cmd.append("--justlaunch")
    if device_id:
        cmd += ["--id", device_id]
    if extra_args:
        cmd += extra_args
    return _run(cmd, cwd=cwd)


@mcp.tool()
def list_devices() -> str:
    """List connected devices via xctrace."""
    cmd = ["xcrun", "xctrace", "list", "devices"]
    return _run(cmd)


@mcp.tool()
def devicectl_list_devices() -> str:
    """List devices via devicectl."""
    cmd = ["xcrun", "devicectl", "list", "devices"]
    return _run(cmd)


@mcp.tool()
def devicectl_install_app(device_id: str, app_path: str, cwd: Optional[str] = None) -> str:
    """Install an .app bundle on a connected device using devicectl."""
    cmd = ["xcrun", "devicectl", "device", "install", "app", "--device", device_id, app_path]
    return _run(cmd, cwd=cwd)


@mcp.tool()
def devicectl_launch_app(device_id: str, bundle_id: str, cwd: Optional[str] = None) -> str:
    """Launch an installed app by bundle id using devicectl."""
    cmd = ["xcrun", "devicectl", "device", "process", "launch", "--device", device_id, bundle_id]
    return _run(cmd, cwd=cwd)


if __name__ == "__main__":
    mcp.run()
