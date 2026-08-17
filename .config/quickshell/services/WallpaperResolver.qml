pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia.Images
import qs.services

Singleton {
    id: root

    function resolve(basePath: string, targetAspect: real): string {
        // (0) Empty path guard
        if (!basePath) return basePath;

        // Define canonical aspects
        const aspects = [
            { token: "16:9", ratio: 16 / 9 },
            { token: "16:10", ratio: 16 / 10 }
        ];

        // Find nearest canonical aspect to targetAspect
        let nearest = aspects[0];
        let nearestDiff = Math.abs(targetAspect - aspects[0].ratio);
        for (let i = 1; i < aspects.length; i++) {
            const diff = Math.abs(targetAspect - aspects[i].ratio);
            if (diff < nearestDiff) {
                nearestDiff = diff;
                nearest = aspects[i];
            }
        }

        // Extract basePath info
        const lastSlash = basePath.lastIndexOf('/');
        const filename = lastSlash >= 0 ? basePath.substring(lastSlash + 1) : basePath;
        const parentDir = lastSlash >= 0 ? basePath.substring(0, lastSlash) : "";
        const dotParts = filename.split('.');
        const ext = dotParts.length > 1 ? "." + dotParts[dotParts.length - 1] : "";
        let baseName = dotParts.length > 1
            ? dotParts.slice(0, -1).join('.')
            : filename;

        // Strip existing aspect token from baseName (e.g. "gruvbox:16:10" → "gruvbox")
        if (baseName.endsWith(":16:9"))
            baseName = baseName.substring(0, baseName.length - 5);
        else if (baseName.endsWith(":16:10"))
            baseName = baseName.substring(0, baseName.length - 6);

        // Helper: safely call IUtils.imageAspect
        function safeImageAspect(p: string): real {
            try {
                return IUtils.imageAspect(p);
            } catch (e) {
                return -1;
            }
        }

        // (1) PRIMARY: Construct expected sibling path and verify via imageAspect.
        //     This does NOT depend on Wallpapers.list, so it works even when
        //     the FileSystemModel hasn't populated yet.
        const canonTarget = baseName + ":" + nearest.token;
        const siblingPath = parentDir + "/" + canonTarget + ext;
        if (siblingPath !== basePath) {
            const siblingAspect = safeImageAspect(siblingPath);
            if (siblingAspect > 0) {
                // File exists and is readable — return it
                return siblingPath;
            }
        }

        // (2) FALLBACK: No conforming sibling found
        // (2a) Check if basePath itself is within 1% of targetAspect
        const basePathAspect = safeImageAspect(basePath);
        if (basePathAspect > 0 && Math.abs(basePathAspect - targetAspect) / targetAspect < 0.01) {
            return basePath;
        }

        // (2b) Scan Wallpapers.list for dimension-matched siblings
        //      (only works when FileSystemModel has populated)
        const entries = Wallpapers.list;
        let bestPath = basePath;
        let bestDiff = Infinity;
        for (let i = 0; i < entries.length; i++) {
            const entry = entries[i];
            if (entry.parentDir === parentDir
                    && entry.baseName.startsWith(baseName)
                    && entry.path !== basePath) {
                const aspect = safeImageAspect(entry.path);
                if (aspect > 0) {
                    const diff = Math.abs(aspect - targetAspect) / targetAspect;
                    if (diff < bestDiff) {
                        bestDiff = diff;
                        bestPath = entry.path;
                    }
                }
            }
        }

        if (bestDiff < 0.01) {
            return bestPath;
        }

        // (3) Return basePath as default
        return basePath;
    }

    IpcHandler {
        function resolve(basePath: string, targetAspect: real): string {
            return root.resolve(basePath, targetAspect);
        }

        target: "wallpaperResolver"
    }
}