# README

Simple sandbox project for building native macOS screensavers

## Overview

To build / select a screensaver:
1. (optionally) build a new `ScreenSaverView` implementation in `/ScreenSavers/`
2. update `MetalSaver/MetalSaver.swift` with the desired implementation
3. select a build target and run ("Preview" for windowed application, "MetalSaver" to build `.saver` file

