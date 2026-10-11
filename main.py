import sys

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--dx-smoke":
        from dxplayer.smoke import main
    elif len(sys.argv) > 1 and sys.argv[1] == "--dx-web-smoke":
        from dxplayer.web_smoke import main
    elif len(sys.argv) > 1 and sys.argv[1] in {"--dx-plugin-host", "--dx-ai-host", "--dx-translation-host"}:
        from dxplayer.silent import restore_host_stdio
        restore_host_stdio()
        mode = sys.argv.pop(1)
        if mode == "--dx-plugin-host":
            from dxplayer.plugin_host import main
        elif mode == '--dx-translation-host':
            from dxplayer.translation_host import main
        else:
            from dxplayer.ai_host import main
    else:
        from dxplayer.app import main
    main()
