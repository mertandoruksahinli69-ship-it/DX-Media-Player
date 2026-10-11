# -*- mode: python ; coding: utf-8 -*-
from PyInstaller.utils.hooks import collect_data_files
from PyInstaller.utils.hooks import collect_dynamic_libs
from PyInstaller.utils.hooks import copy_metadata

datas = [('docs', 'docs'), ('assets', 'assets')]
binaries = [('runtime/libmpv-2.dll', 'runtime')]
datas += collect_data_files('faster_whisper')
datas += collect_data_files('ctranslate2')
datas += collect_data_files('sacremoses')
datas += collect_data_files('argostranslate')
datas += copy_metadata('faster-whisper')
datas += copy_metadata('huggingface-hub')
datas += copy_metadata('argostranslate')
datas += copy_metadata('ctranslate2')
binaries += collect_dynamic_libs('ctranslate2')


a = Analysis(
    ['main.py'],
    pathex=[],
    binaries=binaries,
    datas=datas,
    hiddenimports=['winrt.windows.media', 'winrt.windows.foundation', 'winrt.windows.storage.streams', 'winrt.windows.media.interop', 'PySide6.QtWebEngineCore', 'PySide6.QtWebEngineWidgets', 'mpv', 'dxplayer.plugin_host', 'faster_whisper', 'tokenizers', 'onnxruntime', 'av', 'dxplayer.ai_host', 'dxplayer.translation_host', 'argostranslate.package', 'ctranslate2._ext', 'sentencepiece'],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=['ctranslate2.converters', 'ctranslate2.specs', 'argostranslate.translate', 'argostranslate.sbd', 'spacy', 'stanza', 'torch', 'pandas', 'scipy', 'matplotlib', 'numba', 'llvmlite', 'sklearn', 'botocore', 'pytest'],
    noarchive=False,
    optimize=0,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='DXMediaPlayer',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=['assets/icons/dx.ico'],
)
coll = COLLECT(
    exe,
    a.binaries,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name='DXMediaPlayer',
)
