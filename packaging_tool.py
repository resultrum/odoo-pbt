#!/usr/bin/env python3
"""
Fixed packaging_tool.py for PyCharm compatibility
Handles packages with None names in metadata
"""
import sys


def do_list():
    """List installed packages without triggering the None name bug"""
    try:
        import importlib.metadata as metadata
    except ImportError:
        import importlib_metadata as metadata

    for dist in metadata.distributions():
        # FIX: Handle None name - this was the root cause of the PyCharm error
        pkg_name = dist.name if dist.name is not None else "unknown"
        pkg_version = dist.version if dist.version is not None else "unknown"
        pkg_path = str(dist._path.parent) if hasattr(dist, '_path') else ""

        # Get requires
        requires = []
        try:
            if dist.requires:
                requires = list(dist.requires)
        except:
            pass

        requires_str = ':'.join(requires) if requires else ""

        # Create output - all must be strings to avoid TypeError
        output_parts = [
            str(pkg_name),
            str(pkg_version),
            str(pkg_path),
            str(requires_str)
        ]

        sys.stdout.write('\t'.join(output_parts) + '\n')


def main():
    """Main entry point"""
    try:
        do_list()
    except Exception as e:
        sys.stderr.write(f'Error: {e}\n')
        sys.exit(1)


if __name__ == '__main__':
    main()
