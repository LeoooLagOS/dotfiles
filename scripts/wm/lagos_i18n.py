"""Translations for the desktop scripts, shared with the Quickshell panel
(config/quickshell/panel/common/Tr.qml): the language is the panel's
Settings → Appearance → Language, or the system's (LANG) when it says
"System"; the words come from the panel's i18n/<lang>.json, keyed by the
English text. A missing one stays English.

    from lagos_i18n import t
    t("Download complete")
    t("Battery at %1", cap)        # %1, %2… = the arguments
"""

import json
import os

CONFIG = os.environ.get("XDG_CONFIG_HOME", os.path.expanduser("~/.config"))
I18N_DIR = os.path.join(CONFIG, "quickshell", "panel", "i18n")


def _lang() -> str:
    lang = "system"
    try:
        with open(os.path.join(CONFIG, "lagos", "panel-settings.json")) as f:
            lang = json.load(f).get("language") or "system"
    except (OSError, ValueError):
        pass
    if lang == "system":
        lang = os.environ.get("LC_ALL") or os.environ.get("LC_MESSAGES") or os.environ.get("LANG") or "en"
    for sep in "_.@":
        lang = lang.split(sep)[0]
    return lang


def _load() -> dict:
    lang = _lang()
    if lang == "en":
        return {}
    try:
        with open(os.path.join(I18N_DIR, f"{lang}.json")) as f:
            return json.load(f)
    except (OSError, ValueError):
        return {}


_DICT = _load()


def t(text: str, *args) -> str:
    out = _DICT.get(text) or text
    for i, a in enumerate(args, 1):
        out = out.replace(f"%{i}", str(a))
    return out
